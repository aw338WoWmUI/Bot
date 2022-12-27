FreeUpSpace = FreeUpSpace or {}
local addOnName, AddOn = ...
local _ = {}

local ITEM_LEVEL = 353

FreeUpSpace._ = _

function FreeUpSpace.freeUpSpace()
  Coroutine.runAsCoroutine(function()
    _.sellEquipmentWithALowItemLevelBelow()
  end)
end

function _.sellEquipmentWithALowItemLevelBelow()
  _.moveEquipmentWithALowItemLevelFromTheBankIntoTheCharacterBags()
  _.sellEquipmentWithALowItemLevelFromTheCharacterBagsToAVendor()
end

function _.moveEquipmentWithALowItemLevelFromTheBankIntoTheCharacterBags()
  if Bags.hasFreeSpace() then
    local interactWithBankNPCPosition = Core.createWorldPosition(
      0,
      -8895.5078125,
      627.76910400391,
      99.667327880859
    )
    await(Core.moveTo(interactWithBankNPCPosition))
    local bankNPCObjectID = 43819
    local bankNPC = Core.findClosestObjectToCharacterWithObjectID(bankNPCObjectID)
    if bankNPC then
      Core.interactWithObject(bankNPC)
      Events.waitForEvent('BANKFRAME_OPENED')

      local containerIndexes = {
        Enum.BagIndex.Bank,
        Enum.BagIndex.BankBag_1,
        Enum.BagIndex.BankBag_2,
        Enum.BagIndex.BankBag_3,
        Enum.BagIndex.BankBag_4,
        Enum.BagIndex.BankBag_5,
        Enum.BagIndex.BankBag_6,
        Enum.BagIndex.BankBag_7
      }
      for __, containerIndex in ipairs(containerIndexes) do
        for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
          if Bags.areBagsFull() then
            return
          end

          if _.isEquipmentWithALowItemLevel(containerIndex, slotIndex) then
            Compatibility.Container.UseContainerItem(containerIndex, slotIndex)
            Events.waitForEvent('BAG_UPDATE_DELAYED')
          end
        end
      end
    end
  end
end

function _.sellEquipmentWithALowItemLevelFromTheCharacterBagsToAVendor()
  local vendorObjectID = 6740
  local vendor = Core.findClosestObjectToCharacterWithObjectID(vendorObjectID)
  if vendor and Core.isAlive(vendor) then
    await(Core.gossipWithObject(vendor, 28159))
    Events.waitForEvent('MERCHANT_SHOW')

    local containerIndexes = {
      Enum.BagIndex.Backpack,
      Enum.BagIndex.Bag_1,
      Enum.BagIndex.Bag_2,
      Enum.BagIndex.Bag_3,
      Enum.BagIndex.Bag_4,
    }
    for __, containerIndex in ipairs(containerIndexes) do
      for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
        local itemInfo = Compatibility.Container.retrieveItemInfo(containerIndex, slotIndex)
        if _.isEquipmentWithALowItemLevel(containerIndex, slotIndex) and not itemInfo.hasNoValue then
          Compatibility.Container.UseContainerItem(containerIndex, slotIndex)
          Events.waitForEvent('BAG_UPDATE_DELAYED')
        end
      end
    end
  end
end

function _.isEquipmentWithALowItemLevel(containerIndex, slotIndex)
  local itemLink = C_Container.GetContainerItemLink(containerIndex, slotIndex)
  return Boolean.toBoolean(itemLink and _.isEquipment(itemLink) and _.isItemLevelBelow(itemLink, ITEM_LEVEL))
end

function _.isEquipment(itemIdentifier)
  local classID = select(6, GetItemInfoInstant(itemIdentifier))
  return classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor
end

function _.isItemLevelBelow(itemIdentifier, value)
  local itemLevel = GetDetailedItemLevelInfo(itemIdentifier)
  return itemLevel < value
end
