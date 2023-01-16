Bot = Bot or {}

Bot.DeathKnight = {}

local addOnName, AddOn = ...

local _ = {}

local LICHBORNE = 49039
local DEATH_COIL = 47541
local DEATH_STRIKE = 49998

local IDs = Set.create({
  194524,
  197008,
  189843
})

function Bot.DeathKnight.castSpell()
  if IDs:contains(HWT.ObjectId('target')) and UnitHealth('target') <= 75000 then
    Core.useItemByID(199414, 'target')
    if Core.canStaticPopup1Button1BePressed() then
      StaticPopup1Button1:Click()
    end
  else
    _.doFirstOfWhichConditionsAreMet({
      _.conditionallyUseDelicateSuspensionOfSpores,
      function()
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

        return true
      end
    })
  end
end

function _.doFirstOfWhichConditionsAreMet(functions)
  for __, fn in ipairs(functions) do
    local wereConditionsMet = fn()
    if wereConditionsMet then
      return
    end
  end
end

local RAISE_ALLY = 61999

function _.areConditionsMetForRaiseAlly(characterToResurrect)
  return characterToResurrect ~= nil and SpellCasting.canBeCasted(RAISE_ALLY, characterToResurrect)
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
  local unitTokens = _.retrieveUnitTokens()

  local deadTanks = Array.filter(unitTokens, function(unitToken)
    return UnitGroupRolesAssigned(unitToken) == 'TANK' and UnitIsDead(unitToken)
  end)
  if #deadTanks >= 1 then
    local deadTanksThatResurrectCanBeCastedOn = Array.filter(deadTanks, function(deadTank)
      return SpellCasting.isSpellInRange(RAISE_ALLY, deadTank)
    end)
    if #deadTanksThatResurrectCanBeCastedOn >= 1 then
      return deadTanksThatResurrectCanBeCastedOn[1]
    else
      return nil
    end
  else
    local deadHealers = Array.filter(unitTokens, function(unitToken)
      return UnitGroupRolesAssigned(unitToken) == 'HEALER' and UnitIsDead(unitToken)
    end)
    if #deadHealers >= 1 then
      local deadHealersThatResurrectCanBeCastedOn = Array.filter(deadHealers, function(deadHealer)
        return SpellCasting.isSpellInRange(RAISE_ALLY, deadHealer)
      end)
      if #deadHealersThatResurrectCanBeCastedOn >= 1 then
        return deadHealersThatResurrectCanBeCastedOn[1]
      else
        return nil
      end
    end
  end

  return nil
end

function _.raiseAlly(characterToResurrect)
  SpellCasting.castSpell(RAISE_ALLY, {
    target = characterToResurrect
  })
end

local DELICATE_SUSPENSION_OF_SPORES = 191377
local DELICATE_SUSPENSION_OF_SPORES_RANGE = 10
local DELICATE_SUSPENSION_OF_SPORES_HEALING = 36351

function _.conditionallyUseDelicateSuspensionOfSpores()
  if C_Container.GetItemCooldown(DELICATE_SUSPENSION_OF_SPORES) == 0 then
    local containerIndex, slotIndex = Bags.findItem(DELICATE_SUSPENSION_OF_SPORES)
    if containerIndex and slotIndex then
      local characterToUseDelicateSuspensionOfSporesOn = _.findCharacterToUseDelicateSuspensionOfSporesOn()
      if characterToUseDelicateSuspensionOfSporesOn then
        SpellCasting.useContainerItem(containerIndex, slotIndex, characterToUseDelicateSuspensionOfSporesOn)
        return true
      end
    end
  end

  return false
end

function _.areConditionsMetForDelicateSuspensionOfSpores(characterToUseDelicateSuspensionOfSporesOn)
  return (
    Bags.hasItem(DELICATE_SUSPENSION_OF_SPORES) and
      C_Container.GetItemCooldown(DELICATE_SUSPENSION_OF_SPORES) == 0 and
      Boolean.toBoolean(characterToUseDelicateSuspensionOfSporesOn)
  )
end

function _.findCharacterToUseDelicateSuspensionOfSporesOn()
  local unitTokens = _.retrieveUnitTokensIncludingPlayer()

  local deadCharacters = Array.filter(unitTokens, function(unitToken)
    return UnitIsDead(unitToken)
  end)

  local deadCharactersInRange = Array.filter(deadCharacters, function(unitToken)
    SpellCasting.isSpellInRange(DELICATE_SUSPENSION_OF_SPORES, unitToken)
  end)

  local estimatedHealing = Array.map(deadCharactersInRange, function(unitToken)
    return {
      unitToken = unitToken,
      estimatedHealing = _.estimateHealing(unitToken)
    }
  end)

  local best = Array.max(estimatedHealing, function(object)
    return object.estimatedHealing
  end)

  if best and best.estimatedHealing >= 2 * DELICATE_SUSPENSION_OF_SPORES_HEALING then
    return best.unitToken
  else
    return nil
  end
end

function _.retrieveUnitTokens()
  local unitTokens = {}
  if IsInRaid() then
    for index = 1, 40 do
      table.insert(unitTokens, 'raid' .. index)
    end
  elseif UnitInParty('player') then
    Array.append(unitTokens, partyUnitTokens)
  end
  return unitTokens
end

function _.retrieveUnitTokensIncludingPlayer()
	return Array.concat({'player'}, _.retrieveUnitTokens())
end

function _.estimateHealing(unitToken)
  local unitTokens = _.retrieveUnitTokens()

  local unitPosition = Core.retrieveObjectPosition(unitToken)
  local closeByCharacterThatCanBeHealed = Array.filter(unitTokens, function(unitToken)
    return (
      Core.isAlive(unitToken) and
        Core.calculateDistanceBetweenPositions(unitPosition,
          Core.retrieveObjectPosition(unitToken) <= DELICATE_SUSPENSION_OF_SPORES_RANGE)
    )
  end)

  local estimatedHealing = Math.sum(Array.map(closeByCharacterThatCanBeHealed, function(unitToken)
    return Math.min(UnitHealthMax(unitToken) - UnitHealth(unitToken), DELICATE_SUSPENSION_OF_SPORES_HEALING)
  end))

  return estimatedHealing
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
