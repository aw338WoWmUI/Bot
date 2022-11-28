local addOnName, AddOn = ...
HWT = HWT or {}

local _ = {}

local isHWTLoaded = false
local functionsToRunWhenHWTIsLoaded = {}

Conditionals.doOnceWhen(
  function ()
    return _G.GMR and GMR.RunString
  end,
  function ()
    local HWT2 = HWTRetriever.retrieveHWT()
    if HWT2 then
      Object.assign(HWT, HWT2)
      isHWTLoaded = true
      _.runFunctions(functionsToRunWhenHWTIsLoaded)
    end
  end
)

function _.runFunctions(functions)
  Coroutine.runAsCoroutine(function()
    Array.forEach(functions, function(fn)
      fn()
      Yielder.yieldAndResume()
    end)
  end)
end

function HWT.doWhenHWTIsLoaded(fn)
  if isHWTLoaded then
    Coroutine.runAsCoroutine(fn)
  else
    table.insert(functionsToRunWhenHWTIsLoaded, fn)
  end
end

function _.isHWTLoaded()
  return isHWTLoaded
end
