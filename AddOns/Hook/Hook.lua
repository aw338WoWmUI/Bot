local addOnName, AddOn = ...
PackageInitialization.initializePackage(addOnName)
local _ = {}

Hook = {}

function Hook:new()
  local hook = {
    _callbacks = {}
  }
  setmetatable(hook, { __index = Hook })
  return hook
end

function Hook:registerCallback(callback)
  table.insert(self._callbacks, callback)
  return self
end

function Hook:runCallbacks()
  for _, callback in ipairs(self._callbacks) do
    callback()
  end
end
