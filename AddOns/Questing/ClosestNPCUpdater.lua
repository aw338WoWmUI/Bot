local addOnName, AddOn = ...
Questing = Questing or {}

local _ = {}

local unavailableGoodsVendorNPCs = Set.create()
local unavailableSellVendors = Set.create()
local unavailableRepairNPCs = Set.create()

local lastContinentID = nil

local closestNPCs = {
  Goods = nil,
  Sell = nil,
  Repair = nil
}

Questing.closestNPCs = closestNPCs

Q_ = _

function _.updateNPCPositionsToClosest()
  local continentID = Core.retrieveCurrentContinentID()
  if lastContinentID and continentID ~= lastContinentID then
    for key in pairs(closestNPCs) do
      closestNPCs[key] = nil
    end
  end

  _.updateGoodsVendorToClosest()
  _.updateSellVendorToClosest()
  _.updateRepairerToClosest()

  lastContinentID = continentID
end

function _.updateGoodsVendorToClosest()
  _.updateNPCPositionToClosest(_.findClosestGoodsVendor, function(npc)
    closestNPCs.Goods = npc
  end)
end

function _.updateSellVendorToClosest()
  _.updateNPCPositionToClosest(_.findClosestSellVendor, function(npc)
    closestNPCs.Sell = npc
  end)
end

function _.updateRepairerToClosest()
  _.updateNPCPositionToClosest(_.findClosestCanRepairNPC, function(npc)
    closestNPCs.Repair = npc
  end)
end

function _.updateNPCPositionToClosest(find, update)
  local npc = find()
  if npc then
    update(npc)
  end
end

function _.findClosestGoodsVendor()
  return _.findClosestNPC(_.isGoodsVendor, AddOn.savedVariables.perCharacter.QuestingGoodsVendorNPCs)
end

function _.findClosestSellVendor()
  return _.findClosestNPC(_.isSellVendor, AddOn.savedVariables.perCharacter.QuestingSellVendors)
end

function _.findClosestCanRepairNPC()
  return _.findClosestNPC(_.isRepair, AddOn.savedVariables.perCharacter.QuestingRepairerNPCs)
end

function _.findClosestNPC(matches, fallbackList)
  local objects = Core.retrieveObjects()
  local NPCs = Array.filter(objects, function(object)
    return matches(object)
  end)
  if Array.isEmpty(NPCs) then
    local continentID = Movement.retrieveContinentID()
    NPCs = Array.filter(fallbackList, function(NPC)
      return NPC.continentID == continentID
    end)
  end
  local npc = Array.min(NPCs, function(NPC)
    return Core.calculateDistanceFromCharacterToPosition(NPC)
  end)
  if npc and not npc.continentID then
    npc.continentID = Core.retrieveCurrentContinentID()
  end
  return npc
end

function _.isGoodsVendor(object)
  return Core.isFoodVendor(object.pointer) and Core.unitReaction('player', object.pointer) >= 4
end

function _.isSellVendor(object)
  return Core.isSellVendor(object.pointer) and Core.unitReaction('player', object.pointer) >= 4
end

function _.isRepair(object)
  return Core.isRepair(object.pointer) and Core.unitReaction('player', object.pointer) >= 4
end

function _.buildNPCsLookupTables()
  AddOn.savedVariables.perCharacter.QuestingGoodsVendorNPCs = {}
  AddOn.savedVariables.perCharacter.QuestingSellVendors = {}
  AddOn.savedVariables.perCharacter.QuestingRepairerNPCs = {}

  --print('Building NPC lookup tables...')
  --local yielder = Yielder.createYielderWithTimeTracking(1 / 60)
  --
  --for NPC in Questing.Database.createNPCsIterator() do
  --  local position = retrieveNPCPosition(NPC)
  --  if position then
  --    if NPC.isGoodsVendor or NPC.isVendor or NPC.canRepair then
  --      local entry = {
  --        objectID = NPC.id,
  --        continentID = position.continentID,
  --        x = position.x,
  --        y = position.y,
  --        z = position.z
  --      }
  --      if NPC.isGoodsVendor then
  --        table.insert(AddOn.savedVariables.perCharacter.QuestingGoodsVendorNPCs, entry)
  --      end
  --      if NPC.isVendor then
  --        table.insert(AddOn.savedVariables.perCharacter.QuestingSellVendors, entry)
  --      end
  --      if NPC.canRepair then
  --        table.insert(AddOn.savedVariables.perCharacter.QuestingRepairerNPCs, entry)
  --      end
  --    end
  --  end
  --
  --  if yielder.hasRanOutOfTime() then
  --    yielder.yield()
  --  end
  --end
  --
  --print('buildNPCsLookupTables ---')
end

HWT.doWhenHWTIsLoaded(function()
  if not AddOn.savedVariables.perCharacter.QuestingGoodsVendorNPCs or not AddOn.savedVariables.perCharacter.QuestingSellVendors or not AddOn.savedVariables.perCharacter.QuestingRepairerNPCs then
    _.buildNPCsLookupTables()
  end

  _.updateNPCPositionsToClosest()
end)
