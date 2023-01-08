local _ = {}

-- /script Bot.printYieldPerHour()

function Bot.calculateYield()
  local yield = 0
  local bags = {
    Enum.BagIndex.Backpack,
    Enum.BagIndex.ReagentBag
  }
  for __, containerIndex in ipairs(bags) do
    for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
      local itemInfo = Compatibility.Container.retrieveItemInfo(containerIndex, slotIndex)
      if itemInfo then
        local price = _.retrieveMinimumBuyoutPrice(itemInfo.itemID)
        if price then
          yield = yield + itemInfo.stackCount * price
        end
      end
    end
  end
  return yield
end

function Bot.printYield()
	print(GetMoneyString(Bot.calculateYield()))
end

function Bot.printYieldPerHour()
  local duration = _.minutes(9) + _.seconds(50)
  local yieldPerHour = Bot.calculateYield() / duration
	print(GetMoneyString(yieldPerHour))
end

function _.retrieveMinimumBuyoutPrice(itemID)
  return TSM_API.GetCustomPriceValue('DBMinBuyout', 'i:' .. itemID)
end

function _.minutes(amount)
	return amount / 60
end

function _.seconds(amount)
  return amount / (60 * 60)
end
