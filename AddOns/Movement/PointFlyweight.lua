local addOnName, AddOn = ...
Movement = Movement or {}

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
