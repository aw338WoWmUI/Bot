Bot = Bot or {}
local addOnName = ...
local _ = {}

function Bot.processItems()
  Coroutine.runAsCoroutine(function ()
    _.sellItemsAtNPCVendor()
  end)
end

function _.sellItemsAtNPCVendor()
	Bot.sell()
end

function Bot.sell()
  local sellNPC = Questing.closestNPCs.Sell
  await(Core.gossipWithAt(sellNPC, sellNPC.objectID))
  if MerchantFrame:IsShown() then
    Bot.sellItemsAtVendor()
  else
    if Bot.hasSellingGossipOption() then
      Bot.selectSellingGossipOption()
    end
    local wasSuccessful = Events.waitForEvent('MERCHANT_SHOW', 2)
    if wasSuccessful then
      Bot.sellItemsAtVendor()
    end
  end
  CloseMerchant()
end

function Bot.sellItemsAtVendor()
  for containerIndex = 0, NUM_BAG_SLOTS do
    for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
      local itemInfo = Compatibility.Container.retrieveItemInfo(containerIndex, slotIndex)
      if itemInfo then
        local classID = select(6, GetItemInfoInstant(itemInfo.itemID))
        if itemInfo and
          not itemInfo.hasNoValue and (
          itemInfo.quality == Enum.ItemQuality.Poor or
            (BotOptions.sellCommon and (itemInfo.quality == Enum.ItemQuality.Common and (classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor))) or
            (BotOptions.sellUncommon and itemInfo.quality == Enum.ItemQuality.Uncommon) or
            (BotOptions.sellRare and itemInfo.quality == Enum.ItemQuality.Rare)
        ) then
          Compatibility.Container.UseContainerItem(containerIndex, slotIndex)
          Events.waitForEvent('BAG_UPDATE_DELAYED')
        end
      end
    end
  end
end

function Bot.hasSellingGossipOption()
  return Boolean.toBoolean(Bot.retrieveSellingGossipOption())
end

function Bot.selectSellingGossipOption()
  local option = Bot.retrieveSellingGossipOption()
  if option then
    Compatibility.GossipInfo.selectOption(option.gossipOptionID)
  end
end

function Bot.retrieveSellingGossipOption()
  local options = Compatibility.GossipInfo.retrieveOptions()
  return Array.find(options, Bot.isSellingGossipOption)
end

function Bot.isSellingGossipOption(option)
  return option.icon == 132060
end

function Bot.retrieveSellingGossipOption()
  local options = Compatibility.GossipInfo.retrieveOptions()
  return Array.find(options, Bot.isSellingGossipOption)
end

local function onAddonLoaded(addOnLoadedName)
  if addOnLoadedName == addOnName then
    _.initializeSavedVariables()
  end
end

function _.initializeSavedVariables()
	if not BotOptions then
    BotOptions = {}
  end
  if BotOptions.sellCommon == nil then
    BotOptions.sellCommon = false
  end
  if BotOptions.sellUncommon == nil then
    BotOptions.sellUncommon = false
  end
  if BotOptions.sellRare == nil then
    BotOptions.sellRare = false
  end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', function (self, event, ...)
  if event == 'ADDON_LOADED' then
    onAddonLoaded(...)
  end
end)
frame:RegisterEvent('ADDON_LOADED')
