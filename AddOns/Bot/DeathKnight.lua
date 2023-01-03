Bot = Bot or {}

Bot.DeathKnight = {}

local addOnName, AddOn = ...

local _ = {}

local LICHBORNE = 49039
local DEATH_COIL = 47541
local DEATH_STRIKE = 49998

function Bot.DeathKnight.castSpell()
  local characterToResurrect = _.findCharacterToResurrect()
  if _.areConditionsMetForRaiseAlly(characterToResurrect) then
    _.raiseAlly(characterToResurrect)
  elseif _.areConditionsMetForHealing() and (Core.hasCharacterBuff(LICHBORNE) or SpellCasting.canBeCasted(LICHBORNE)) and SpellCasting.canBeCasted(DEATH_COIL) then
    if not Core.hasCharacterBuff(LICHBORNE) then
      SpellCasting.castSpell(LICHBORNE)
    end
    SpellCasting.castSpell(DEATH_COIL, {
      target = 'player'
    })
  elseif _.areConditionsMetForHealing() and SpellCasting.canBeCasted(DEATH_STRIKE) then
    SpellCasting.castSpell(DEATH_STRIKE)
  elseif _.hasCharacterItemWithBreathOfNeltharionEquipped() and _.isBreathOfNeltharionTinkerOffCooldown() and _.areAtLeastTwoMobsInFront() then
    if _.hasCharacterItemWithGroundedCircuitryEquipped() and _.isGroundedCircuitryTinkerOffCooldown() then
      _.castGroundedCircuitry()
    end
    _.castBreathOfNeltharion()
  elseif _G.RecommendedSpellCaster then
    AddOn.castRecommendedSpell()
  elseif _G.GMR and GMR.ClassRotation then
    GMR.ClassRotation()
  end
end

local RAISE_ALLY = 61999

function _.areConditionsMetForRaiseAlly(characterToResurrect)
  return characterToResurrect ~= nil and SpellCasting.canBeCasted(RAISE_ALLY)
end

function _.areConditionsMetForHealing()
  return (UnitHealth('player') / UnitHealthMax('player')) <= 0.5
end

local partyUnitTokens = {
  'party1',
  'party2',
  'party3',
  'party4'
}

function _.findCharacterToResurrect()
  local unitTokens = {}
  if IsInRaid() then
    for index = 1, 40 do
      table.insert(unitTokens, 'raid' .. index)
    end
  elseif UnitInParty('player') then
    Array.append(unitTokens, partyUnitTokens)
  end
  local deadTank = Array.find(unitTokens, function(unitToken)
    return UnitGroupRolesAssigned(unitToken) == 'TANK' and UnitIsDead(unitToken)
  end)
  if deadTank then
    return deadTank
  else
    local deadHealer = Array.find(unitTokens, function(unitToken)
      return UnitGroupRolesAssigned(unitToken) == 'HEALER' and UnitIsDead(unitToken)
    end)
    return deadHealer
  end
end

function _.raiseAlly(characterToResurrect)
  SpellCasting.castSpell(RAISE_ALLY, {
    target = characterToResurrect
  })
end

function _.areAtLeastTwoMobsInFront()
  local mobsInFront = _.retrieveMobsInFront()
  return #mobsInFront >= 2
end

function _.retrieveMobsInFront()
  local mobs = Core.receiveMobsThatAreInCombat()
  local MAXIMUM_RANGE = 4
  return Array.filter(mobs, function(mob)
    return Core.calculateDistanceFromCharacterToObject(mob) <= MAXIMUM_RANGE and
      _.isMobInFront(mob)
  end)
end

function _.isMobInFront(mob)
  local characterPosition = Core.retrieveCharacterPosition()
  local mobPosition = Core.retrieveObjectPosition(mob)
  local characterYaw = HWT.ObjectFacing('player')
  local angleToMob = Core.calculateAnglesBetweenTwoPoints(characterPosition, mobPosition)
  local frontCone = math.rad(40)
  return Core.normalizeAngle(angleToMob - characterYaw) < frontCone / 2
end

function _.hasCharacterItemWithBreathOfNeltharionEquipped()
  local tooltip = C_TooltipInfo.GetInventoryItem('player', INVSLOT_HEAD)
  return Array.any(tooltip.lines, function(line)
    TooltipUtil.SurfaceArgs(line)
    return string.match(line.leftText, '^Use: Reveal a flamethrower')
  end)
end

function _.isBreathOfNeltharionTinkerOffCooldown()
  local start = GetInventoryItemCooldown('player', INVSLOT_HEAD)
  return start == 0
end

function _.castBreathOfNeltharion()
  UseInventoryItem(INVSLOT_HEAD)
end

function _.hasCharacterItemWithGroundedCircuitryEquipped()
  local tooltip = C_TooltipInfo.GetInventoryItem('player', INVSLOT_WRIST)
  return Array.any(tooltip.lines, function(line)
    TooltipUtil.SurfaceArgs(line)
    return string.match(line.leftText, '^Use: Guarantees the next slotted Tinker')
  end)
end

function _.isGroundedCircuitryTinkerOffCooldown()
  local start = GetInventoryItemCooldown('player', INVSLOT_WRIST)
  return start == 0
end

function _.castGroundedCircuitry()
  UseInventoryItem(INVSLOT_WRIST)
end
