Resolvable = Resolvable or {}
local addOnName, AddOn = ...
local _ = {}

Resolvable.Resolvable = {}

function Resolvable.Resolvable:new(fn)
  local object = {
    _afterResolve = Hook.Hook:new(),
  }
  setmetatable(object, { __index = Resolvable.Resolvable })
  RunNextFrame(function()
    local function resolve(...)
      object._afterResolve:runCallbacks(...)
    end

    fn(resolve)
  end)
  return object
end

function Resolvable.Resolvable:afterResolve(callback)
  self._afterResolve:registerCallback(callback)
end

function Resolvable.Resolvable:resolveWith(...)
  self._afterResolve:runCallbacks(...)
end

function Resolvable.Resolvable:resolve()
  self:resolveWith()
end

function Resolvable.await(value)
  if value and value.afterResolve then
    local thread = coroutine.running()
    value:afterResolve(function(...)
      Coroutine.resumeWithShowingError(thread, ...)
    end)
    return coroutine.yield()
  else
    return value
  end
end
