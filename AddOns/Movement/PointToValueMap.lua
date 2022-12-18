local addOnName, AddOn = ...
Movement = Movement or {}

local function convertPointToArray(point)
  return { point.x, point.y, point.z }
end

Movement.PointToValueMap = {}

function Movement.PointToValueMap:new()
  return ObjectToValueLookup.ObjectToValueLookup:new(convertPointToArray)
end
