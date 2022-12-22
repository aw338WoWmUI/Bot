--- Usage: /script Fishing.toggleFishing()

Fishing = Fishing or {}
local addOnName, AddOn = ...
local _ = {}

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
      while true do
        if FishingOptions.fishInPools then
          local pools = Array.filter(Core.retrieveObjectPointers(), function(pointer)
            return Set.contains(POOL_OBJECT_IDS, HWT.ObjectId(pointer))
          end)
          local pool = _.selectPool(pools)
          if pool then
            _.fishInPool(pool)
          end
        end

        local iceHole = Core.findClosestObjectToCharacterWithOneOfObjectIDs({ ICE_FISHING_HOLE_OBJECT_ID })

        if _.hasFishingLure() and not _.isFishingPoleEnchantedWithFishingLure() then
          _.enchantFishingPoleWithFishingLure()
        end

        if _.hasCaptainRumseysLager() and _.isCaptainRumseysLagerBuffDurationShorterThanMaximumFishingDuration() then
          _.buffWithCaptainRumseysLagerBuff()
        end

        if not iceHole and _.hasScalebellyMackerel() and _.isChumBuffDurationShorterThanMaximumFishingDuration() then
          _.buffWithChumBuff()
        end

        if iceHole then
          Core.interactWithObject(iceHole)
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

          if _.hasLearnedHarpooning() and _.isChannelingLookingForLunkers() then
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

            print('lunker', lunker)
            if lunker then
              local point = Core.retrieveObjectPosition(lunker)
              Movement.facePoint(point)
              UseItemByName('Iskaaran Harpoon')
              print('a')
              Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function(self, event, unit, __, spellID)
                return unit == 'player' and spellID == HARPOON_SPELL_ID
              end)
              print('b')
              Coroutine.waitFor(function()
                local start = GetSpellCooldown(PULL_HARD_SPELL_ID)
                return start > 0
              end)
              while Core.isAlive(lunker) do
                local start, duration = GetSpellCooldown(PULL_HARD_SPELL_ID)
                local cooldownDurationLeft = math.max(start + duration - GetTime(), 0)
                print('cooldownDurationLeft', cooldownDurationLeft)
                if cooldownDurationLeft > 0 then
                  print('c')
                  Coroutine.waitForDuration(cooldownDurationLeft)
                  Coroutine.waitFor(function()
                    local start = GetSpellCooldown(PULL_HARD_SPELL_ID)
                    return start == 0
                  end)
                  print('d')
                end
                if Core.isAlive(lunker) then
                  Core.pressExtraActionButton1()
                  print('e')
                  Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function(self, event, unit, __, spellID)
                    return unit == 'player' and spellID == PULL_HARD_SPELL_ID
                  end)
                  print('f')
                end
                if not isFishing then
                  return
                end
                Coroutine.waitForDuration(0.5) -- Wait a little bit before checking if lunker is still alive.
              end
              Resolvable.await(Core.lootObject(lunker))
            end
          end
        end
        if isFishing then
          if Questing.areBagsFull() then
            Quit()
            return
          end
        else
          return
        end
      end
    end)
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
    Resolvable.await(Core.moveTo(standingSpot))
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

function _.hasFishingLure()
  return Boolean.toBoolean(Bags.hasItem(NIGHTCRAWLERS_ITEM_ID))
end

function _.isFishingPoleEnchantedWithFishingLure()
  local tooltip = C_TooltipInfo.GetInventoryItem('player', 28, false)
  return Array.any(tooltip.lines, _.isFishingLureEnchantmentLine)
end

function _.isFishingLureEnchantmentLine(line)
  TooltipUtil.SurfaceArgs(line)
  return line.type == 0 and string.match(line.leftText, '^Fishing Lure')
end

function _.enchantFishingPoleWithFishingLure()
  -- C_Container.UseContainerItem
  UseItemByName('Nightcrawlers')
  PickupInventoryItem(28)
  Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function(self, event, unit)
    return unit == 'player'
  end)
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
  return Boolean.toBoolean(select(4, UnitChannelInfo('player')))
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
      fishInPools = true
    }
  end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', onEvent)
frame:RegisterEvent('ADDON_LOADED')
