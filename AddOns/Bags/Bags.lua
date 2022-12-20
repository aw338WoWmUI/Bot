Bags = Bags or {}
local addOnName, AddOn = ...
local _ = {}

function Bags.countItem(itemID)
  local count = 0

  for containerIndex = 0, NUM_BAG_SLOTS + 1 do
    for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
      local itemInfo = Compatibility.Container.retrieveItemInfo(containerIndex, slotIndex)
      if itemInfo and itemInfo.itemID == itemID then
        count = count + itemInfo.stackCount
      end
    end
  end

  return count
end

function Bags.findItem(itemIDs)
  if type(itemIDs) == 'number' then
    itemIDs = { itemIDs }
  end
  itemIDs = Set.create(itemIDs)

  for containerIndex = 0, NUM_BAG_SLOTS + 1 do
    for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
      local slotItemID = C_Container.GetContainerItemID(containerIndex, slotIndex)
      if Set.contains(itemIDs, slotItemID) then
        return containerIndex, slotIndex
      end
    end
  end

  return nil, nil
end

function Bags.hasItem(itemID)
  for containerIndex = 0, NUM_BAG_SLOTS + 1 do
    for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
      local slotItemID = C_Container.GetContainerItemID(containerIndex, slotIndex)
      if slotItemID == itemID then
        return true
      end
    end
  end

  return false
end
