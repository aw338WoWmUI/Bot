local pointsWithObjectID = {}

function createPointWithPathToAndObjectID(x, y, z, pathIndex, objectID)
  local a = pointsWithObjectID[x]
  if a then
    local b = a[y]
    if b then
      local c = b[z]
      if c then
        local d = c[pathIndex]
        if d then
          local e = d[objectID]
          if e then
            return e
          end
        end
      end
    end
  end

  if not a then
    pointsWithObjectID[x] = {}
  end
  if not pointsWithObjectID[x][y] then
    pointsWithObjectID[x][y] = {}
  end
  if not pointsWithObjectID[x][y][z] then
    pointsWithObjectID[x][y][z] = {}
  end
  if not pointsWithObjectID[x][y][z][pathIndex] then
    pointsWithObjectID[x][y][z][pathIndex] = {}
  end
  local point = {
    x = x,
    y = y,
    z = z,
    pathIndex = pathIndex,
    objectID = objectID
  }
  pointsWithObjectID[x][y][z][pathIndex][objectID] = point

  return point
end
