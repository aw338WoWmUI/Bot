AutoCombat = AutoCombat or {}
local addOnName, AddOn = ...
local _ = {}

local isEnabled = false
local isRunning = false

function AutoCombat.toggle()
  if isEnabled then
    AutoCombat.disable()
  else
    AutoCombat.enable()
  end
end

local HUNTING_COMPANION = 376280

function AutoCombat.enable()
  Coroutine.runAsCoroutine(function()
    if not isEnabled then
      print('Starting auto combat.')
      isEnabled = true
      _.waitForHasStopped()
      isRunning = true
      while isEnabled do
        -- TODO: Probably only works in Ohn'Ahran Plains
        --if IsOutdoors() and SpellCasting.canBeCasted(HUNTING_COMPANION) and not Core.hasCharacterBuff(HUNTING_COMPANION) then
        --  SpellCasting.castSpell(HUNTING_COMPANION)
        --end
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
      isRunning = false
    end
  end)
end

function AutoCombat.disable()
  Coroutine.runAsCoroutine(function()
    if isEnabled then
      print('Stopping auto combat.')
      isEnabled = false
      _.waitForHasStopped()
    end
  end)
end

function AutoCombat.castManually(spellName)
  Coroutine.runAsCoroutine(function()
    if SpellCasting.retrieveRemainingSpellCooldown(spellName) <= 2 then
      local wasAutoCombatEnabledBeforeCasting = isEnabled
      if isEnabled then
        AutoCombat.disable()
      end
      _.waitForHasStopped()
      SpellCasting.waitForSpellToBeReadyForCast(spellName)
      CastSpellByName(spellName)
      if wasAutoCombatEnabledBeforeCasting then
        Coroutine.waitFor(function()
          return not HWT.IsAoEPending()
        end)
        AutoCombat.enable()
      end
    end
  end)
end

function _.targetMob()
  local mobs = Core.receiveMobsThatAreInCombat()
  local mob = Array.min(mobs, function(mob)
    return UnitHealth(mob)
  end)
  if mob then
    Core.targetUnit(mob)
  end
end

function _.waitForHasStopped()
  Coroutine.waitFor(function()
    return not isRunning
  end)
end
