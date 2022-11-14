local functionsToRunWhenGMRIsFullyLoaded = {}

local runFunctionsWhenGMRIsFullyLoaded = Function.once(function()
  local ticker
  ticker = C_Timer.NewTicker(0, function()
    if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
      ticker:Cancel()

      local thread = coroutine.create(function()
        Array.forEach(functionsToRunWhenGMRIsFullyLoaded, function(fn)
          fn()
          yieldAndResume()
        end)
      end)
      resumeWithShowingError(thread)
    end
  end)
end)

function doWhenGMRIsFullyLoaded(fn)
  table.insert(functionsToRunWhenGMRIsFullyLoaded, fn)
  runFunctionsWhenGMRIsFullyLoaded()
end

function doRegularlyWhenGMRIsFullyLoaded(fn)
  doWhenGMRIsFullyLoaded(function()
    local thread = coroutine.create(function()
      while true do
        fn()
        yieldAndResume()
      end
    end)
    resumeWithShowingError(thread)
  end)
end
