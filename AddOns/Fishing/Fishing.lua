--- Usage: /script Fishing.toggleFishing()

Fishing = Fishing or {}
local addOnName, AddOn = ...
local _ = {}

local FISHING_SPELL_ID = 131474
local FISHING_BOBBER_OBJECT_ID = 35591
local MAXIMUM_FISHING_DURATION = 30 -- seconds

local isFishing = false
local exitTimer = nil

function Fishing.toggleFishing()
  if isFishing then
    exitTimer:Cancel()
    exitTimer = nil
    isFishing = false
  else
    isFishing = true

    exitTimer = C_Timer.NewTimer(_.hours(3), function ()
      Exit()
    end)

    Coroutine.runAsCoroutine(function()
      while true do
        if not _.isFishingPoleEnchantedWithFishingLure() then
          _.enchantFishingPoleWithFishingLure()
        end

        if _.isCaptainRumseysLagerBuffDurationShorterThanMaximumFishingDuration() then
          _.buffWithCaptainRumseysLagerBuff()
        end

        if _.isChumBuffDurationShorterThanMaximumFishingDuration() then
          _.buffWithChumBuff()
        end

        Core.castSpellByID(FISHING_SPELL_ID)
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
          if isFishing then
            if Questing.areBagsFull() then
              Quit()
              return
            else
              local waitDurationUntilNextFishing = _.randomFloat(0.5, 1)
              Coroutine.waitForDuration(waitDurationUntilNextFishing)
            end
          else
            return
          end
        end
      end
    end)
  end
end

function _.hours(amount)
  return amount * 60 * 60
end

function _.hasFishingLures()

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
  Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function (self, event, unit)
    return unit == 'player'
  end)
end

function _.isCaptainRumseysLagerBuffDurationShorterThanMaximumFishingDuration()
  return _.isBuffDurationShorterThanMaximumFishingDuration("Captain Rumsey's Lager")
end

function _.buffWithCaptainRumseysLagerBuff()
  _.useBuffItem("Captain Rumsey's Lager")
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

function _.randomFloat(from, to)
  return from + math.random() * (to - from)
end

function Fishing.findFishingBobber()
  return Array.find(Core.retrieveObjectPointers(), function(pointer)
    return HWT.ObjectId(pointer) == FISHING_BOBBER_OBJECT_ID and HWT.GameObjectIsUsable(pointer, false)
  end)
end
