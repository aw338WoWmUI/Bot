local addOnName, AddOn = ...
GMRHelpers = GMRHelpers or {}

local functionsToRunWhenGMRIsLoaded = {}
local functionsToRunWhenGMRIsFullyLoaded = {}

function GMRHelpers.isFullyLoaded()
  return _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded()
end

local function runFunctions(functions)
  Coroutine.runAsCoroutine(function()
    Array.forEach(functions, function(fn)
      fn()
      Yielder.yieldAndResume()
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
  if GMRHelpers.isFullyLoaded() then
    Coroutine.runAsCoroutine(fn)
  else
    table.insert(functionsToRunWhenGMRIsLoaded, fn)
    runFunctionsWhenGMRIsLoaded()
  end
end

function doWhenGMRIsFullyLoaded(fn)
  if GMRHelpers.isFullyLoaded() then
    Coroutine.runAsCoroutine(fn)
  else
    table.insert(functionsToRunWhenGMRIsFullyLoaded, fn)
    runFunctionsWhenGMRIsFullyLoaded()
  end
end

function doRegularlyWhenGMRIsFullyLoaded(fn)
  doWhenGMRIsFullyLoaded(function()
    Coroutine.runAsCoroutine(function()
      while true do
        fn()
        Yielder.yieldAndResume()
      end
    end)
  end)
end
