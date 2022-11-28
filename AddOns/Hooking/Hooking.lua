Hooking = {}

function Hooking.hookSettingOnTable(table, fieldName, predicate)
  local value = table[fieldName]
  if value then
    value = predicate(value)
  end
  table[fieldName] = nil

  metatable = getmetatable(table) or {}

  local originalNewindex = metatable.__newindex
  metatable.__newindex = function(table, key, value)
    if originalNewindex then
      originalNewindex(table, key, value)
    end

    if key == fieldName then
      value = predicate(value)
      rawset(table, fieldName, nil)
    elseif not originalNewindex then
      rawset(table, key, value)
    end
  end

  local originalIndex = metatable.__index
  metatable.__index = function(table, key)
    if key == fieldName then
      return value
    elseif originalIndex then
      return originalIndex(table, key)
    else
      return rawget(table, key)
    end
  end

  setmetatable(table, metatable)
end

function Hooking.hookFunctionOnTable(table, functionName, createHookFunction)
  Hooking.hookSettingOnTable(table, functionName, createHookFunction)
end

function Hooking.hookFunctionOnGlobalTable(globalName, functionName, createHookFunction)
  function tryToHookFunction()
    local table = _G[globalName]
    if table then
      Hooking.hookFunctionOnTable(table, functionName, createHookFunction)
      return true
    else
      return false
    end
  end

  if not tryToHookFunction() then
    local ticker
    ticker = C_Timer.NewTicker(0, function()
      if tryToHookFunction() then
        ticker:Cancel()
      end
    end)
  end
end
