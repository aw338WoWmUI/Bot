local pointsWithPathTo = {}

function createPointWithPathTo(x, y, z, pathIndex)
  local a = pointsWithPathTo[x]
  if a then
    local b = a[y]
    if b then
      local c = b[z]
      if c then
        local d = c[pathIndex]
        if d then
          return d
        end
      end
    end
  end

  if not a then
    pointsWithPathTo[x] = {}
  end
  if not pointsWithPathTo[x][y] then
    pointsWithPathTo[x][y] = {}
  end
  if not pointsWithPathTo[x][y][z] then
    pointsWithPathTo[x][y][z] = {}
  end
  local point = {
    x = x,
    y = y,
    z = z,
    pathIndex = pathIndex
  }
  pointsWithPathTo[x][y][z][pathIndex] = point

  return point
end
