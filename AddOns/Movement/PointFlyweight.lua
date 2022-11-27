local addOnName, AddOn, exports, imports = ...
local Modules = imports and imports.Modules or _G.Modules
local Movement = Modules.determineExportsVariable(addOnName, exports)

local points = Movement.PointToValueMap:new()

function Movement.createPoint(x, y, z)
  local point = { x = x, y = y, z = z }
  local flyweightPoint = points:retrieveValue(point)
  if not flyweightPoint then
    flyweightPoint = point
    points:setValue(flyweightPoint, flyweightPoint)
  end
  return flyweightPoint
end
