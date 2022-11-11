doWhenGMRIsFullyLoaded(function()
  local thread = coroutine.create(function()
    local yielder = createYielderWithTimeTracking(1 / 60)

    while true do
      if GMR.IsVendoring() and GossipFrame:IsShown() then
        local options = C_GossipInfo.GetOptions()
        local option = Array.find(options, function(option)
          return option.icon == 132060
        end)
        if option then
          C_GossipInfo.SelectOption(option.gossipOptionID)
        end
      end

      yielder.yield()
    end
  end)
  resumeWithShowingError(thread)
end)
