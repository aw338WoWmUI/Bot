local run = nil
local pathFinder = nil
local pathMover = nil

function stopPathFinding()
  if pathFinder then
    pathFinder.stop()
    pathFinder = nil
    run = nil
    aStarPoints = nil
    Movement.path = nil
    MovementPath = Movement.path
  end
end

function stopPathMoving()
  if pathMover then
    pathMover.stop()
    pathMover = nil
  end
end

function stopPathFindingAndMoving()
  stopPathFinding()
  stopPathMoving()
end

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
    ticker:Cancel()

    function isPathFinding()
      return toBoolean(pathFinder)
    end

    local function isDifferentPathFindingRequestThanRun(from, to)
      return from ~= run.from or to ~= run.to
    end

    GMR.OffMeshHandler = function(x, y, z)
      -- print('GMR.OffMeshHandler', x, y, z)
      if x and y and z then
        local from = Movement.retrievePlayerPosition()
        local to = createPoint(x, y, z)
        if run and isDifferentPathFindingRequestThanRun(from, to) then
          stopPathFindingAndMoving()
        end
        if not run or isDifferentPathFindingRequestThanRun(from, to) then
          local thread = coroutine.create(function()
            if not from.x or not to.x then
              print('GMR.OffMeshHandler')
              print('from')
              DevTools_Dump(from)
              print('to')
              DevTools_Dump(to)
            end
            run = {
              from = from,
              to = to
            }
            pathFinder = Movement.createPathFinder()
            -- print('start pathfinder')
            local path = pathFinder.start(from, to)
            stopPathFinding()
            Movement.path = path
            MovementPath = Movement.path
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
    end

    GMR.MeshTo = GMR.OffMeshHandler
    GMR.Mesh = GMR.OffMeshHandler
    -- GMR.EngageMeshTo = GMR.OffMeshHandler

    hooksecurefunc(GMR, 'MoveTo', function(x, y, z)
      if x and y and z then
        if pathMover then
          pathMover.stop()
          pathMover = nil
        end
        local point = createPoint(x, y, z)
        if run then
          stopPathFindingAndMoving()
        end
      end
    end)

    C_Timer.NewTicker(0, function()
      if not GMR.IsExecuting() then
        stopPathFindingAndMoving()
      end
    end)
  end
end)
