local function addItemsForMailing()
  for containerIndex = 0, NUM_BAG_SLOTS do
    for slotIndex = 1, GetContainerNumSlots(containerIndex) do
      local itemID = GetContainerItemID(containerIndex, slotIndex)
      if itemID then
        local classID = select(6, GetItemInfoInstant(itemID))
        if classID == Enum.ItemClass.Tradegoods then
          GMR.DefineMailingItem(itemID)
        end
      end
    end
  end
end

local function onBagUpdateDelayed()
    addItemsForMailing()
end

local function onEvent(self, event, ...)
    if event == 'BAG_UPDATE_DELAYED' then
        onBagUpdateDelayed(...)
    end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', onEvent)
frame:RegisterEvent('BAG_UPDATE_DELAYED')

local ticker
ticker = C_Timer.NewTicker(0, function ()
  if GMR.IsFullyLoaded() then
    ticker:Cancel()
    addItemsForMailing()
  end
end)
