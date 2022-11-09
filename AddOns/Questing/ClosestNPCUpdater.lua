sellVendors = {}

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
    ticker:Cancel()

    function a()
      local yielder = createYielder(1 / 60)

      for NPC in Questing.Database.createNPCsIterator() do
        local continentID, x, y, z = retrieveNPCPosition(NPC)
        if x and y and z then
          if NPC.isGoodsVendor then
          end
          if NPC.isVendor then
            table.insert(sellVendors, { x, y, z, NPC.id })
          end
          if NPC.canRepair then
          end
        end

        if yielder.hasRanOutOfTime() then
          yielder.yield()
        end
      end

      while true do
        if GMR.IsVendoring() and GossipFrame:IsShown() then
          local options = C_GossipInfo.GetOptions()
          local option = Array.find(options, function (option)
            return option.icon == 132060
          end)
          if option then
            C_GossipInfo.SelectOption(option.gossipOptionID)
          end
        end

        local sellVendor = findClosestSellVendor()
        if sellVendor then
          local pointer = GMR.FindObject(sellVendor[4])
          local x, y, z
          if pointer then
            x, y, z = GMR.ObjectPosition(pointer)
          else
            x, y, z = sellVendor[1], sellVendor[2], sellVendor[3]
          end
          GMR.DefineSellVendor(x, y, z, sellVendor[4])
        end
        yielder.yield()
      end
    end

    function findClosestSellVendor()
      return Array.min(sellVendors, function(value)
        return GMR.GetDistanceToPosition(value[1], value[2], value[3])
      end)
    end

    local thread = coroutine.create(a)
    resumeWithShowingError(thread)
  end
end)
