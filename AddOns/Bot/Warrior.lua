local addOnName, AddOn = ...
Bot = Bot or {}

Bot.Warrior = {}

local _ = {}

local function retrieveHighestRankSpellID(spellID)
  local name = GetSpellInfo(spellID)
  local highestRankSpellID = select(7, GetSpellInfo(name))
  return highestRankSpellID
end

local HEROIC_STRIKE_RANK_1 = 78
local BATTLE_SHOUT_RANK_1 = 6673
local REND_RANK_1 = 772
local CHARGE_RANK_1 = 100
local VICTORY_RUSH_RANK_1 = 34428

local HEROIC_STRIKE = retrieveHighestRankSpellID(HEROIC_STRIKE_RANK_1)
local BATTLE_SHOUT = retrieveHighestRankSpellID(BATTLE_SHOUT_RANK_1)
local REND = retrieveHighestRankSpellID(REND_RANK_1)
local CHARGE = retrieveHighestRankSpellID(CHARGE_RANK_1)
local VICTORY_RUSH = retrieveHighestRankSpellID(VICTORY_RUSH_RANK_1)

local HEROIC_STRIKE_NAME = GetSpellInfo(HEROIC_STRIKE)
local REND_NAME = GetSpellInfo(REND)

function Bot.Warrior.castSpell()
  if _.areConditionsMetToCastVictoryRush() then
    CastSpellByID(VICTORY_RUSH)
  elseif _G.RecommendedSpellCaster then
    RecommendedSpellCaster.castRecommendedSpell()
  end
end

function _.areConditionsMetToCastVictoryRush()
  local characterHealthInPercent = UnitHealth('player') / UnitHealthMax('player')
  return (
    _.canBeCasted(VICTORY_RUSH) and
    characterHealthInPercent <= 0.8
  )
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
  local hasBattleShoutBuff = Boolean.toBoolean(_.retrievePlayerAuraBySpellID(BATTLE_SHOUT))
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
