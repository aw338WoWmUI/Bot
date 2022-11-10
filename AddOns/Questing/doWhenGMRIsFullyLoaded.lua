function doWhenGMRIsFullyLoaded(fn)
  local ticker
  ticker = C_Timer.NewTicker(0, function()
    if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
      ticker:Cancel()

      fn()
    end
  end)
end
