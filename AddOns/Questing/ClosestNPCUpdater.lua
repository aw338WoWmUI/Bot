local _ = {}

Q_ = _

function _.updateNPCPositionsToClosest()
  _.updateGoodsVendorToClosest()
  _.updateSellVendorToClosest()
  _.updateRepairerToClosest()
end

function _.updateGoodsVendorToClosest()
  _.updateNPCPositionToClosest(_.findClosestGoodsVendor, GMR.DefineGoodsVendor)
end

function _.updateSellVendorToClosest()
  _.updateNPCPositionToClosest(_.findClosestSellVendor, GMR.DefineSellVendor)
end

function _.updateRepairerToClosest()
  _.updateNPCPositionToClosest(_.findClosestCanRepairNPC, GMR.DefineRepairVendor)
end

function _.updateNPCPositionToClosest(find, update)
  local npc = find()
  if npc then
    update(npc.x, npc.y, npc.z, npc.ID)
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
