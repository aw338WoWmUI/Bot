local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR then
    ticker:Cancel()
    function GMR.IsBattleGroundChecked()
      return false
    end
  end
end)
