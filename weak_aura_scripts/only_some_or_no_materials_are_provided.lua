if ProfessionsFrame then
  local orderView = ProfessionsFrame.OrderView
  if orderView then
    local order = orderView.order
    if order then
      local reagentState = order.reagentState
      return reagentState == Enum.CraftingOrderReagentsType.Some or reagentState == Enum.CraftingOrderReagentsType.None
    end
  end
end
