Bot = Bot or {}

function Bot.isCharacterInCombat()
  return UnitAffectingCombat('player')
end

function printAuras()
  AuraUtil.ForEachAura('player', 'HELPFUL', nil, function (...)
    print('aura', ...)
  end)
end
