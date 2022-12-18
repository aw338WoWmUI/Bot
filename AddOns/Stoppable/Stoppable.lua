local addOnName, AddOn = ...
Stoppable = Stoppable or {}

Stoppable.Stoppable = {}

function Stoppable.Stoppable:new()
  local stoppable = {
    _hasStopped = false,
    _returnValues = nil,
    _afterStop = Hook.Hook:new(),
    _afterReturn = Hook.Hook:new(),
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

function Stoppable.Stoppable:stopAlso(stoppable)
  self:afterStop(function()
    stoppable:Stop()
  end)
end

function Stoppable.Stoppable:afterStop(callback)
  self._afterStop:registerCallback(callback)
end

function Stoppable.Stoppable:afterReturn(callback)
  self._afterReturn:registerCallback(callback)
end

function Stoppable.Stoppable:setReturnValues(...)
  self._returnValues = { ... }
  self._afterReturn:runCallbacks()
end
