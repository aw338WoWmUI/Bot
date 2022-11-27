local addOnName, AddOn, exports, imports = ...
local Modules = imports and imports.Modules or _G.Modules
local Movement = Modules.determineExportsVariable(addOnName, exports)
local ObjectToValueLookup = Modules.determineImportVariables('ObjectToValueLookup', imports)

local function convertPointToArray(point)
  return { point.x, point.y, point.z }
end

Movement.PointToValueMap = {}

function Movement.PointToValueMap:new()
  return ObjectToValueLookup:new(convertPointToArray)
end
