-- # Configuration
-- For setting the character name from whom to accept the orders:
-- /script BotOptions.customerName = '<name of character>'

Bot = Bot or {}

local isDoingOrder = false

function Bot.doPublicOrders()
  if not BotOptions.customerName then
    error('Please set Bot.customerName with `/script BotOptions.customerName = \'<name of character>\'` to the name of the character who does the orders.')
    return
  end

  AutoRefreshAndAcceptCraftingOrders.autoAccept = false

  hooksecurefunc(ProfessionsFrame.OrdersPage, 'OrderRequestCallback', function()
    if not isDoingOrder then
      print('after OrderRequestCallback')
      local orders = C_CraftingOrders.GetCrafterOrders()
      local order = Array.find(orders, function(order)
        return order.customerName == BotOptions.customerName
      end)
      if order then
        print('accept order')
        isDoingOrder = true

        -- FIXME: It seems that sometimes it failes here.
        C_CraftingOrders.ClaimOrder(order.orderID, C_TradeSkillUI.GetChildProfessionInfo().profession)
        Coroutine.runAsCoroutineImmediately(function()
          Events.waitForEventCondition('CRAFTINGORDERS_CLAIMED_ORDER_UPDATED', function(self, event, orderID)
            return orderID == order.orderID
          end)
          local recipeID = order.spellID
          local isRecraft = false
          local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft)
          local transaction = CreateProfessionsRecipeTransaction(recipeSchematic)
          local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)
          local highestRecipe = Professions.GetHighestLearnedRecipe(recipeInfo)
          if highestRecipe then
            recipeInfo = highestRecipe
          end
          local reagentSlotProvidedByCustomer = {}
          for _, reagentInfo in ipairs(order.reagents) do
            reagentSlotProvidedByCustomer[reagentInfo.reagentSlot] = true
          end
          local predicate = function(reagentTbl, slotIndex)
            return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent and not reagentSlotProvidedByCustomer[slotIndex]
          end
          local craftingReagentTbl = transaction:CreateCraftingReagentInfoTbl(predicate)
          local recipeLevel = recipeInfo.unlockedRecipeLevel
          C_TradeSkillUI.CraftRecipe(recipeID, 1, craftingReagentTbl, recipeLevel, order.orderID)
          Events.waitForEventCondition('CRAFTINGORDERS_CLAIMED_ORDER_UPDATED', function(self, event, orderID)
            return orderID == order.orderID
          end)
          C_CraftingOrders.FulfillOrder(order.orderID, '', C_TradeSkillUI.GetChildProfessionInfo().profession)
          Events.waitForEvent('CRAFTINGORDERS_CLAIMED_ORDER_REMOVED')

          isDoingOrder = false

          print('...')
        end)
      end
    end
  end)
end

-- /script Bot.requestPublicOrders(5)

-- For Engineering orders
function Bot.requestPublicOrders(numberOfTimes)
  Coroutine.runAsCoroutineImmediately(function()
    for i = 1, numberOfTimes do
      Bot.requestPublicOrder()
      Events.waitForEventCondition('CHAT_MSG_SYSTEM', function(self, event, message)
        return string.match(message, 'A crafter has fulfilled your order for Handful of Serevite Bolts')
      end)
    end
  end)
end

function Bot.requestPublicOrder()
  local orderInfo = {
    craftingReagentItems = {
      {
        quantity = 4,
        itemID = 190396, -- Serevite Ore (quality 2)
        dataSlotIndex = 1
      }
    },
    orderType = 0,
    reagentItems = {},
    tipAmount = 100,
    skillLineAbilityID = 47447,
    customerNotes = '',
    orderDuration = 0,
  }
  C_CraftingOrders.PlaceNewOrder(orderInfo)
end

-- /script Bot.requestPublicOrders2(5)

-- For Blacksmithing orders
function Bot.requestPublicOrders2(numberOfTimes)
  Coroutine.runAsCoroutineImmediately(function()
    for i = 1, numberOfTimes do
      Bot.requestPublicOrder2()
      Events.waitForEventCondition('CHAT_MSG_SYSTEM', function(self, event, message)
        return string.match(message, 'A crafter has fulfilled your order for Sturdy Expedition Shovel')
      end)
    end
  end)
end

function Bot.requestPublicOrder2()
  local orderInfo = {
    craftingReagentItems = {
      {
        quantity = 10,
        itemID = 190396, -- Serevite Ore (quality 2)
        dataSlotIndex = 1
      }
    },
    orderType = 0,
    reagentItems = {
      {
        quantity = 2,
        itemID = 190452, -- Primal Flux
        dataSlotIndex = 1
      }
    },
    tipAmount = 100,
    skillLineAbilityID = 47751,
    customerNotes = '',
    orderDuration = 0,
  }
  C_CraftingOrders.PlaceNewOrder(orderInfo)
end

-- This can be used to print out the order data.
--hooksecurefunc(C_CraftingOrders, 'PlaceNewOrder', function(orderInfo)
--  print('order info')
--  DevTools_Dump(orderInfo)
--end)
