Compatibility = Compatibility or {}
Compatibility.Container = {}

function Compatibility.Container.retrieveItemInfo(containerIndex, slotIndex)
  if C_Container.GetContainerItemInfo then
    return C_Container.GetContainerItemInfo(containerIndex, slotIndex)
  else
    return GetContainerItemInfo(containerIndex, slotIndex)
  end
end

function Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex)
  if C_Container.GetContainerNumSlots then
    return C_Container.GetContainerNumSlots(containerIndex)
  else
    return GetContainerNumSlots(containerIndex, slotIndex)
  end
end
