local addOnName, AddOn = ...
Stoppable = Stoppable or {}

Stoppable.Stoppable = {}

function Stoppable.Stoppable:new()
  local stoppable = {
    _hasStopped = false,
    _returnValues = nil,
    _afterStop = Hook.Hook:new(),
    _afterResolve = Hook.Hook:new(),
    _thread = nil,
  }
  setmetatable(stoppable, { __index = Stoppable.Stoppable })
  return stoppable
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

--- Wait until the stoppable has been resolved.
function Stoppable.Stoppable:await()
  self._thread = coroutine.running()
  return coroutine.yield()
end

function Stoppable.Stoppable:stopAlso(stoppable)
  self:afterStop(function()
    stoppable:Stop()
  end)
end

function Stoppable.Stoppable:afterStop(callback)
  self._afterStop:registerCallback(callback)
end

function Stoppable.Stoppable:afterResolve(callback)
  self._afterResolve:registerCallback(callback)
end

function Stoppable.Stoppable:resolveWith(...)
  self._returnValues = { ... }
  self._afterResolve:runCallbacks()
  Coroutine.resumeWithShowingError(self._thread, ...)
end
