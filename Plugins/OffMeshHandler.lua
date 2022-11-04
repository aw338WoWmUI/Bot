local runningWithPoint = nil
local pathFinder = nil
local pathMover = nil

function isPathFinding()
  return toBoolean(pathFinder)
end

local function stopPathFinding()
  if pathFinder then
    pathFinder.stop()
  end
  pathFinder = nil
  runningWithPoint = nil
end

GMR.OffMeshHandler = function (x, y, z)
  local point = createPoint(x, y, z)
  if runningWithPoint and point ~= runningWithPoint then
    stopPathFinding()
  end
  if not runningWithPoint or point ~= runningWithPoint then
    local thread = coroutine.create(function()
      runningWithPoint = point
      pathFinder = createPathFinder()
      afsdsd = nil
      print('start pathfinder')
      local path = pathFinder.start(x, y, z)
      if path then
        afsdsd = path
        path = Array.map(path, function (point)
          return {point.x, point.y, point.z}
        end)
        --for index = 2, #path do
        --  local previousWaypoint = path[index - 1]
        --  local waypoint = path[index]
        --  GMR.ModifyPath(previousWaypoint[1], previousWaypoint[2], previousWaypoint[3], waypoint[1], waypoint[2], waypoint[3])
        --end
        print('go path')
        pathMover = movePath(path)

        runningWithPoint = nil
        pathFinder = nil
      end
    end)
    return resumeWithShowingError(thread)
  end

  return true
end

local handleMove = function (x, y, z)
  if pathMover then
    pathMover.stop()
    pathMover = nil
  end
  local point = createPoint(x, y, z)
  if runningWithPoint and point ~= runningWithPoint then
    stopPathFinding()
  end
end

hooksecurefunc(GMR, 'MeshTo', handleMove)
hooksecurefunc(GMR, 'MoveTo', handleMove)
