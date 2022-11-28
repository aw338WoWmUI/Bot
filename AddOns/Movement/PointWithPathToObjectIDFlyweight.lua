local addOnName, AddOn = ...
Movement = Movement or {}

local pointsWithObjectID = ObjectToValueLookup:new(function(point)
  return { point.x, point.y, point.z, point.pathIndex, point.objectID }
end)

function Movement.createPointWithPathToAndObjectID(x, y, z, pathIndex, objectID)
  local point = {
    x = x,
    y = y,
    z = z,
    pathIndex = pathIndex,
    objectID = objectID
  }
  local flyweightPoint = pointsWithPathTo:retrieveValue(point)
  if not flyweightPoint then
    flyweightPoint = point
    pointsWithPathTo:setValue(flyweightPoint, flyweightPoint)
  end
  return flyweightPoint
end
