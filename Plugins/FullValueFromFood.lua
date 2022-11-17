local function waitForItemToLoad(item)
  if not item:IsItemDataCached() then
    local thread = coroutine.running()

    item:ContinueOnItemLoad(function()
      coroutine.resume(thread)
    end)

    coroutine.yield()
  end
end

local function retrieveTotalRegenerateValue(containerIndex, slotIndex)
  local itemID = GetContainerItemID(containerIndex, slotIndex)
  local item = Item:CreateFromItemID(itemID)
  waitForItemToLoad(item)
  local text = Tooltips.retrieveItemTooltipText(itemID)
  local totalRegenerationValue = Tooltips.retrieveNThNumber(text, 1)
  return totalRegenerationValue
end

local function calculateValue(totalRegenerationValue, totalResourceValue)
  return tostring(math.floor((totalResourceValue - totalRegenerationValue) * 100 / totalResourceValue))
end

local function adjustEatingValue()
  local containerIndex, slotIndex = select(4, GMR.GetFood())
  if containerIndex and slotIndex then
    local totalRegenerationValue = retrieveTotalRegenerateValue(containerIndex, slotIndex)
    local totalHealth = UnitHealthMax('player')
    -- This seems to only be reflected in the GMR GUI after reload.
    GMR_SavedVariablesPerCharacter["EatingValue"] = calculateValue(totalRegenerationValue, totalHealth)
  end
end

local function adjustDrinkingValue()
  local containerIndex, slotIndex = select(4, GMR.GetDrink())
  if containerIndex and slotIndex then
    local totalRegenerationValue = retrieveTotalRegenerateValue(containerIndex, slotIndex)
    local totalMana = UnitPowerMax('player')
    -- This seems to only be reflected in the GMR GUI after reload.
    GMR_SavedVariablesPerCharacter["DrinkingValue"] = calculateValue(totalRegenerationValue, totalMana)
  end
end

local function adjustValues()
  coroutine.wrap(function()
    adjustEatingValue()
    adjustDrinkingValue()
  end)()
end

C_Timer.After(5, adjustValues)
C_Timer.NewTicker(60, adjustValues)
