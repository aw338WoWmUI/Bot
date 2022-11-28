local addOnName, AddOn, exports, imports = ...
--- @type Modules
local Modules = imports and imports.Modules or _G.Modules
--- @class Stoppable
local Stoppable = Modules.determineExportsVariable(addOnName, exports)

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
