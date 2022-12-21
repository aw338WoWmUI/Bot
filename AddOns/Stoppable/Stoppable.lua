local addOnName, AddOn = ...
Stoppable = Stoppable or {}

Stoppable.Stoppable = {}
setmetatable(Stoppable.Stoppable, Resolvable.Resolvable)

function Stoppable.Stoppable:new(fn)
  local object = Resolvable.Resolvable:new(fn)
  object._hasStopped = false
  object._afterStop = Hook.Hook:new()
  setmetatable(object, { __index = self })
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
