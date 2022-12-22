local addOnName, AddOn = ...
Stoppable = Stoppable or {}

Stoppable.Stoppable = {}
setmetatable(Stoppable.Stoppable, { __index = Resolvable.Resolvable })

function Stoppable.Stoppable:new(fn)
  local object
  object = Resolvable.Resolvable:new(function (resolve)
    return fn(object, resolve)
  end)
  object._hasStopped = false
  object._afterStop = Hook.Hook:new()
  setmetatable(object, { __index = Stoppable.Stoppable })
  return object
end

function Stoppable.Stoppable:isRunning()
  return not self._hasStopped
end

function Stoppable.Stoppable:hasStopped()
  return self._hasStopped
end

function Stoppable.Stoppable:stop()
  self._hasStopped = true
  self._afterStop:runCallbacks()
end

function Stoppable.Stoppable:stopAlso(stoppable)
  self:afterStop(function()
    stoppable:Stop()
  end)
end

function Stoppable.Stoppable:afterStop(callback)
  self._afterStop:registerCallback(callback)
end
