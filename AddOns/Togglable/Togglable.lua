Togglable = Togglable or {}
local addOnName, AddOn = ...
local _ = {}

Togglable.Togglable = {}

function Togglable.Togglable:new(start)
	local togglable = {
    _start = start,
    _isRunning = false,
    _stoppable = nil
  }
  setmetatable(togglable, { __index = Togglable.Togglable })
  return togglable
end

function Togglable.Togglable:isRunning()
	return self._isRunning
end

function Togglable.Togglable:toggle()
  if self._isRunning then
    if self._stoppable then
      self._stoppable:afterStop(function ()
        self._isRunning = false
      end)
      print('stop')
      self._stoppable:stop()
      self._stoppable = nil
    end
  else
    self._isRunning = true
    self._stoppable = self._start()
  end
end
