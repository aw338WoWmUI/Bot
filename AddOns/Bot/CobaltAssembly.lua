local _ = {}

local WILD_ARCANA = 377132

local ARCANE_MASTERY = 385441
local COBALT_CATCH_UP = 385494
local KILLING_SPREE = 385814
local STUFFED_POCKETS = 385720
local TEMPORAL_HICCUPS = 385397
local ARCANE_ENLARGEMENT = 388818
local WHIMS_OF_FATE = 388905
local ARCANE_HEALTH = 385429
local ARCANE_LEAP = 374403
local TIME_SKIP = 385384
local ME_AND_MYSELF = 385917
local NEGA_JUMP = 388928
local ARCANE_INERTIA = 388746
local EXPLODING_MAP = 385651
local ARCANE_EQUALIZER = 385844
local QUICKENED = 385368
local ENOUGH = 386518
local MIRRORED_IMAGE = 385119
local ARCANE_LUCK = 385444
local ARCANE_CONSUMPTION = 386515
local ARCANE_TRANSFERENCE = 388704
local FUN_DETECTED = 394040
local TRAIL_BLAZER = 388733
local COLD_NOVA = 385701
local ARCANE_COMPACTION = 388819
local SUDDEN_SHEEP = 374402
local ARCANE_BRAVERY = 385841

local healingBuffs = {
  ARCANE_CONSUMPTION,
  ARCANE_HEALTH,
  ARCANE_TRANSFERENCE,
}

local priorityList = Array.concat(
  {
    FUN_DETECTED,
    KILLING_SPREE,
    ARCANE_MASTERY,
    ARCANE_COMPACTION,
    ARCANE_LUCK,
    ARCANE_EQUALIZER,
    QUICKENED,
    ARCANE_LEAP,
    MIRRORED_IMAGE,
    ENOUGH,
    ARCANE_INERTIA,
    SUDDEN_SHEEP,
    COLD_NOVA,
  },
  healingBuffs,
  {
    TIME_SKIP,
    ME_AND_MYSELF,
    STUFFED_POCKETS,
  }
)

local skip = Set.create({
  TEMPORAL_HICCUPS,
  ARCANE_ENLARGEMENT,
  WHIMS_OF_FATE,
  NEGA_JUMP,
  EXPLODING_MAP,
  TRAIL_BLAZER,
  ARCANE_BRAVERY,
})

local assigned = Set.union(Set.create(priorityList), skip, Set.create({ COBALT_CATCH_UP }))

local refreshable = Set.create({

})

local maximumNumberOfStacks = {
  [KILLING_SPREE] = 10,
  [ARCANE_MASTERY] = 100,
  [ARCANE_COMPACTION] = 100,
  [ARCANE_LUCK] = 100,
}

local stackable = Set.create(Object.keys(maximumNumberOfStacks))

local buffsToKeepUp = stackable

-- Maximum number of stacks: 100

function _.chooseAnOption()
  local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo()

  if choiceInfo then
    if choiceInfo.choiceID == 698 then

      local options = choiceInfo.options

      local optionsStillToAssign = Array.filter(options, function(option)
        return not assigned:contains(option.spellID)
      end)

      if optionsStillToAssign:isEmpty() then
        local option
        local catchUpOption = _.findOption(options, COBALT_CATCH_UP)
        if _.prioritizeRefreshing() and catchUpOption then
          _.chooseOption(catchUpOption)
        else
          local hasChosenAnOption = false
          for __, spell in ipairs(priorityList) do
            option = _.findOption(options, spell)
            local numberOfStacks, __, duration = select(3, Core.findAuraByID(spell, 'player', 'HELPFUL'))
            if option and (not duration or duration < 60 or (stackable:contains(spell) and numberOfStacks < maximumNumberOfStacks[spell])) then
              _.chooseOption(option)
              hasChosenAnOption = true
              break
            end
          end

          if not hasChosenAnOption then
            if catchUpOption then
              _.chooseOption(catchUpOption)
            else
              for __, spell in ipairs(priorityList) do
                option = _.findOption(options, spell)
                if option then
                  _.chooseOption(option)
                  hasChosenAnOption = true
                  break
                end
              end
            end
          end
        end
      else
        Array.forEach(optionsStillToAssign, function(option)
          print(option.header, option.spellID)
        end)
      end
    end
  end
end

function _.prioritizeRefreshing()
  return Array.any(buffsToKeepUp:toList(), function(spellID)
    local duration = select(5, Core.findAuraByID(spellID, 'player', 'HELPFUL'))
    return duration and duration <= 60
  end)
end

function _.findOption(options, spellID)
  return Array.find(options, function(option)
    return option.spellID == spellID
  end)
end

function _.chooseOption(option)
  local buttonID = option.buttons[1].id
  C_PlayerChoice.SendPlayerChoiceResponse(buttonID)
  PlayerChoiceFrame:Hide()
  PlayerChoiceTimeRemaining:HideTimer()
  GenericPlayerChoiceToggleButton:Hide()
end

local lastInteractedWith = {}

function Bot.doCombatAssemblyFarming()
  HWT.doWhenHWTIsLoaded(function()
    Coroutine.runAsCoroutineImmediately(function()
      while true do
        if not C_PlayerChoice.IsWaitingForPlayerChoiceResponse() then
          local newLastInteractedWith = {}
          for guid, lastInteractedWithTime in pairs(lastInteractedWith) do
            if GetTime() - lastInteractedWithTime < 0.5 then
              newLastInteractedWith[guid] = lastInteractedWithTime
            end
          end
          lastInteractedWith = newLastInteractedWith

          local wildArcana = Array.find(Core.retrieveObjectPointers(), function(object)
            return (
              HWT.ObjectId(object) == WILD_ARCANA and
                not lastInteractedWith[UnitGUID(object)] and
                HWT.GameObjectIsUsable(object, true) and
                HWT.GameObjectIsUsable(object, false) and
                Core.isInInteractionRange(object)
            )
          end)
          if wildArcana then
            if Core.interactWithObject(wildArcana) then
              local wasSuccessful = Coroutine.waitUntil(function ()
                return C_PlayerChoice.IsWaitingForPlayerChoiceResponse()
              end, 0.5)
              if wasSuccessful then
                lastInteractedWith[UnitGUID(wildArcana)] = GetTime()
                _.chooseAnOption()
                Coroutine.waitUntil(function ()
                  return not C_PlayerChoice.IsWaitingForPlayerChoiceResponse()
                end)
              end
            end
          end
        end

        Coroutine.yieldAndResume()
      end
    end)
  end)
end

-- Bot.doCombatAssemblyFarming()
