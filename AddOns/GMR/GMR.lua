function doWhenGMRIsFullyLoaded(fn)
  local ticker
  ticker = C_Timer.NewTicker(0, function()
    if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
      ticker:Cancel()

      fn()
    end
  end)
end

function doRegularlyWhenGMRIsFullyLoaded(fn)
  doWhenGMRIsFullyLoaded(function ()
    local thread = coroutine.create(function()
      while true do
        fn()
        yieldAndResume()
      end
    end)
    resumeWithShowingError(thread)
  end)
end
