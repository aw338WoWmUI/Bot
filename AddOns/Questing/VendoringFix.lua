doRegularlyWhenGMRIsFullyLoaded(function()
  if GMR.IsVendoring() and GossipFrame:IsShown() then
    local options = C_GossipInfo.GetOptions()
    local option = Array.find(options, function(option)
      return option.icon == 132060
    end)
    if option then
      C_GossipInfo.SelectOption(option.gossipOptionID)
    end
  end
end)
