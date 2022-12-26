AutoCombat = AutoCombat or {}
local addOnName, AddOn = ...
local _ = {}

local isRunning = false

function AutoCombat.toggle()
  if not isRunning then
    AutoCombat.enable()
  else
    AutoCombat.disable()
  end
end

function AutoCombat.enable()
  Coroutine.runAsCoroutine(function()
    if not isRunning then
      print('Starting auto combat.')
      isRunning = true
      while isRunning do
        if Core.isCharacterInCombat() and not Core.isAlive('target') then
          _.targetMob()
        end
        if Core.isCharacterInCombat() and Core.isAlive('target') then
          Core.startAttacking()
          Bot.castCombatRotationSpell()
        else
          local lootableMob = Array.find(Core.retrieveObjectPointers(), function(pointer)
            return Core.isLootable(pointer) and Core.isInInteractionRange(pointer)
          end)
          if lootableMob then
            Core.interactWithObject(lootableMob)
            Events.waitForEvent('LOOT_CLOSED', 3)
            Coroutine.waitForDuration(0.2)
          end
        end

        Coroutine.yieldAndResume()
      end
    end
  end)
end

function AutoCombat.disable()
  Coroutine.runAsCoroutine(function()
    if isRunning then
      print('Stopping auto combat.')
      isRunning = false
    end
  end)
end

function AutoCombat.castManually(spellName)
  Coroutine.runAsCoroutine(function()
    local wasAutoCombatEnabledBeforeCasting = isRunning
    if isRunning then
      AutoCombat.disable()
    end
    CastSpellByName(spellName)
    if wasAutoCombatEnabledBeforeCasting then
      Coroutine.waitFor(function ()
        return not HWT.IsAoEPending()
      end)
      AutoCombat.enable()
    end
  end)
end

function _.targetMob()
  local mobs = Core.receiveMobsThatAreInCombat()
  local mob = Array.min(mobs, function(mob)
    return Core.calculateDistanceFromCharacterToObject(mob)
  end)
  if mob then
    Core.targetUnit(mob)
  end
end
