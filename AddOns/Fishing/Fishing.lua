--- Usage: /script Fishing.fish()
--- `/reload` to stop the script.

local addOnName, AddOn = ...
PackageInitialization.initializePackage(addOnName)
local _ = {}

local FISHING_SPELL_ID = 131474
local FISHING_BOBBER_OBJECT_ID = 35591

function fish()
  Coroutine.runAsCoroutine(function()
    while true do
      Core.castSpellByID(FISHING_SPELL_ID)
      HWT.ResetAfk()
      Coroutine.waitForDuration(1)
      local fishingBobber = findFishingBobber()
      local hasSomethingBitten = Coroutine.waitFor(function ()
        return HWT.ObjectAnimationState(fishingBobber) == 1
      end, 30)
      if hasSomethingBitten then
        local waitDurationBeforeInteractingWithBobber = _.randomFloat(0.2, 1)
        Coroutine.waitForDuration(waitDurationBeforeInteractingWithBobber)
        Core.interactWithObject(fishingBobber)
        HWT.ResetAfk()
      end
      local waitDurationUntilNextFishing = _.randomFloat(0.5, 1)
      Coroutine.waitForDuration(waitDurationUntilNextFishing)
    end
  end)
end

function _.randomFloat(from, to)
  return from + math.random() * (to - from)
end

function findFishingBobber()
  return Array.find(Core.retrieveObjectPointers(), function(pointer)
    return HWT.ObjectId(pointer) == FISHING_BOBBER_OBJECT_ID and HWT.GameObjectIsUsable(pointer, false)
  end)
end
