local function convertPointToArray(point)
  return { point.x, point.y, point.z }
end

PointToValueMap = {}

function PointToValueMap:new()
  return ObjectToValueLookup:new(convertPointToArray)
end
