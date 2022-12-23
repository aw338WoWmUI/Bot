Compatibility = Compatibility or {}
Compatibility.Container = {}

function Compatibility.Container.retrieveItemInfo(containerIndex, slotIndex)
  if _G.C_Container and C_Container.GetContainerItemInfo then
    return C_Container.GetContainerItemInfo(containerIndex, slotIndex)
  else
    local iconFileID, stackCount, isLocked, quality, isReadable, hasLoot, hyperlink, isFiltered, hasNoValue, itemID, isBound = GetContainerItemInfo(containerIndex,
      slotIndex)
    local itemInfo = {
      iconFileID = iconFileID,
      stackCount = stackCount,
      isLocked = isLocked,
      quality = quality,
      isReadable = isReadable,
      hasLoot = hasLoot,
      hyperlink = hyperlink,
      isFiltered = isFiltered,
      hasNoValue = hasNoValue,
      itemID = itemID,
      isBound = isBound
    }
    return itemInfo
  end
end

function Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex)
  if _G.C_Container and C_Container.GetContainerNumSlots then
    return C_Container.GetContainerNumSlots(containerIndex)
  else
    return GetContainerNumSlots(containerIndex)
  end
end

function Compatibility.Container.UseContainerItem(containerIndex, slotIndex, unitToken, reagentBankOpen)
  if _G.C_Container and C_Container.UseContainerItem then
    return C_Container.UseContainerItem(containerIndex, slotIndex, unitToken, reagentBankOpen)
  else
    return UseContainerItem(containerIndex, slotIndex, unitToken, reagentBankOpen)
  end
end

function Compatibility.Container.receiveNumberOfFreeSlotsInContainer(containerIndex)
  if _G.C_Container and C_Container.GetContainerNumFreeSlots then
    return C_Container.GetContainerNumFreeSlots(containerIndex)
  else
    return GetContainerNumFreeSlots(containerIndex)
  end
end
