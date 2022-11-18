Conditionals = {}

function Conditionals.doOnceWhen(areConditionsMet, fn)
  local ticker
  ticker = C_Timer.NewTicker(0, function()
    if areConditionsMet() then
      ticker:Cancel()

      fn()
    end
  end)
end
