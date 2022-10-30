C_GossipInfo.GetNumOptions = function ()
  return #C_GossipInfo.GetOptions()
end

local selectOption = C_GossipInfo.SelectOption
C_GossipInfo.SelectOption = function (value, ...)
  local options = C_GossipInfo.GetOptions()
  if value >= 1 and value <= #options then
    local option = options[value]
    return selectOption(option.gossipOptionID, ...)
  else
    return selectOption(value, ...)
  end
end
