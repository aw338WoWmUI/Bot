position1 = nil
position2 = nil
afsdsd = nil
aStarPoints = nil

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and _G.GMR.LibDraw and _G.GMR.LibDraw.clearCanvas then
    ticker:Cancel()

    hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
      if savedPosition then
        GMR.LibDraw.GroundCircle(savedPosition.x, savedPosition.y, savedPosition.z, 0.5)
      end
      if position1 and position2 then
        GMR.LibDraw.Line(
          position1.x,
          position1.y,
          position1.z,
          position2.x,
          position2.y,
          position2.z
        )
      end

      if afsdsd then
        local previousPoint = afsdsd[1]
        for index = 2, #afsdsd do
          local point = afsdsd[index]
          GMR.LibDraw.Line(
            previousPoint.x,
            previousPoint.y,
            previousPoint.z,
            point.x,
            point.y,
            point.z
          )
          previousPoint = point
        end
      end

      if aStarPoints then
        Array.forEach(aStarPoints, function(point)
          GMR.LibDraw.Circle(point.x, point.y, point.z, 0.5)
        end)
      end
    end)
  end
end)

function savePosition1()
  position1 = GMR.GetPlayerPosition()
end

function savePosition2()
  position2 = GMR.GetPlayerPosition()
end

function savePosition()
  local playerPosition = GMR.GetPlayerPosition()
  savedPosition = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + 1)
end

function moveTo(position)
  GMR.MoveTo(position.x, position.y, position.z)
end

local TraceLineHitFlags = {
  COLLISION = 1048849
}

function calculateIsObstacleInFrontToPosition(position)
  return createPoint(GMR.GetPositionFromPosition(position.x, position.y, position.z, 5, GMR.ObjectRawFacing('player'),
    0))
end

function isObstacleInFront(position)
  position1 = createPoint(
    position.x,
    position.y,
    position.z + 1
  )
  position2 = calculateIsObstacleInFrontToPosition(position1)
  return not thereAreZeroCollisions(position1, position2)
end

function canWalkTo(position)
  local playerPosition = GMR.GetPlayerPosition()
  local fromPosition = createPoint(
    playerPosition.x,
    playerPosition.y,
    playerPosition.z + 1
  )
  return thereAreZeroCollisions(fromPosition, position)
end

function thereAreZeroCollisions(a, b)
  local x, y, z = GMR.TraceLine(a.x, a.y, a.z, b.x, b.y, b.z, TraceLineHitFlags.COLLISION)
  return toBoolean(not x)
end

function isObstacleInFrontOfPlayer()
  local playerPosition = GMR.GetPlayerPosition()
  return isObstacleInFront(playerPosition)
end

function generateWaypoint()
  local playerPosition = GMR.GetPlayerPosition()
  return createPoint(GMR.GetPositionFromPosition(playerPosition.x, playerPosition.y, playerPosition.z, 5,
    GMR.ObjectRawFacing('player'),
    0))
end

function generateAngles()
  local angles = {}
  for angle = 0, 2 * PI, 2 * PI / 6 do
    table.insert(angles, angle)
  end
  return angles
end

function generatePoints(fromPosition, angles)
  return Array.map(angles, function(angle)
    return generatePoint(fromPosition, angle)
  end)
end

function generatePoint(fromPosition, angle)
  local x, y, z = GMR.GetPositionFromPosition(fromPosition.x, fromPosition.y, fromPosition.z, 5, angle, 0)
  local z2 = GMR.GetGroundZ(x, y, z)
  if z2 ~= nil then
    z = z2 + 1
  end
  return createPoint(x, y, z)
end

function isWalkableToEvaluationPoint(evaluation)
  return evaluation.canWalkTo
end

function retrievePositionFromEvaluation(evaluation)
  return evaluation.position
end

function generateNeighborPoints(fromPosition)
  local angles = generateAngles()
  local points = generatePoints(fromPosition, angles)
  aStarPoints = points
  return Array.filter(points, function(point)
    return thereAreZeroCollisions(fromPosition, point)
  end)
end

function findMostOptimalPosition(points, destination)
  local mostOptimalPosition = Array.min(points, function(point)
    return GMR.GetDistanceBetweenPositions(point.x, point.y, point.z, destination.x, destination.y, destination.z)
  end)
  return mostOptimalPosition
end

function findApproachPosition(destination)
  local playerPosition = GMR.GetPlayerPosition()

  local fromPosition = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + 1)

  local function evaluateApproachPosition(point)
    return {
      canWalkTo = canWalkTo(point),
      position = point
    }
  end

  local points = generateNeighborPoints(fromPosition)
  local mostOptimalPosition = findMostOptimalPosition(points, destination)

  return mostOptimalPosition
end

function createMoveToAction2(waypoint)
  local stopMoving = nil
  local firstRun = true
  return {
    run = function()
      if firstRun then
        stopMoving = GMR.StopMoving
        GMR.StopMoving = function()
        end
      end
      moveTo(waypoint)
    end,
    isDone = function()
      return GMR.IsPlayerPosition(waypoint.x, waypoint.y, waypoint.z, 3)
    end,
    whenIsDone = function()
      if stopMoving then
        GMR.StopMoving = stopMoving
      end
    end
  }
end

function moveToSavedPosition()
  local destination = savedPosition
  moveToAStar(destination.x, destination.y, destination.z)
end

function moveTo2(destination)
  if GMR.IsPositionInLoS(destination.x, destination.y, destination.z) then
    moveTo(destination)
  else
    local position = findApproachPosition(destination)
    print('position', position)
    if position then
      moveTo(position)
    end
  end
end

function drawLine()
  hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
    print('clearCanvas')
  end)
  GMR.LibDraw.Line(-4275.1850585938,
    168.40158081055,
    -69.644104003906,
    -4281.8154296875,
    165.69804382324,
    -69.827529907226
  )
end

function moveCloserTo(x, y, z)
  local playerPosition = GMR.GetPlayerPosition()
  local px = playerPosition.x
  local py = playerPosition.y
  local pz = playerPosition.z
  local distance = GMR.GetDistanceBetweenPositions(px, py, pz, x, y, z)
  for a = 0, distance, 1 do
    local sx, sy, sz = GMR.GetPositionBetweenPositions(px, py, pz, x, y, z, a)
    if GMR.PathExists(sx, sy, sz) then
      GMR.Questing.MoveTo(sx, sy, sz)
      return
    end
  end
end

function determineStartPosition()
  local playerPosition = GMR.GetPlayerPosition()
  local start = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + 1)

  return start
end

local pathWalker = nil

function moveToAStar(x, y, z)
  local thread = coroutine.create(function()
    local start = determineStartPosition()
    local destination = createPoint(x, y, z)

    local path = findPath(start, destination, generateNeighborPoints)
    afsdsd = path
    if path then
      if pathWalker then
        pathWalker.stop()
      end
      pathWalker = createActionSequenceDoer2(Array.map(path, createMoveToAction2))
      pathWalker.run()
    end
  end)
  resumeWithShowingError(thread)
end

function testA()
  return thereAreZeroCollisions(afsdsd[1], afsdsd[2])
end

function testADD()
  local z = GMR.GetGroundZ(savedPosition.x, savedPosition.y, savedPosition.z)
  print(z, GMR.GetDistanceToPosition(savedPosition.x, savedPosition.y, savedPosition.z - 1))
end

-- view distance = 5: 625
-- view distance = 10: 975
-- /dump testADD()
