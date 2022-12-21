Hook = Hook or {}
local addOnName, AddOn = ...
local _ = {}

Hook.Hook = {}

function Hook.Hook:new()
  local hook = {
    _callbacks = {}
  }
  setmetatable(hook, { __index = Hook.Hook })
  return hook
end

function Hook.Hook:registerCallback(callback)
  local object = {
    callback = callback
  }
  table.insert(self._callbacks, object)
  local hasCallbackBeenUnregistered = false
  local handle = {
    unregisterCallback = function ()
      if not hasCallbackBeenUnregistered then
        local index = Array.indexOf(self._callbacks, object)
        if index ~= -1 then
          table.remove(self._callbacks, index)
        end
        hasCallbackBeenUnregistered = true
      end
    end
  }
  return handle
end

function Hook.Hook:runCallbacks(...)
  for _, object in ipairs(self._callbacks) do
    object.callback(...)
  end
end
