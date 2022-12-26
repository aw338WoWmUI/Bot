local addOnName, AddOn = ...
Movement = Movement or {}

local function convertWorldPositionToArray(worldPosition)
  return { worldPosition.continentID, worldPosition.x, worldPosition.y, worldPosition.z }
end

Movement.WorldPositionSet = {}

function Movement.WorldPositionSet:new()
  return ObjectToValueLookup.ObjectToValueLookup:new(convertWorldPositionToArray)
end

function Movement.createWorldPositionSetFromSavedVariable(savedVariable)
  local set = {
    _values = savedVariable._values,
    _convertObjectToArray = convertWorldPositionToArray
  }
  setmetatable(set, { __index = ObjectToValueLookup.ObjectToValueLookup})
  return set
end
