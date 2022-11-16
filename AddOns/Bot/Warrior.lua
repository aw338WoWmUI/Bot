Bot = Bot or {}
Bot.Warrior = {}
local _ = {}

local HEROIC_STRIKE = 78
local BATTLE_SHOUT = 6673
local REND = 772
local CHARGE = 100

local HEROIC_STRIKE_NAME = GetSpellInfo(HEROIC_STRIKE)
local REND_NAME = GetSpellInfo(REND)

function Bot.Warrior.castSpell()
  if _.areConditionsMetToCastCharge() then
    print('cast charge')
    CastSpellByID(CHARGE)
  elseif _.areConditionsMetToCastBattleShout() then
    print('cast battle shout')
    CastSpellByID(BATTLE_SHOUT)
  elseif _.areConditionsMetToCastRend() then
    print('cast rend')
    CastSpellByID(REND)
  elseif _.areConditionsMetToCastHeroicStrike() then
    print('cast heroic strike')
    CastSpellByID(HEROIC_STRIKE)
  end
end

local function IDPredicate(spellIDToFind, _, _, _, _, _, _, _, _, _, _, _, spellID)
  return spellID == spellIDToFind
end

function _.retrievePlayerAuraBySpellID(spellID)
  return _.findAuraByID(spellID, 'player')
end

function _.findAuraByID(spellID, unit, filter)
  return AuraUtil.FindAura(IDPredicate, unit, filter, spellID)
end

function _.canBeCasted(spellId)
  return (
    IsUsableSpell(spellId) and
      GetSpellCooldown(spellId) == 0
  )
end

function _.areConditionsMetToCastCharge()
  return _.canBeCasted(CHARGE) and
    IsSpellInRange(CHARGE, 'target')
end

function _.areConditionsMetToCastBattleShout()
  local hasBattleShoutBuff = toBoolean(_.retrievePlayerAuraBySpellID(BATTLE_SHOUT))
  return (
    not hasBattleShoutBuff and _.canBeCasted(BATTLE_SHOUT)
  )
end

function _.areConditionsMetToCastRend()
  return (
    _.canBeCasted(REND) and
      IsSpellInRange(REND_NAME, 'target') and
      not _.findAuraByID(REND, 'target', 'HARMFUL')
  )
end

function _.areConditionsMetToCastHeroicStrike()
  local lowDamage = UnitDamage('player')
  local targetHealth = UnitHealth('target')
  return (
    not IsCurrentSpell(HEROIC_STRIKE) and
      _.canBeCasted(HEROIC_STRIKE) and
      IsSpellInRange(HEROIC_STRIKE_NAME, 'target') and
      targetHealth > lowDamage
  )
end
