local addOnName, AddOn, exports, imports = ...
local Modules = imports and imports.Modules or _G.Modules
local Movement = Modules.determineExportsVariable(addOnName, exports)
local ObjectToValueLookup = Modules.determineImportVariables('ObjectToValueLookup', imports)

local pointsWithPathTo = ObjectToValueLookup:new(function(point)
  return { point.x, point.y, point.z, point.pathIndex }
end)

function Movement.createPointWithPathTo(x, y, z, pathIndex)
  local point = {
    x = x,
    y = y,
    z = z,
    pathIndex = pathIndex
  }
  local flyweightPoint = pointsWithPathTo:retrieveValue(point)
  if not flyweightPoint then
    flyweightPoint = point
    pointsWithPathTo:setValue(flyweightPoint, flyweightPoint)
  end
  return flyweightPoint
end
