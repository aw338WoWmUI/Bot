local points = PointToValueMap:new()

function createPoint(x, y, z)
  local point = { x = x, y = y, z = z }
  local flyweightPoint = points:retrieveValue(point)
  if not flyweightPoint then
    flyweightPoint = point
    points:setValue(flyweightPoint, flyweightPoint)
  end
  return flyweightPoint
end
