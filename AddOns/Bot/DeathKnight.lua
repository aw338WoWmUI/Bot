Bot = Bot or {}

Bot.DeathKnight = {}

local addOnName, AddOn = ...

local _ = {}

function Bot.DeathKnight.castSpell()
  if _.hasCharacterItemWithBreathOfNeltharionEquipped() and _.isBreathOfNeltharionTinkerOffCooldown() and _.areAtLeastTwoMobsInFront() then
    _.castBreathOfNeltharion()
  elseif _G.RecommendedSpellCaster then
    AddOn.castRecommendedSpell()
  elseif _G.GMR and GMR.ClassRotation then
    GMR.ClassRotation()
  end
end

function _.areAtLeastTwoMobsInFront()
  local mobsInFront = _.retrieveMobsInFront()
  return #mobsInFront >= 2
end

function _.retrieveMobsInFront()
  local mobs = Core.receiveMobsThatAreInCombat()
  local MAXIMUM_RANGE = 4
  return Array.filter(mobs, function (mob)
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
  return Array.any(tooltip.lines, function (line)
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
