local function calculateDistance(a, b)
  return math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2) + math.pow(b.z - a.z, 2))
end

local function angleTo(from, to)
  local x = to.x - from.x
  local y = to.y - from.y
  local angle = math.atan2(y, x)
  if angle < 0 then
    angle = angle + 2 * math.pi
  end
  return angle
end

local function isPlayerInRange(coordinates, range)
  local playerPosition = GMR.GetPlayerPosition()
  local distance = calculateDistance(playerPosition, coordinates)
  return distance ~= nil and distance <= range
end

local function hasArrivedAt(coordinates, proximityTolerance)
  return isPlayerInRange(coordinates, proximityTolerance)
end

local function retrieveObjectPosition(identifier)
  local x, y, z = GMR.ObjectPosition(identifier)
  return {
    x = x,
    y = y,
    z = z
  }
end

local function getDifferenceBetweenAngleFromPlayerToPositionAndPlayerFacingAngle(position)
  local playerPosition = retrieveObjectPosition('player')
  local angleFromPlayerToTarget = angleTo(playerPosition, position)
  local playerFacingAngle = GMR.ObjectRawFacing('player')
  local differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle = angleFromPlayerToTarget - playerFacingAngle
  if differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < 0 then
    differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle = differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle + 2 * math.pi
  end
  return differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle
end

local moveToWhileFacingDistanceProximityTolerance = 0.5

function facePosition(positionToFace)
  GMR.FaceDirection(positionToFace.x, positionToFace.y, positionToFace.z)
end

local moveDirections = {
  MoveForward = 1,
  MoveForwardAndStrafeLeft = 2,
  StrafeLeft = 3,
  MoveBackwardAndStrafeLeft = 4,
  MoveBackward = 5,
  MoveBackwardAndStrafeRight = 6,
  StrafeRight = 7,
  MoveForwardAndStrafeRight = 8
}

local function getDirectionToMoveTowards(position)
  local differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle = getDifferenceBetweenAngleFromPlayerToPositionAndPlayerFacingAngle(position)

  local moveDirection
  if differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= 2 * math.pi - (1 / 8) * math.pi or differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < (1 / 8) * math.pi then
    moveDirection = moveDirections.MoveForward
  elseif differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= (1 / 8) * math.pi and differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < (3 / 8) * math.pi then
    moveDirection = moveDirections.MoveForwardAndStrafeLeft
  elseif differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= (3 / 8) * math.pi and differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < (5 / 8) * math.pi then
    moveDirection = moveDirections.StrafeLeft
  elseif differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= (5 / 8) * math.pi and differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < (7 / 8) * math.pi then
    moveDirection = moveDirections.MoveBackwardAndStrafeLeft
  elseif differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= (7 / 8) * math.pi and differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < (9 / 8) * math.pi then
    moveDirection = moveDirections.MoveBackward
  elseif differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= (9 / 8) * math.pi and differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < (11 / 8) * math.pi then
    moveDirection = moveDirections.MoveBackwardAndStrafeRight
  elseif differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= (11 / 8) * math.pi and differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < (13 / 8) * math.pi then
    moveDirection = moveDirections.StrafeRight
  elseif differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= (13 / 8) * math.pi and differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle < (15 / 8) * math.pi then
    moveDirection = moveDirections.MoveForwardAndStrafeRight
  end

  return moveDirection
end

local function startMovingInDirection(moveDirection)
  if moveDirection == moveDirections.MoveForward then
    GMR.MoveForwardStart()
  elseif moveDirection == moveDirections.MoveForwardAndStrafeLeft then
    GMR.MoveForwardStart()
    GMR.StrafeLeftStart()
  elseif moveDirection == moveDirections.StrafeLeft then
    GMR.StrafeLeftStart()
  elseif moveDirection == moveDirections.MoveBackwardAndStrafeLeft then
    GMR.MoveBackwardStart()
    GMR.StrafeLeftStart()
  elseif moveDirection == moveDirections.MoveBackward then
    GMR.MoveBackwardStart()
  elseif moveDirection == moveDirections.MoveBackwardAndStrafeRight then
    GMR.MoveBackwardStart()
    GMR.StrafeRightStart()
  elseif moveDirection == moveDirections.StrafeRight then
    GMR.StrafeRightStart()
  elseif moveDirection == moveDirections.MoveForwardAndStrafeRight then
    GMR.MoveForwardStart()
    GMR.StrafeRightStart()
  end
end

local function stopMovingInDirection(moveDirection)
  if moveDirection == moveDirections.MoveForward then
    GMR.MoveForwardStop()
  elseif moveDirection == moveDirections.MoveForwardAndStrafeLeft then
    GMR.MoveForwardStop()
    GMR.StrafeLeftStop()
  elseif moveDirection == moveDirections.StrafeLeft then
    GMR.StrafeLeftStop()
  elseif moveDirection == moveDirections.MoveBackwardAndStrafeLeft then
    GMR.MoveBackwardStop()
    GMR.StrafeLeftStop()
  elseif moveDirection == moveDirections.MoveBackward then
    GMR.MoveBackwardStop()
  elseif moveDirection == moveDirections.MoveBackwardAndStrafeRight then
    GMR.MoveBackwardStop()
    GMR.StrafeRightStop()
  elseif moveDirection == moveDirections.StrafeRight then
    GMR.StrafeRightStop()
  elseif moveDirection == moveDirections.MoveForwardAndStrafeRight then
    GMR.MoveForwardStop()
    GMR.StrafeRightStop()
  end
end

function moveToWithCurrentFacingDirection(position)
  local moveDirection = getDirectionToMoveTowards(position)
  startMovingInDirection(moveDirection)

  local handler
  handler = C_Timer.NewTicker(1 / 60, function()
    local playerPosition = retrieveObjectPosition('player')
    local distance = calculateDistance(
      playerPosition,
      position
    )
    local proximityTolerance = moveToWhileFacingDistanceProximityTolerance
    if distance <= proximityTolerance then
      handler:Cancel()
      stopMovingInDirection(moveDirection)
    else
      local moveDirection2 = getDirectionToMoveTowards(position)
      if moveDirection ~= moveDirection2 then
        stopMovingInDirection(moveDirection)
        moveDirection = moveDirection2
        startMovingInDirection(moveDirection)
      end
    end
  end)
end

local function isFacingPosition(positionToFace)
  local differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle = getDifferenceBetweenAngleFromPlayerToPositionAndPlayerFacingAngle(positionToFace)
  local proximityTolerance = (5 / 360) * 2 * math.pi
  return (
    differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle >= 2 * math.pi - proximityTolerance or
      differenceBetweenAngleFromPlayerToTargetAndPlayerFacingAngle <= proximityTolerance
  )
end

function moveToWhileFacing(moveToPosition, positionToFace)
  local hasStopped = false

  facePosition(positionToFace)
  moveToWithCurrentFacingDirection(moveToPosition)
  local handler
  handler = C_Timer.NewTicker(1 / 60, function()
    if hasStopped then
      handler:Cancel()
    elseif (
      hasArrivedAt(moveToPosition, moveToWhileFacingDistanceProximityTolerance) and
        isFacingPosition(positionToFace)
    ) then
      handler:Cancel()
    end
  end)

  return {
    Stop = function()
      hasStopped = true
    end
  }
end

function moveTo3(moveToPosition)
  return moveToWhileFacing(moveToPosition, moveToPosition)
end

function testMoveTo3()
  local position = createPoint(
    -3459.1276855469,
    712.71026611328,
    2.9626386165619
  )
  savedPosition = position
  moveTo3(position)
end
