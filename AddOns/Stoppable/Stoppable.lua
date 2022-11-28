local addOnName, AddOn = ...
--- @type Modules
--- @class Stoppable
Stoppable = Stoppable or {}

Stoppable.Stoppable = {}

function Stoppable.Stoppable:new()
  local stoppable = {
    isStopped = false
  }
  setmetatable(stoppable, Stoppable)
  return stoppable
end

function Stoppable.Stoppable:Stop()
  self.isStopped = true
end
