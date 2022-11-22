GMRHelpers = {}

local functionsToRunWhenGMRIsLoaded = {}
local functionsToRunWhenGMRIsFullyLoaded = {}

function GMRHelpers.isFullyLoaded()
  return _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded()
end

local function runFunctions(functions)
  runAsCoroutine(function()
    Array.forEach(functions, function(fn)
      fn()
      yieldAndResume()
    end)
  end)
end

local runFunctionsWhenGMRIsFullyLoaded = Function.once(function()
  Conditionals.doOnceWhen(
    GMRHelpers.isFullyLoaded,
    function()
      runFunctions(functionsToRunWhenGMRIsFullyLoaded)
    end
  )
end)

local runFunctionsWhenGMRIsLoaded = Function.once(function()
  Conditionals.doOnceWhen(
    function()
      return _G.GMR
    end,
    function()
      runFunctions(functionsToRunWhenGMRIsLoaded)
    end
  )
end)

function doWhenGMRIsLoaded(fn)
  table.insert(functionsToRunWhenGMRIsLoaded, fn)
  runFunctionsWhenGMRIsLoaded()
end

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
