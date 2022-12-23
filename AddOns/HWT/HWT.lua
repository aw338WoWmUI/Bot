local addOnName = ...
local version = '1.0.0'

if not Library.isRegistered(addOnName, version) then
  local addOnName, AddOn = ...
  --- @class HWT
  local HWT = HWT or {}

  Library.register(addOnName, version, HWT)

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
        Coroutine.yieldAndResume()
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
end
