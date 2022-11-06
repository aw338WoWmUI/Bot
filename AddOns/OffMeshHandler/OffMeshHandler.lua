local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
    ticker:Cancel()

    local run = nil
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
      run = nil
    end

    local function isDifferentPathFindingRequestThanRun(from, to)
      return from ~= run.from or to ~= run.to
    end

    GMR.OffMeshHandler = function(x, y, z)
      print('GMR.OffMeshHandler', x, y, z)
      local from = retrievePlayerPosition()
      local to = createPoint(x, y, z)
      if run and isDifferentPathFindingRequestThanRun(from, to) then
        stopPathFinding()
      end
      if not run or isDifferentPathFindingRequestThanRun(from, to) then
        local thread = coroutine.create(function()
          run = {
            from = from,
            to = to
          }
          pathFinder = createPathFinder()
          afsdsd = nil
          print('start pathfinder')
          path = pathFinder.start(x, y, z)
          print('path')
          DevTools_Dump(path)
          if path then
            afsdsd = path
            --path = Array.map(path, function(point)
            --  return { point.x, point.y, point.z }
            --end)
            --for index = 2, #path do
            --  local previousWaypoint = path[index - 1]
            --  local waypoint = path[index]
            --  GMR.ModifyPath(previousWaypoint[1], previousWaypoint[2], previousWaypoint[3], waypoint[1], waypoint[2], waypoint[3])
            --end
            -- print('go path')
            -- pathMover = movePath(path)

            run = nil
            pathFinder = nil
          end
        end)
        return resumeWithShowingError(thread)
      end

      return true
    end

    local handleMove = function(x, y, z)
      if x and y and z then
        if pathMover then
          pathMover.stop()
          pathMover = nil
        end
        local point = createPoint(x, y, z)
        if run then
          stopPathFinding()
        end
      end
    end

    local meshTo = GMR.MeshTo
    GMR.MeshTo = function (...)
      handleMove(...)
      return meshTo(...)
    end
    hooksecurefunc(GMR, 'MoveTo', handleMove)

    --GMR.OffMeshHandler = function (x, y, z)
    --  log('GMR.OffMeshHandler', x, y, z)
    --  local continentID = select(8, GetInstanceInfo())
    --  local playerPosition = retrievePlayerPosition()
    --  local id, x, y, z = findClosestDifferentPolygonTowardsPosition(playerPosition.x, playerPosition.y, playerPosition.z, x, y, z)
    --  if x then
    --    GMR.MoveTo(x, y, z)
    --  end
    --end
  end
end)
