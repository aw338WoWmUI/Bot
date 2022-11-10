local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
    ticker:Cancel()

    local run = nil
    local pathFinder = nil

    function isPathFinding()
      return toBoolean(pathFinder)
    end

    local function stopPathFinding()
      if pathFinder then
        pathFinder.stop()
      end
      pathFinder = nil
      run = nil
      aStarPoints = nil
    end

    local function isDifferentPathFindingRequestThanRun(from, to)
      return from ~= run.from or to ~= run.to
    end

    GMR.OffMeshHandler = function(x, y, z)
      -- print('GMR.OffMeshHandler', x, y, z)
      local from = Movement.retrievePlayerPosition()
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
          pathFinder = Movement.createPathFinder()
          -- print('start pathfinder')
          local path = pathFinder.start(from, to)
          Movement.path = path
          -- print('path')
          -- DevTools_Dump(path)
          if path then
            pathMover = Movement.movePath(path)

            run = nil
            pathFinder = nil
          end
        end)
        return resumeWithShowingError(thread)
      end

      return true
    end

    local meshTo = GMR.MeshTo
    GMR.MeshTo = function(x, y, z)
      if x and y and z then
        if pathMover then
          Movement.path = nil
        end
        local from = Movement.retrievePlayerPosition()
        local to = createPoint(x, y, z)
        if run and isDifferentPathFindingRequestThanRun(from, to) then
          stopPathFinding()
        end
      end
      return meshTo(x, y, z)
    end

    hooksecurefunc(GMR, 'MoveTo', function(x, y, z)
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
    end)
  end
end)
