goodsVendorNPCs = {}
sellVendors = {}
canRepairNPCs = {}

doWhenGMRIsFullyLoaded(function()
  function a()
    local yielder = createYielderWithTimeTracking(1 / 60)

    for NPC in Questing.Database.createNPCsIterator() do
      local continentID, x, y, z = retrieveNPCPosition(NPC)
      if x and y and z then
        if NPC.isGoodsVendor or NPC.isVendor or NPC.canRepair then
          local entry = { x, y, z, NPC.id }
          if NPC.isGoodsVendor then
            table.insert(goodsVendorNPCs, entry)
          end
          if NPC.isVendor then
            table.insert(sellVendors, entry)
          end
          if NPC.canRepair then
            table.insert(canRepairNPCs, entry)
          end
        end
      end

      if yielder.hasRanOutOfTime() then
        yielder.yield()
      end
    end

    while true do
      updateNPCPositionsToClosest()

      yielder.yield()
    end
  end

  function updateNPCPositionsToClosest()
    updateGoodsVendorToClosest()
    updateSellVendorToClosest()
    updateRepairerToClosest()
  end

  function updateGoodsVendorToClosest()
    updateNPCPositionToClosest(findClosestGoodsVendor, GMR.DefineGoodsVendor)
  end

  function updateSellVendorToClosest()
    updateNPCPositionToClosest(findClosestSellVendor, GMR.DefineSellVendor)
  end

  function updateRepairerToClosest()
    updateNPCPositionToClosest(findClosestCanRepairNPC, GMR.DefineRepairVendor)
  end

  function updateNPCPositionToClosest(find, update)
    local npc = find()
    if npc then
      local position = determineObjectPosition(
        npc[4],
        createPoint(npc[1], npc[2], npc[3])
      )
      update(position.x, position.y, position.z, npc[4])
    end
  end

  function findClosestGoodsVendor()
    return Array.min(goodsVendorNPCs, function(value)
      return GMR.GetDistanceToPosition(value[1], value[2], value[3])
    end)
  end

  function findClosestSellVendor()
    return Array.min(sellVendors, function(value)
      return GMR.GetDistanceToPosition(value[1], value[2], value[3])
    end)
  end

  function findClosestCanRepairNPC()
    return Array.min(canRepairNPCs, function(value)
      return GMR.GetDistanceToPosition(value[1], value[2], value[3])
    end)
  end

  function determineObjectPosition(objectID, fallbackPosition)
    local pointer = GMR.FindObject(objectID)
    local position
    if pointer then
      position = createPoint(GMR.ObjectPosition(pointer))
    else
      position = fallbackPosition
    end
    return position
  end

  local thread = coroutine.create(a)
  resumeWithShowingError(thread)
end)
