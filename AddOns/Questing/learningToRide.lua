local addOnName, AddOn = ...
Questing = Questing or {}

local _ = {}

local APPRENTICE_RIDING = 33388
local APPRENTICE_RIDING_LEVEL_REQUIRED = 10

local JOURNEYMAN_RIDING = 33391
local JOURNEYMAN_RIDING_LEVEL_REQUIRED = 20

local EXPERT_RIDING = 34092
local EXPERT_RIDING_LEVEL_REQUIRED = 30

local MASTER_RIDING = 90265
local MASTER_RIDING_LEVEL_REQUIRED = 40

function Questing.canLearnRiding()
  return (
    Questing.canLearnApprenticeRiding() or
      Questing.canLearnJourneymanRiding() or
      Questing.canLearnExpertRiding() or
      Questing.canLearnMasterRiding()
  )
end

function Questing.canLearnApprenticeRiding()
  return UnitLevel('player') >= APPRENTICE_RIDING_LEVEL_REQUIRED and not IsSpellKnown(APPRENTICE_RIDING) and not IsSpellKnown(JOURNEYMAN_RIDING) and not IsSpellKnown(EXPERT_RIDING) and not IsSpellKnown(MASTER_RIDING) and _.hasEnoughGoldToLearnApprenticeRiding()
end

function Questing.canLearnJourneymanRiding()
  return UnitLevel('player') >= JOURNEYMAN_RIDING_LEVEL_REQUIRED and not IsSpellKnown(JOURNEYMAN_RIDING) and not IsSpellKnown(EXPERT_RIDING) and not IsSpellKnown(MASTER_RIDING) and _.hasEnoughGoldToLearnJourneymanRiding()
end

function Questing.canLearnExpertRiding()
  return UnitLevel('player') >= EXPERT_RIDING_LEVEL_REQUIRED and not IsSpellKnown(EXPERT_RIDING) and not IsSpellKnown(MASTER_RIDING) and _.hasEnoughGoldToLearnExpertRiding()
end

function Questing.canLearnMasterRiding()
  return UnitLevel('player') >= MASTER_RIDING_LEVEL_REQUIRED and not IsSpellKnown(MASTER_RIDING) and _.hasEnoughGoldToLearnMasterRiding()
end

local FACTION_ALLIANCE = 72
local FACTION_OGRIMMAR = 76

local APPRENTICE_RIDING_BASE_COST = 1
local JOURNEYMAN_RIDING_BASE_COST = 50
local EXPERT_RIDING_BASE_COST = 500
local MASTER_RIDING_BASE_COST = 5000

local STANDING = {
  Friendly = 5,
  Honored = 6,
  Revered = 7,
  Exalted = 8
}

local STANDING_DISCOUNTS = {
  [STANDING.Friendly] = 5,
  [STANDING.Honored] = 10,
  [STANDING.Revered] = 15,
  [STANDING.Exalted] = 20
}

function _.hasEnoughGoldToLearnApprenticeRiding()
  return _.hasEnoughGoldToLearnRiding(APPRENTICE_RIDING_BASE_COST)
end

function _.hasEnoughGoldToLearnJourneymanRiding()
  return _.hasEnoughGoldToLearnRiding(JOURNEYMAN_RIDING_BASE_COST)
end

function _.hasEnoughGoldToLearnExpertRiding()
  return _.hasEnoughGoldToLearnRiding(EXPERT_RIDING_BASE_COST)
end

function _.hasEnoughGoldToLearnMasterRiding()
  return _.hasEnoughGoldToLearnRiding(MASTER_RIDING_BASE_COST)
end

function _.hasEnoughGoldToLearnRiding(baseCost)
  local factionID
  local factionName = UnitFactionGroup('player')
  if factionName == 'Alliance' then
    factionID = FACTION_ALLIANCE
  elseif factionName == 'Horde' then
    factionID = FACTION_OGRIMMAR
  end
  local cost = baseCost
  local standing = select(3, GetFactionInfo(factionID))
  local discount = STANDING_DISCOUNTS[standing]
  if discount then
    cost = cost * (1 - discount / 100)
  end
  local availableGold = GetMoney() / 10000
  return availableGold >= cost
end

local FLYING_TRAINERS = {
  Alliance = {
    objectID = 43769,
    position = {
      continentID = 0,
      x = -8845.400390625,
      y = 502.65301513672,
      z = 109.61595916748
    }
  },
  Horde = {
    objectID = 44919,
    position = {
      continentID = 1,
      x = 1799.5400390625,
      y = -4357.08984375,
      z = 102.40349578857
    }
  }
}

function Questing.learnRiding()
  local trainer = FLYING_TRAINERS[UnitFactionGroup('player')]
  Questing.Coroutine.interactWithAt(trainer.position, trainer.objectID)
  if Core.isTrainerFrameShown() then
    SetTrainerServiceTypeFilter('available', 1)
    local unitLevel = UnitLevel('player')
    for index = 1, GetNumTrainerServices() do
      local serviceType = select(2, GetTrainerServiceInfo(index))
      if serviceType == 'available' and GetMoney() >= GetTrainerServiceCost(index) then
        BuyTrainerService(index)
        break
      end
    end
  end
end
