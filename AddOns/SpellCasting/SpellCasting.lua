SpellCasting = SpellCasting or {}
local addOnName, AddOn = ...
local _ = {}

function SpellCasting.useContainerItem(containerIndex, slotIndex, target, isReagentBankAccessible)
  Compatibility.Container.UseContainerItem(containerIndex, slotIndex, target, isReagentBankAccessible)
end

function SpellCasting.waitForSpellCastSucceeded(spellID)
  Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function(self, event, unit, __, eventSpellID)
    return unit == 'player' and eventSpellID == spellID
  end)
end

function SpellCasting.waitForEmpoweredSpellCastStart(spellID)
  return Events.waitForEventCondition('UNIT_SPELLCAST_EMPOWER_START', function(self, event, unit, __, eventSpellID)
    return unit == 'player' and eventSpellID == spellID
  end, 0.5)
end

function SpellCasting.castSpellByID(spellID, options)
  options = options or {}

  local name = GetSpellInfo(spellID)
  CastSpellByName(name)
  if options.empowermentLevel and IsPressHoldReleaseSpell(spellID) then
    if SpellCasting.waitForEmpoweredSpellCastStart(spellID) then
      SpellCasting.releaseWhenSpellHasBeenEmpowerTo(spellID, options.empowermentLevel)
    end
  end
end

function SpellCasting.releaseWhenSpellHasBeenEmpowerTo(spellID, empowermentLevel)
  local holdDuration = 0
  for index = 0, empowermentLevel - 1 do
    holdDuration = holdDuration + GetUnitEmpowerStageDuration('player', index)
  end

  local channelStartTime = select(4, UnitChannelInfo('player'))
  if channelStartTime then
    local durationAlreadyCasted = math.max(GetTime() - channelStartTime, 0)
    holdDuration = holdDuration - durationAlreadyCasted
  end

  holdDuration = holdDuration / 1000

  local function release()
    local slots = C_ActionBar.FindSpellActionButtons(spellID)
    if Array.hasElements(slots) then
      ReleaseAction(slots[1])
    end
  end

  if holdDuration == 0 then
    release()
  else
    Resolvable.await(Resolvable.Resolvable:new(function(resolve)
      local spellCastEmpowerStopListener

      local releaseActionTimer = C_Timer.NewTimer(holdDuration, function()
        release()
        spellCastEmpowerStopListener:stopListening()
        resolve()
      end)

      spellCastEmpowerStopListener = Events.listenForEvent('UNIT_SPELLCAST_EMPOWER_STOP', function(event, unit)
        if unit == 'player' then
          releaseActionTimer:Cancel()
          spellCastEmpowerStopListener:stopListening()
          resolve()
        end
      end)
    end))
  end
end
