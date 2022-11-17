Hooking = {}

function Hooking.hookSettingOnTable(table, fieldName, predicate)
  local metatable = getmetatable(table) or {}
  local originalNewindex = metatable.__newindex
  metatable.__newindex = function (table, key, value)
    if originalNewindex then
      originalNewindex(table, key, value)
    end

    if key == fieldName then
      rawset(table, key, predicate(value))
    elseif not originalNewindex then
      rawset(table, key, value)
    end
  end
  setmetatable(table, metatable)
end

function Hooking.hookFunctionOnTable(table, functionName, createHookFunction)
  return Hooking.hookSettingOnTable(table, functionName, createHookFunction)
end

function Hooking.hookFunctionOnGlobalTable(globalName, functionName, createHookFunction)
  local ticker
  ticker = C_Timer.NewTicker(0, function ()
    local table = _G[globalName]
    if table then
      ticker:Cancel()
      Hooking.hookFunctionOnTable(table, functionName, createHookFunction)
    end
  end)
end
