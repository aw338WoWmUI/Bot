local _ = {}

local lastContinentID = nil

local closestNPCs = {
  Goods = nil,
  Sell = nil,
  Repair = nil
}

Q_ = _

function _.updateNPCPositionsToClosest()
  local continentID = select(8, GetInstanceInfo())
  if lastContinentID and continentID ~= lastContinentID then
    for key in pairs(closestNPCs) do
      closestNPCs[key] = nil
      GMR.Tables.Profile.Vendor[key] = nil
    end
  end

  _.updateGoodsVendorToClosest()
  _.updateSellVendorToClosest()
  _.updateRepairerToClosest()

  lastContinentID = continentID
end

function _.updateGoodsVendorToClosest()
  _.updateNPCPositionToClosest(_.findClosestGoodsVendor, function (npc)
    closestNPCs.Goods = npc
    GMR.DefineGoodsVendor(npc.x, npc.y, npc.z, npc.ID)
  end)
end

function _.updateSellVendorToClosest()
  _.updateNPCPositionToClosest(_.findClosestSellVendor, function (npc)
    closestNPCs.Sell = npc
    GMR.DefineSellVendor(npc.x, npc.y, npc.z, npc.ID)
  end)
end

function _.updateRepairerToClosest()
  _.updateNPCPositionToClosest(_.findClosestCanRepairNPC, function (npc)
    closestNPCs.Repair = npc
    GMR.DefineRepairVendor(npc.x, npc.y, npc.z, npc.ID)
  end)
end

function _.updateNPCPositionToClosest(find, update)
  local npc = find()
  if npc then
    update(npc)
  end
end

function _.findClosestGoodsVendor()
  return _.findClosestNPC(_.isGoodsVendor)
end

function _.findClosestSellVendor()
  return _.findClosestNPC(_.isSellVendor)
end

function _.findClosestCanRepairNPC()
  return _.findClosestNPC(_.isRepair)
end

function _.findClosestNPC(matches)
  local objects = retrieveObjects()
  local NPCs = Array.filter(objects, function(object)
    return matches(object)
  end)
  local npc = Array.min(NPCs, function(NPC)
    return GMR.GetDistanceToPosition(NPC.x, NPC.y, NPC.z)
  end)
  if npc then
    npc.continentID = select(8, GetInstanceInfo())
  end
  return npc
end

function _.isGoodsVendor(object)
  return Core.isFoodVendor(object.pointer) and GMR.UnitReaction('player', object.pointer) >= 4
end

function _.isSellVendor(object)
  return Core.isSellVendor(object.pointer) and GMR.UnitReaction('player', object.pointer) >= 4
end

function _.isRepair(object)
  return Core.isRepair(object.pointer) and GMR.UnitReaction('player', object.pointer) >= 4
end

doRegularlyWhenGMRIsFullyLoaded(function()
  _.updateNPCPositionsToClosest()
end)
