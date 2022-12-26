Bot = Bot or {}

Bot.DeathKnight = {}

local addOnName, AddOn = ...

local _ = {}

function Bot.DeathKnight.castSpell()
  local characterToResurrect = _.findCharacterToResurrect()
  if _.areConditionsMetForRaiseAlly(characterToResurrect) then
    _.raiseAlly(characterToResurrect)
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
  return SpellCasting.canBeCasted(RAISE_ALLY) and characterToResurrect ~= nil
end

function _.isCharacterToResurrectDead()
  return _.findCharacterToResurrect() ~= nil
end

local unitTokens = {
  'party1',
  'party2',
  'party3',
  'party4'
}

function _.findCharacterToResurrect()
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
  SpellCasting.castSpellByID(RAISE_ALLY, {
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
