local GRID_LENGTH = 2
local MAXIMUM_Z = 10000
local MINIMUM_Z = -10000

function mesh(fromX, fromY, toX, toY)
  local zCoordinates = {}
  for y = fromY, toY, GRID_LENGTH do
    local a = {}
    zCoordinates[y] = a
    for x = fromX, toX, GRID_LENGTH do
      local tracePoint = Movement.traceLineCollisionWithFallback(
        createPoint(x, y, MAXIMUM_Z),
        createPoint(x, y, MINIMUM_Z)
      )
      a[x] = tracePoint and tracePoint.z or nil
    end
  end
  return zCoordinates
end

function makePolygons(zCoordinates)
  return {

  }
end

function savePosition1()
  position1 = Movement.closestPointOnGrid(Movement.retrievePlayerPosition())
end

function savePosition2()
  position2 = Movement.closestPointOnGrid(Movement.retrievePlayerPosition())
end

function generateMeshNetForSavedPositions()
  local fromX =  math.min(position1.x, position2.x)
  local fromY = math.min(position1.y, position2.y)
  local toX = math.max(position1.x, position2.x)
  local toY = math.max(position1.y, position2.y)
  return mesh(fromX, fromY, toX, toY)
end
