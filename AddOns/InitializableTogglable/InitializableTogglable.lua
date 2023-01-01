InitializableTogglable = InitializableTogglable or {}
local addOnName, AddOn = ...
local _ = {}

InitializableTogglable.InitializableTogglable = {}

function InitializableTogglable.InitializableTogglable:new(initialize)
	local initializeTogglable = {
    _togglable = nil,
    _initialize = initialize
  }
  setmetatable(initializeTogglable, { __index = InitializableTogglable.InitializableTogglable })
  return initializeTogglable
end

function InitializableTogglable.InitializableTogglable:toggle()
	self:initialize()
  Togglable.Togglable.toggle(self._togglable)
end

function InitializableTogglable.InitializableTogglable:initialize()
	if not self._togglable then
    self._togglable = self._initialize()
  end
end
