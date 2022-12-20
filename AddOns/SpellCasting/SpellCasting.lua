SpellCasting = SpellCasting or {}
local addOnName, AddOn = ...
local _ = {}

function SpellCasting.useContainerItem(containerIndex, slotIndex, target, isReagentBankAccessible)
  Compatibility.Container.UseContainerItem(containerIndex, slotIndex, target, isReagentBankAccessible)
end

function SpellCasting.waitForSpellCastSucceeded(spellID)
	Events.waitForEventCondition('UNIT_SPELLCAST_SUCCEEDED', function (self, event, unit, __, eventSpellID)
    return unit == 'player' and eventSpellID == spellID
  end)
end
