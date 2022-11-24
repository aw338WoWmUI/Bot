local _ = {}

local functionsToRunWhenHWTIsLoaded = {}

Conditionals.doOnceWhen(
  function ()
    return _G.GMR and GMR.RunString
  end,
  HWTRetriever.putHWTOnTheGlobalScope
)

local function runFunctions(functions)
  runAsCoroutine(function()
    Array.forEach(functions, function(fn)
      fn()
      yieldAndResume()
    end)
  end)
end

local runFunctionsWhenHWTIsLoaded = Function.once(function()
  Conditionals.doOnceWhen(
    _.isHWTLoaded,
    function()
      runFunctions(functionsToRunWhenHWTIsLoaded)
    end
  )
end)

function doWhenHWTIsLoaded(fn)
  if _.isHWTLoaded() then
    runAsCoroutine(fn)
  else
    table.insert(functionsToRunWhenHWTIsLoaded, fn)
    runFunctionsWhenHWTIsLoaded()
  end
end

function _.isHWTLoaded()
  return toBoolean(_G.HWT)
end
