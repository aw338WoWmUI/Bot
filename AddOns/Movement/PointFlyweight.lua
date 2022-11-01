local points = {}

function createPoint(x, y, z)
  local a = points[x]
  if a then
    local b = a[y]
    if b then
      local c = b[z]
      if c then
        return c
      end
    end
  end

  if not a then
    points[x] = {}
  end
  if not points[x][y] then
    points[x][y] = {}
  end
  local point = {
    x = x,
    y = y,
    z = z
  }
  points[x][y][z] = point

  return point
end
