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
  table.insert(self._callbacks, callback)
  return self
end

function Hook.Hook:runCallbacks()
  for _, callback in ipairs(self._callbacks) do
    callback()
  end
end
