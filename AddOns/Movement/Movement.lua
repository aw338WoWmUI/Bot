position1 = nil
position2 = nil
local ddd = nil
local afsdsd = nil

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

      if ddd and afsdsd then
        local playerPosition = GMR.GetPlayerPosition()
        Array.forEach(afsdsd, function (point)
          GMR.LibDraw.Line(
            ddd.x,
            ddd.y,
            ddd.z,
            point.x,
            point.y,
            point.z
          )
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
  savedPosition = GMR.GetPlayerPosition()
end

function moveTo(position)
  GMR.MoveTo(position.x, position.y, position.z)
end

local TraceLineHitFlags = {
  COLLISION = 1048849
}

function toPoint(x, y, z)
  return {
    x = x,
    y = y,
    z = z
  }
end

function calculateIsObstacleInFrontToPosition(position)
  return toPoint(GMR.GetPositionFromPosition(position.x, position.y, position.z, 5, GMR.ObjectRawFacing('player'),
    0))
end

function isObstacleInFront(position)
  position1 = {
    x = position.x,
    y = position.y,
    z = position.z + 1
  }
  position2 = calculateIsObstacleInFrontToPosition(position1)
  local x, y, z = GMR.TraceLine(position1.x, position1.y, position1.z, position2.x, position2.y, position2.z,
    TraceLineHitFlags.COLLISION)
  print(x, y, z)
  return toBoolean(x and y and z)
end

function canWalkTo(position)
  local playerPosition = GMR.GetPlayerPosition()
  local fromPosition = {
    x = playerPosition.x,
    y = playerPosition.y,
    z = playerPosition.z + 1
  }
  local x, y, z = GMR.TraceLine(fromPosition.x, fromPosition.y, fromPosition.z, position.x, position.y, position.z,
    TraceLineHitFlags.COLLISION)
  return toBoolean(not x)
end

function isObstacleInFrontOfPlayer()
  local playerPosition = GMR.GetPlayerPosition()
  return isObstacleInFront(playerPosition)
end

function generateWaypoint()
  local playerPosition = GMR.GetPlayerPosition()
  local x, y, z = GMR.GetPositionFromPosition(playerPosition.x, playerPosition.y, playerPosition.z, 5, GMR.ObjectRawFacing('player'),
    0)
  return {
    x = x,
    y = y,
    z = z
  }
end

function generateAngles()
  local angles = {}
  for angle = 0, 2 * PI, 2 * PI / 360 * 5 do
    table.insert(angles, angle)
  end
  return angles
end

function isWalkableToEvaluationPoint(evaluation)
  return evaluation.canWalkTo
end

function retrievePositionFromEvaluation(evaluation)
  return evaluation.position
end

function findMostOptimalPosition(evaluations, destination)
  local walkableToEvaluations = Array.filter(evaluations, isWalkableToEvaluationPoint)
  local walkableToPoints = Array.map(walkableToEvaluations, retrievePositionFromEvaluation)
  afsdsd = walkableToPoints
  print('destination')
  DevTools_Dump(destination)
  print('walkableToPoints')
  DevTools_Dump(walkableToPoints)
  local mostOptimalPosition = Array.min(walkableToPoints, function (point)
    return GMR.GetDistanceBetweenPositions(point.x, point.y, point.z, destination.x, destination.y, destination.z)
  end)
  print('mostOptimalEvaluation')
  DevTools_Dump(mostOptimalPosition)
  return mostOptimalPosition
end

function findApproachPosition(destination)
  local playerPosition = GMR.GetPlayerPosition()
  ddd = playerPosition

  local fromPosition = {
    x = playerPosition.x,
    y = playerPosition.y,
    z = playerPosition.z + 1
  }

  local function evaluateApproachPosition(angle)
    local x, y, z = GMR.GetPositionFromPosition(fromPosition.x, fromPosition.y, fromPosition.z, 1, angle, 0)
    local position = {
      x = x,
      y = y,
      z = z
    }
    return {
      canWalkTo = canWalkTo(position),
      position = position
    }
  end

  local angles = generateAngles()
  local evaluations = Array.map(angles, evaluateApproachPosition)
  local mostOptimalPosition = findMostOptimalPosition(evaluations, destination)

  return mostOptimalPosition
end

function createMoveToAction(waypoint)
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
      return GMR.IsPlayerPosition(waypoint.x, waypoint.y, waypoint.z, 1)
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
