goodsVendorNPCs = {}
sellVendors = {}
canRepairNPCs = {}
gryphonMasters = {}

doWhenGMRIsFullyLoaded(function()
  function a()
    local yielder = createYielderWithTimeTracking(1 / 60)

    for NPC in Questing.Database.createNPCsIterator() do
      local continentID, x, y, z = retrieveNPCPosition(NPC)
      if x and y and z then
        if NPC.isGoodsVendor or NPC.isVendor or NPC.canRepair then
          local entry = { continentID, x, y, z, NPC.id }
          if NPC.isGoodsVendor then
            table.insert(goodsVendorNPCs, entry)
          end
          if NPC.isVendor then
            table.insert(sellVendors, entry)
          end
          if NPC.canRepair then
            table.insert(canRepairNPCs, entry)
          end
          if NPC.isGryphonMaster then
            table.insert(gryphonMasters, entry)
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
    local npc = findClosestSellVendor()
    if npc then
      local position = determineObjectPosition(
        npc[5],
        createPoint(npc[2], npc[3], npc[4])
      )
      GMR.LibDraw.SetColorRaw(1, 0, 0, 1)
      GMR.LibDraw.Circle(position.x, position.y, position.z, 0.75)
    end
    updateGoodsVendorToClosest()
    updateSellVendorToClosest()
    updateRepairerToClosest()
    updateGryphonMasterToClosest()
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

  function updateGryphonMasterToClosest()
    updateNPCPositionToClosest(findClosestGryphonMaster, GMR.DefineGryphonMaster)
  end

  function updateNPCPositionToClosest(find, update)
    local npc = find()
    if npc then
      local position = determineObjectPosition(
        npc[5],
        createPoint(npc[2], npc[3], npc[4])
      )
      update(position.x, position.y, position.z, npc[5])
    end
  end

  function findClosestGoodsVendor()
    return findClosestNPC(goodsVendorNPCs)
  end

  function findClosestSellVendor()
    return findClosestNPC(sellVendors)
  end

  function findClosestCanRepairNPC()
    return findClosestNPC(canRepairNPCs)
  end

  function findClosestGryphonMaster()
    return findClosestNPC(gryphonMasters)
  end

  function findClosestNPC(NPCs)
    local continentID = select(8, GetInstanceInfo())
    return Array.min(Array.filter(NPCs, function(npc)
      return npc[1] == continentID
    end), function(value)
      return GMR.GetDistanceToPosition(value[2], value[3], value[4])
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
