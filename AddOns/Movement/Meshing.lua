-- Format: [pointIndex] = { x, y, z }
local points = {

}

-- Format: { pointIndex1, pointIndex2 }
local connections = {

}

function createMesh()

end

function canMoveFromAToB(pointA, pointB)
  return isWalkableOn(pointA) and isWalkableOn(pointB)
end

function isWalkableOn(point)
  local offset = 0.5
  return toBoolean(GMR.TraceLine(point.x, point.y, point.z + offset, point.x, point.y, point.z - offset))
end

function visualizeMesh()
  Array.forEach(connections, function (connection)
    local pointA = points[connection[1]]
    local pointB = points[connection[2]]
    GMR.LibDraw.Line(pointA.x, pointA.y, pointA.z, pointB.x, pointB.y, pointB.z)
  end)
end
