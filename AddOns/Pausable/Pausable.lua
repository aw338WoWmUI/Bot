Pausable = Pausable or {}
local addOnName, AddOn = ...
local _ = {}

--- @class Pausable.Pausable: Stoppable.Stoppable
Pausable.Pausable = {}
setmetatable(Pausable.Pausable, { __index = Stoppable.Stoppable })

function Pausable.Pausable:new()
  --- @class Pausable.Pausable: Stoppable.Stoppable
  local pausable, stoppableInternal = Stoppable.Stoppable:new()
  pausable._hasBeenRequestedToPause = false
  pausable._isPaused = false
  pausable._afterNextRegisterAsPaused = Hook.Hook:new()
  pausable._afterHasPaused = Hook.Hook:new()
  pausable._thread = nil
  pausable._alsoToPause = {}
  setmetatable(pausable, { __index = Pausable.Pausable })
  local pausableInternal = _.PausableInternal:new(pausable, stoppableInternal)
  return pausable, pausableInternal
end

function Pausable.Pausable:hasBeenRequestedToPause()
  return self._hasBeenRequestedToPause
end

function Pausable.Pausable:isPaused()
  return self._isPaused
end

function Pausable.Pausable:isRunning()
  return not self:isPaused() and not self:hasStopped()
end

function Pausable.Pausable:pause()
  self._hasBeenRequestedToPause = true

  local resolvable, resolvableInternal = Resolvable.Resolvable:new()

  local pausables = Array.concat({ self }, self._alsoToPause)
  local numberOfPausablesStillRunning = Array.length(pausables)
  local _pausable = self
  local afterNextRegisterAsPaused = function(...)
    numberOfPausablesStillRunning = numberOfPausablesStillRunning - 1
    if numberOfPausablesStillRunning == 0 then
      _pausable._afterHasPaused:runCallbacks()
      resolvableInternal:resolve()
    end
  end
  Array.forEach(pausables, function(pausable)
    pausable:afterNextRegisterAsPaused(afterNextRegisterAsPaused)
  end)

  Array.forEach(self._alsoToPause, function(pausable)
    return pausable:pause()
  end)

  return resolvable
end

function Pausable.Pausable:resume()
  self._hasBeenRequestedToPause = false
  self._isPaused = false
end

function Pausable.Pausable:afterHasPaused(callback)
  self._afterHasPaused:registerCallback(callback)
end

function Pausable.Pausable:alsoPause(pausable)
  table.insert(self._alsoToPause, pausable)
  return self
end

_.PausableInternal = {}

function _.PausableInternal:new(pausable, stoppableInternal)
  local pausableInternal = {
    _pausable = pausable,
    _stoppableInternal = stoppableInternal
  }
  setmetatable(pausableInternal, { __index = _.PausableInternal })
  return pausableInternal
end

function _.PausableInternal:registerAsPaused()
  self._pausable._isPaused = true
  self._pausable._hasBeenRequestedToPause = false
  self._pausable._afterNextRegisterAsPaused:runCallbacks()
end

function _.PausableInternal:pauseIfHasBeenRequestedToPause()
  if self._pausable:hasBeenRequestedToPause() then
    self._pausable._thread = coroutine.running()
    self:registerAsPaused()
    coroutine.yield()
  end
end

function _.PausableInternal:resolve(...)
  self._stoppableInternal:resolve(...)
end
