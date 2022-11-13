goodsVendorNPCs = {}
unavailableGoodsVendorNPCs = Set.create()

sellVendors = {}
unavailableSellVendors = Set.create()

canRepairNPCs = {}
unavailableRepairNPCs = Set.create()

gryphonMasters = {}
unavailableGryphonMasters = Set.create()

function resetSelling()
  if GMR.IsExecuting() and GMR_SavedVariablesPerCharacter.Sell then
    GMR.Stop()
    GMR.DefineSetting('Disable', 'Sell')
    GMR.Execute()
    C_Timer.After(1, function ()
      GMR.DefineSetting('Enable', 'Sell')
    end)
  end
end

doWhenGMRIsFullyLoaded(function()
  function a()
    local yielder = createYielderWithTimeTracking(1 / 60)

    for NPC in Questing.Database.createNPCsIterator() do
      local continentID, x, y, z = retrieveNPCPosition(NPC)
      if continentID and x and y and z then
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
        end
      end

      if yielder.hasRanOutOfTime() then
        yielder.yield()
      end
    end

    Array.forEach(flightMasterNPCIDs, function(id)
      local NPC = Questing.Database.retrieveNPC(id)
      if NPC then
        local continentID, x, y, z = retrieveNPCPosition(NPC)
        if continentID and x and y and z then
          local entry = { continentID, x, y, z, NPC.id }
          table.insert(gryphonMasters, entry)
        end
      end
    end)

    if yielder.hasRanOutOfTime() then
      yielder.yield()
    end

    while true do
      local npcID = GMR.ObjectId('npc')
      if npcID then
        if GossipFrame:IsShown() then
          local options = C_GossipInfo.GetOptions()
          if #options == 0 then
            local npc = Questing.Database.retrieveNPC(npcID)
            if npc then
              if npc.isVendor and not unavailableSellVendors[npcID] then
                unavailableSellVendors[npcID] = true
                resetSelling()
              end
              if npc.isGoodsVendor then
                unavailableGoodsVendorNPCs[npcID] = true
              end
              if npc.canRepair then
                unavailableRepairNPCs[npcID] = true
              end
            end
          end
        end
      end

      updateNPCPositionsToClosest()

      yielder.yield()
    end
  end

  function updateNPCPositionsToClosest()
    updateGoodsVendorToClosest()
    updateSellVendorToClosest()
    updateRepairerToClosest()
    -- updateGryphonMasterToClosest()
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
    return findClosestNPC(goodsVendorNPCs, unavailableGoodsVendorNPCs)
  end

  function findClosestSellVendor()
    return findClosestNPC(sellVendors, unavailableSellVendors)
  end

  function findClosestCanRepairNPC()
    return findClosestNPC(canRepairNPCs, unavailableRepairNPCs)
  end

  function findClosestGryphonMaster()
    return findClosestNPC(gryphonMasters, unavailableGryphonMasters)
  end

  function findClosestNPC(NPCs, npcIdsFromWhichTheFunctionIsUnavailable)
    local continentID = select(8, GetInstanceInfo())
    return Array.min(Array.filter(NPCs, function(npc)
      return npc[1] == continentID and not Set.contains(npcIdsFromWhichTheFunctionIsUnavailable, npc[5])
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
