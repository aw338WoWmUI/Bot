--- Usage: /script Fishing.toggleFishing()

Fishing = Fishing or {}
local addOnName, AddOn = ...
local _ = {}

local MODE = 'FISHING' -- 'ICE_FISHING'
local HARPOONING = false

local FISHING_SPELL_ID = 131474
local FISHING_BOBBER_OBJECT_ID = 35591
local NIGHTCRAWLERS_ITEM_ID = 6530
local CAPTAIN_RUMSEYS_LAGER_ITEM_ID = 34832
local SCALEBELLY_MACKEREL_ITEM_ID = 194730
local LOOKING_FOR_LUNKERS_SPELL_ID = 392270
local HARPOON_SPELL_ID = 377081
local MAXIMUM_FISHING_DURATION = 30 -- seconds
local PULL_HARD_SPELL_ID = 374599
local HARPOON_RANGE = 50
local ICE_FISHING_HOLE_OBJECT_ID = 192631
local ICE_CRACK_OBJECT_ID = 377944
local ICE_FISHING = 377895
local AQUADYNAMIC_FISH_ATTRACTOR = 6533
local ISLEFIN_DORADO_LURE_ITEM_ID = 198403
local ISLEFIN_DORADO_LURE_SPELL_ID = 383094

local fishingPoleEnchantments = {
  AQUADYNAMIC_FISH_ATTRACTOR,
  NIGHTCRAWLERS_ITEM_ID
}

local lures = {
  {
    itemID = ISLEFIN_DORADO_LURE_ITEM_ID,
    spellID = ISLEFIN_DORADO_LURE_SPELL_ID
  }
}

local isFishing = false
local exitTimer = nil

local TEMPORAL_DRAGONHEAD_POOL = 381100
local THOUSANDBITE_PIRANHA_SWARM = 381097
local SCALEBELLY_MACKERAL_SWARM = 381096
local AILERON_SEAMOTH_SCHOOL = 381098
local POOL_OBJECT_IDS = Set.create({
  TEMPORAL_DRAGONHEAD_POOL,
  THOUSANDBITE_PIRANHA_SWARM,
  SCALEBELLY_MACKERAL_SWARM,
  AILERON_SEAMOTH_SCHOOL,
})

function _.isPool(pointer)
  local name = UnitName(pointer)
  return Boolean.toBoolean(string.match(name, 'Pool$') or string.match(name, 'Swarm$') or string.match(name, 'School$'))
end

function Fishing.measureDistance()
  local iceHole = Core.findClosestObjectToCharacterWithObjectID(ICE_FISHING_HOLE_OBJECT_ID)
  if iceHole then
    return Core.calculateDistanceFromCharacterToObject(iceHole)
  end
end

local TARGET_DISTANCE_TO_ICE_HOLE = 4.9033551216125
local TARGET_DISTANCE_TO_ICE_CRACK = TARGET_DISTANCE_TO_ICE_HOLE
local maxBreakingIceInteractDistance = 10.230718612671
local maxFishingDistance = 8.2202529907227
local MINIMUM_DISTANCE_FROM_ICE_HOLE = 2.884045124054

function Fishing.toggleFishing()
  if isFishing then
    exitTimer:Cancel()
    exitTimer = nil
    isFishing = false
  else
    isFishing = true

    exitTimer = C_Timer.NewTimer(_.hours(3), function()
      Exit()
    end)

    Coroutine.runAsCoroutine(function()
      while isFishing do
        if FishingOptions.fishInPools then
          local pools = Array.filter(Core.retrieveObjectPointers(), function(pointer)
            return Set.contains(POOL_OBJECT_IDS, HWT.ObjectId(pointer))
          end)
          local pool = _.selectPool(pools)
          if pool then
            _.fishInPool(pool)
          end
        end

        local iceHole = nil
        if MODE == 'ICE_FISHING' then
          iceHole = Core.findClosestObjectToCharacterWithObjectID(ICE_FISHING_HOLE_OBJECT_ID)
          if iceHole then
            local iceHolePosition = Core.retrieveObjectPosition(iceHole)
            g_iceHoles:setValue(iceHolePosition, true)
          else
            local iceCrack = Core.findClosestObjectToCharacterWithObjectID(ICE_CRACK_OBJECT_ID)
            if iceCrack then
              Fishing.positionForBreakingIce(iceCrack)
              Coroutine.waitUntil(function()
                return not IsFlying()
              end)
              Movement.faceObject(iceCrack, function()
                return not isFishing
              end)
              Core.interactWithObject(iceCrack)
              Events.waitForEventCondition('UNIT_SPELLCAST_STOP', function(self, event, unit)
                return unit == 'player'
              end)
              Coroutine.waitForDuration(1)
              iceHole = Core.findClosestObjectToCharacterWithObjectID(ICE_FISHING_HOLE_OBJECT_ID)
              if iceHole then
                local iceHolePosition = Core.retrieveObjectPosition(iceHole)
                g_iceHoles:setValue(iceHolePosition, true)
              end
            else
              -- local spots = g_iceHoles:retrieveAllValues()
              --_.findSpot(spots)
              --if _.hasFoundSpot() then
              --
              --end
            end
          end
        end

        if MODE == 'ICE_FISHING' and iceHole or MODE == 'FISHING' then
          if _.hasAFishingPoleEnchantment() and not _.isFishingPoleEnchantedWithFishingLure() then
            _.enchantFishingPoleWithBestFishingPoleEnchantment()
          end

          if _.hasALure() and not _.hasALureBuff() then
            _.buffWithLureBuff()
          end

          if _.hasCaptainRumseysLager() and _.isCaptainRumseysLagerBuffDurationShorterThanMaximumFishingDuration() then
            _.buffWithCaptainRumseysLagerBuff()
          end

          if MODE ~= 'ICE_FISHING' and _.hasScalebellyMackerel() and _.isChumBuffDurationShorterThanMaximumFishingDuration() then
            _.buffWithChumBuff()
          end

          if MODE == 'ICE_FISHING' then
            if iceHole then
              Fishing.positionForFishingInIceHole(iceHole)
              Movement.faceObject(iceHole, function()
                return not isFishing
              end)
              Core.interactWithObject(iceHole)
              Events.waitForEvent('UNIT_SPELLCAST_SUCCEEDED', 2)
            end
          else
            Core.castSpellByID(FISHING_SPELL_ID)
          end

          HWT.ResetAfk()
          Coroutine.waitForDuration(1)
          local fishingBobber = Fishing.findFishingBobber()
          -- TODO: It seems that "Massive Thresher" can appear.
          -- print('fishingBobber', fishingBobber)
          if fishingBobber then
            Coroutine.waitFor(function()
              return HWT.ObjectExists(fishingBobber) and HWT.ObjectAnimationState(fishingBobber) == 1
            end, MAXIMUM_FISHING_DURATION)
            if HWT.ObjectExists(fishingBobber) and HWT.ObjectAnimationState(fishingBobber) == 1 then
              local waitDurationBeforeInteractingWithBobber = _.randomFloat(0.2, 1)
              Coroutine.waitForDuration(waitDurationBeforeInteractingWithBobber)
              Core.interactWithObject(fishingBobber)
              HWT.ResetAfk()
            end

            local waitDurationUntilNextFishing = _.randomFloat(0.5, 1)
            Coroutine.waitForDuration(waitDurationUntilNextFishing)

            if _.isChannelingLookingForLunkers() then
              if _.hasLearnedHarpooning() and HARPOONING then
                Events.waitForEventCondition('UNIT_SPELLCAST_CHANNEL_STOP', function(self, event, unit)
                  return unit == 'player'
                end)

                Coroutine.waitForDuration(0.5)

                local lunker = Array.find(Core.retrieveObjectPointers(), function(pointer)
                  return (
                    UnitName(pointer) == 'Massive Thresher' and
                      Core.isAlive(pointer) and
                      Core.calculateDistanceFromCharacterToObject(pointer) <= HARPOON_RANGE
                  )
                end)

                if lunker then
                  local point = Core.retrieveObjectPosition(lunker)
                  Movement.facePoint(point)
                  UseItemByName('Iskaaran Harpoon')
                  Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function(self, event, unit, __, spellID)
                    return unit == 'player' and spellID == HARPOON_SPELL_ID
                  end)
                  Coroutine.waitFor(function()
                    local start = GetSpellCooldown(PULL_HARD_SPELL_ID)
                    return start > 0
                  end)
                  while Core.isAlive(lunker) do
                    local start, duration = GetSpellCooldown(PULL_HARD_SPELL_ID)
                    local cooldownDurationLeft = math.max(start + duration - GetTime(), 0)
                    if cooldownDurationLeft > 0 then
                      Coroutine.waitForDuration(cooldownDurationLeft)
                      Coroutine.waitFor(function()
                        local start = GetSpellCooldown(PULL_HARD_SPELL_ID)
                        return start == 0
                      end)
                    end
                    if Core.isAlive(lunker) then
                      Core.pressExtraActionButton1()
                      Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function(self, event, unit, __, spellID)
                        return unit == 'player' and spellID == PULL_HARD_SPELL_ID
                      end)
                    end
                    if not isFishing then
                      return
                    end
                    Coroutine.waitForDuration(0.5) -- Wait a little bit before checking if lunker is still alive.
                  end
                  await(Core.lootObject(lunker))
                end
              else
                SpellStopCasting()
                Events.waitForEventCondition('UNIT_SPELLCAST_CHANNEL_STOP', function(self, event, unit)
                  return unit == 'player'
                end)
              end
            end
          end
          if isFishing then
            if Bags.areBagsFull() then
              Quit()
              return
            end
          end
        end

        Coroutine.yieldAndResume()
      end
    end)
  end
end

function Fishing.positionForFishingInIceHole(iceHole)
  local iceHolePosition = Core.retrieveObjectPosition(iceHole)
  local position = Core.retrievePositionBetweenPositions(iceHolePosition, Core.retrieveCharacterPosition(),
    TARGET_DISTANCE_TO_ICE_HOLE)
  await(Core.moveToUntil(position, {
    stopCondition = _.createStopCondition(iceHole, MINIMUM_DISTANCE_FROM_ICE_HOLE, maxFishingDistance)
  }))
end

function Fishing.positionForBreakingIce(iceCrack)
  local iceCrackPosition = Core.retrieveObjectPosition(iceCrack)
  local position = Core.retrievePositionBetweenPositions(iceCrackPosition, Core.retrieveCharacterPosition(),
    TARGET_DISTANCE_TO_ICE_CRACK)
  await(Core.moveToUntil(position, {
    stopCondition = _.createStopCondition(iceCrack, TARGET_DISTANCE_TO_ICE_CRACK, maxBreakingIceInteractDistance)
  }))
end

function _.createStopCondition(object, minimumDistance, maximumDistance)
  return function()
    local distance = Core.calculateDistanceFromCharacterToObject(object)
    return not distance or (distance >= minimumDistance and distance <= maximumDistance)
  end
end

local poolPriorityList = {
  _.isMagmaThreasherPool,
  _.isRimefinTunaPool,
  _.isPrismaticLeaperPool,
  _.isIslefinDoradoPool,
}

function _.selectPool(pools)
  for __, isPoolOfType in ipairs(poolPriorityList) do
    local pool = Array.find(pools, isPoolOfType)
    if pool then
      return pool
    end
  end

  return _.findClosestPool(pools)
end

function _.findClosestPool(pools)
  return Array.min(pools, function(pool)
    return Core.calculateDistanceFromCharacterToObject(pool)
  end)
end

function _.fishInPool(pool)
  _.moveToPool(pool)
  if _.isCloseToPool(pool) then

  end
end

function _.moveToPool(pool)
  local standingSpot = _.findStandingSpotForFishingInPool(pool)
  if standingSpot then
    await(Core.moveTo(standingSpot))
  end
end

local DISTANCE_TO_FISHING_POOL = 10

function _.isCloseToPool(pool)
  return Core.calculateDistanceFromCharacterToObject(pool) <= DISTANCE_TO_FISHING_POOL
end

function _.findStandingSpotForFishingInPool(pool)
  local fishingPoolPosition = Core.retrieveObjectPosition(pool)
  local numberOfPointsOnCircle = 32
  local candidates = Movement.generatePointsAround(fishingPoolPosition, DISTANCE_TO_FISHING_POOL,
    numberOfPointsOnCircle)
  table.sort(candidates, _.compareStandingSpots)
  local spot = Array.find(candidates, _.doesPositionQualifyAsStandingSpot)
  return spot
end

function _.compareStandingSpots(a, b)
  return Core.calculateDistanceFromCharacterToPosition(a) < Core.calculateDistanceFromCharacterToPosition(b)
end

function _.doesPositionQualifyAsStandingSpot(position)

end

function _.hours(amount)
  return amount * 60 * 60
end

function _.hasAFishingPoleEnchantment()
  return Boolean.toBoolean(_.findBestFishingPoleEnchantment())
end

function _.findBestFishingPoleEnchantment()
  return Array.find(fishingPoleEnchantments, Bags.hasItem)
end

function _.isFishingPoleEnchantedWithFishingLure()
  local tooltip = C_TooltipInfo.GetInventoryItem('player', 28, false)
  return Array.any(tooltip.lines, _.isFishingPoleEnchantment)
end

function _.isFishingPoleEnchantment(line)
  TooltipUtil.SurfaceArgs(line)
  return line.type == 0 and string.match(line.leftText, '^Fishing Lure')
end

function _.hasALure()
  return Boolean.toBoolean(_.findLure())
end

function _.hasALureBuff()
  return Array.any(lures, function(lure)
    return Core.findAuraByID(lure.spellID, 'player')
  end)
end

function _.buffWithLureBuff()
  local lure = _.findLure()
  if lure then
    local itemID = lure.itemID
    if itemID then
      local itemName = GetItemInfo(itemID)
      if itemName then
        UseItemByName(itemName)
        -- TODO: Does this work?
        Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function(self, event, unit)
          return unit == 'player'
        end)
      end
    end
  end
end

function _.findLure()
  return Array.find(lures, function (lure)
    return Bags.hasItem(lure.itemID)
  end)
end

function _.enchantFishingPoleWithBestFishingPoleEnchantment()
  local itemID = _.findBestFishingPoleEnchantment()
  if itemID then
    local itemName = GetItemInfo(itemID)
    if itemName then
      UseItemByName(itemName)
      if IsCurrentItem(itemName) then
        PickupInventoryItem(28)
        Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function(self, event, unit)
          return unit == 'player'
        end)
      end
    end
  end
end

function _.hasCaptainRumseysLager()
  return Bags.hasItem(CAPTAIN_RUMSEYS_LAGER_ITEM_ID)
end

function _.isCaptainRumseysLagerBuffDurationShorterThanMaximumFishingDuration()
  return _.isBuffDurationShorterThanMaximumFishingDuration("Captain Rumsey's Lager")
end

function _.buffWithCaptainRumseysLagerBuff()
  _.useBuffItem("Captain Rumsey's Lager")
end

function _.hasScalebellyMackerel()
  return Bags.hasItem(SCALEBELLY_MACKEREL_ITEM_ID)
end

function _.isChumBuffDurationShorterThanMaximumFishingDuration()
  return _.isBuffDurationShorterThanMaximumFishingDuration('Chum')
end

function _.buffWithChumBuff()
  _.useBuffItem('Scalebelly Mackerel')
end

function _.isBuffDurationShorterThanMaximumFishingDuration(buffName)
  local expirationTime = select(6, AuraUtil.FindAuraByName(buffName, 'player'))
  return Boolean.toBoolean(not expirationTime or expirationTime - GetTime() < MAXIMUM_FISHING_DURATION)
end

function _.useBuffItem(itemName)
  UseItemByName(itemName)
  local waitDuration = _.randomFloat(0.5, 1)
  Coroutine.waitForDuration(waitDuration)
end

function _.hasLearnedHarpooning()
  -- FIXME
  -- return IsSpellKnown(ISKAARAN_HARPOON_SPELL_ID)
  return true
end

function _.isChannelingLookingForLunkers()
  local startTime, __, __, __, spellID = select(4, UnitChannelInfo('player'))
  return Boolean.toBoolean(startTime) and spellID == LOOKING_FOR_LUNKERS_SPELL_ID
end

function _.randomFloat(from, to)
  return from + math.random() * (to - from)
end

function Fishing.findFishingBobber()
  return Array.find(Core.retrieveObjectPointers(), function(pointer)
    return HWT.ObjectId(pointer) == FISHING_BOBBER_OBJECT_ID and HWT.GameObjectIsUsable(pointer, false)
  end)
end

local function onEvent(self, event, ...)
  if event == 'ADDON_LOADED' then
    _.onAddonLoaded(...)
  end
end

function _.onAddonLoaded(addOnName)
  if addOnName == 'Fishing' then
    _.initializeSavedVariables()
  end
end

function _.initializeSavedVariables()
  if not FishingOptions then
    FishingOptions = {
      fishInPools = false
    }
  end
  if g_iceHoles then
    g_iceHoles = Movement.createWorldPositionSetFromSavedVariable(g_iceHoles)
  else
    g_iceHoles = Movement.WorldPositionSet:new()
  end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', onEvent)
frame:RegisterEvent('ADDON_LOADED')
