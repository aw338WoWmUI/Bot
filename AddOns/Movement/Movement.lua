position1 = nil
position2 = nil
afsdsd = nil
aStarPoints = nil

local zOffset = 1.6
local MAXIMUM_FALL_HEIGHT = 30

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and _G.GMR.LibDraw and _G.GMR.LibDraw.clearCanvas then
    ticker:Cancel()

    hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
      if savedPosition then
        GMR.LibDraw.Circle(savedPosition.x, savedPosition.y, savedPosition.z, 0.5)
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
          GMR.LibDraw.Circle(point.x, point.y, point.z, 0.1)
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
  savedPosition = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + zOffset)
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
    position.z + zOffset
  )
  position2 = calculateIsObstacleInFrontToPosition(position1)
  return not thereAreZeroCollisions(position1, position2)
end

function canWalkTo(position)
  local playerPosition = GMR.GetPlayerPosition()
  local fromPosition = createPoint(
    playerPosition.x,
    playerPosition.y,
    playerPosition.z + zOffset
  )
  return thereAreZeroCollisions(fromPosition, position)
end

function canMoveFromPointToPoint(from, to)
  return (
    canBeWalkedFromPointToPoint(from, to)
      -- or canBeJumpedFromPointToPoint(from, to)
      -- or canBeFlownFromPointToPoint(from, to)
  )
end

function canFlyFromPointToPoint(from, to)
  return thereAreZeroCollisions(from, to) and isEnoughSpaceOnTop(from, to)
end

function isEnoughSpaceOnTop(from, to)
  local a = 3
  local from2 = {
    x = from.x,
    y = from.y,
    z = from.z + a
  }
  local to2 = {
    x = to.x,
    y = to.y,
    z = to.z + a
  }
  return thereAreZeroCollisions(from2, to2)
end

MAXIMUM_WALK_UP_TO_HEIGHT = 1.1359100341797
local MAXIMUM_JUMP_HEIGHT = 1.6

function canBeWalkedFromPointToPoint(from, to)
  local from2 = {
    x = from.x,
    y = from.y,
    z = from.z + MAXIMUM_JUMP_HEIGHT
  }
  local to2 = {
    x = to.x,
    y = to.y,
    z = to.z + MAXIMUM_JUMP_HEIGHT
  }
  return (
    thereAreZeroCollisions(from2, to2) and canPlayerStandOnPoint(to) and canBeWalkedUpTo(from, to)
  )
end

function canBeWalkedUpTo(from, to)
  local point1 = from
  local distance = 1
  while GMR.GetDistanceBetweenPositions(point1.x, point1.y, point1.z, to.x, to.y, to.z) >= distance do
    local x, y, z = GMR.GetPositionBetweenPositions(point1.x, point1.y, point1.z, to.x, to.y, to.z, distance)
    local z = GMR.GetGroundZ(x, y, z)
    if not (z - point1.z <= MAXIMUM_WALK_UP_TO_HEIGHT) then
      return false
    end
    point1 = createPoint(x, y, z)
  end

  if not (to.z - point1.z <= MAXIMUM_WALK_UP_TO_HEIGHT) then
    return false
  end

  return true
end

function canBeJumpedFromPointToPoint(from, to)
  return (
    to.z - from.z <= MAXIMUM_JUMP_HEIGHT and
      canPlayerStandOnPoint(to)
  )
end

function retrievePlayerPosition()
  local playerPosition = GMR.GetPlayerPosition()
  return createPoint(playerPosition.x, playerPosition.y, playerPosition.z)
end

function canBeFlownFromPointToPoint(from, to)
  local playerPosition = retrievePlayerPosition()
  if playerPosition == from then
    if IsIndoors() then
      return false
    end
  end
  if playerPosition == to then
    if IsIndoors() then
      return false
    end
  end
  return (
    isFlyingAvailableInZone() and
    canMountedPlayerStandOnPoint(to)
  )
end

function canPlayerStandOnPoint(position)
  local position2 = createPoint(
    position.x,
    position.y,
    position.z + MAXIMUM_WALK_UP_TO_HEIGHT
  )
  local points = generatePointsAround(position2, 0.5, 36)
  return Array.all(points, function(point)
    return thereAreZeroCollisions(position2, point)
  end)
end

function canMountedPlayerStandOnPoint(position)
  return canPlayerStandOnPoint(position)
end

function isFlyingAvailableInZone()
  return IsFlyableArea()
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

function generateAngles(numberOfAngles)
  local angles = {}
  local angle = 0
  local delta = 2 * PI / numberOfAngles
  for i = 1, numberOfAngles do
    table.insert(angles, angle)
    angle = angle + delta
  end
  return angles
end

function generatePoints(fromPosition, distance, angles)
  return Array.map(angles, function(angle)
    return generatePoint(fromPosition, distance, angle)
  end)
end

function generateGroundPoints(fromPosition, distance, angles)
  return Array.map(angles, function(angle)
    return generateGroundPoint(fromPosition, distance, angle)
  end)
end

function generateFlyingPoints(fromPosition, distance, angles)
  return Array.map(angles, function(angle)
    return generatePoint(fromPosition, distance, angle)
  end)
end

function generateGroundPoint(fromPosition, distance, angle)
  local x, y, z = GMR.GetPositionFromPosition(fromPosition.x, fromPosition.y, fromPosition.z, distance, angle, 0)
  local z2 = GMR.GetGroundZ(x, y, z)
  if z2 ~= nil then
    z = z2
  end
  return createPoint(x, y, z)
end

function generatePoint(fromPosition, distance, angle)
  local x, y, z = GMR.GetPositionFromPosition(fromPosition.x, fromPosition.y, fromPosition.z, distance, angle, 0)
  return createPoint(x, y, z)
end

function isWalkableToEvaluationPoint(evaluation)
  return evaluation.canWalkTo
end

function retrievePositionFromEvaluation(evaluation)
  return evaluation.position
end

function generateNeighborPoints(fromPosition, distance)
  local points = generateGroundPointsAround(fromPosition, distance, 6)
  -- aStarPoints = points
  local points2 = Array.filter(points, function(point)
    return canMoveFromPointToPoint(fromPosition, point)
  end)
  return points2
end

function generateFlyingNeighborPoints(fromPosition, distance)
  local points = generateFlyingPointsAround(fromPosition, distance, 6)
  -- aStarPoints = points
  return Array.filter(points, function(point)
    return canFlyFromPointToPoint(fromPosition, point)
  end)
end

function generatePointsAround(position, distance, numberOfAngles)
  local angles = generateAngles(numberOfAngles)
  local points = generatePoints(position, distance, angles)
  return points
end

function generateGroundPointsAround(position, distance, numberOfAngles)
  local angles = generateAngles(numberOfAngles)
  local points = generateGroundPoints(position, distance, angles)
  return points
end

function createPointWithZOffset(point, zOffset)
  return createPoint(point.x, point.y, point.z + zOffset)
end

function generateFlyingPointsAround(position, distance, numberOfAngles)
  local angles = generateAngles(numberOfAngles)
  local pointAbove = createPointWithZOffset(position, distance)
  local pointBelow = createPointWithZOffset(position, -distance)
  local points = Array.concat(
    {
      pointAbove,
      pointBelow
    },
    generateFlyingPoints(position, distance, angles),
    generateFlyingPoints(pointAbove, distance, angles),
    generateFlyingPoints(pointBelow, distance, angles)
  )
  return points
end

function findMostOptimalPosition(points, destination)
  local mostOptimalPosition = Array.min(points, function(point)
    return GMR.GetDistanceBetweenPositions(point.x, point.y, point.z, destination.x, destination.y, destination.z)
  end)
  return mostOptimalPosition
end

function findApproachPosition(destination)
  local playerPosition = GMR.GetPlayerPosition()

  local fromPosition = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + zOffset)

  local function evaluateApproachPosition(point)
    return {
      canWalkTo = canWalkTo(point),
      position = point
    }
  end

  local points = generateNeighborPoints(fromPosition, 5)
  local mostOptimalPosition = findMostOptimalPosition(points, destination)

  return mostOptimalPosition
end


function createMoveToAction4(waypoint, move)
  local stopMoving = nil
  local firstRun = true
  return {
    run = function()
      if firstRun then
        stopMoving = GMR.StopMoving
        GMR.StopMoving = function()
        end
      end
      move(waypoint)
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

function createMoveToAction2(waypoint)
  return createMoveToAction4(waypoint, function (waypoint)
    return GMR.MoveTo(waypoint.x, waypoint.y, waypoint.z)
  end)
end

function createMoveToAction3(waypoint, continueMoving)
  local stopMoving = nil
  local firstRun = true
  return {
    run = function()
      if firstRun then
        stopMoving = GMR.StopMoving
        GMR.StopMoving = function()
        end
      end
      moveTo4(waypoint, continueMoving)
    end,
    isDone = function()
      return not IsMounted() or GMR.IsPlayerPosition(waypoint.x, waypoint.y, waypoint.z, 1)
    end,
    whenIsDone = function()
      if stopMoving then
        GMR.StopMoving = stopMoving
      end
      if not IsMounted() then
        GMR.MoveForwardStop()
      end
    end
  }
end

function moveToSavedPosition()
  local destination = savedPosition
  moveTo(destination.x, destination.y, destination.z)
end

function moveTo2(destination)
  if GMR.IsPositionInLoS(destination.x, destination.y, destination.z) then
    GMR.MoveTo(destination.x, destination.y, destination.z)
  else
    local position = findApproachPosition(destination)
    print('position', position)
    if position then
      GMR.MoveTo(position.x, position.y, position.z)
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
  local start = createPoint(playerPosition.x, playerPosition.y, playerPosition.z)

  return start
end

local pathMover = nil

function receiveActiveMount()
  local mountIDs = C_MountJournal.GetMountIDs()
  for _, mountID in ipairs(mountIDs) do
    local mountInfo = {C_MountJournal.GetMountInfoByID(mountID)}
    if mountInfo[4] then
      return unpack(mountInfo)
    end
  end
  return nil
end

function isMountedOnFlyingMount()
  if IsMounted() then
    local mountID = select(12, receiveActiveMount())
    if mountID then
      local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))
      return mountTypeID == 247 or mountTypeID == 248
    end
  end
  return false
end

function waitForDismounted()
  return waitFor(function ()
    return not IsMounted()
  end)
end

function waitForMounted()
  return waitFor(function ()
    return IsMounted()
  end)
end

function mountOnFlyingMount()
  if not isMountedOnFlyingMount() then
    if IsMounted() then
      GMR.Dismount()
    end
    waitForDismounted()
    GMR.CastSpellByName(GMR.GetFlyingMount())
    waitForMounted()
  end
end

-- /dump coroutine.wrap(mountOnFlyingMount)()

function waitForIsInAir()
  return waitFor(function ()
    local playerPosition = retrievePlayerPosition()
    return not GMR.IsGroundPosition(playerPosition.x, playerPosition.y, playerPosition.z)
  end)
end

function liftUp()
  GMR.JumpOrAscendStart()
  waitForIsInAir()
  GMR.AscendStop()
end

local MAXIMUM_SEARCH_TIME = 60 -- seconds

function moveTo(x, y, z)
  local thread = coroutine.create(function()
    moveToInner(x, y, z, 0)
  end)
  resumeWithShowingError(thread)
end

function waitForPlayerStandingStill()
  return waitFor(function ()
    return not GMR.IsMoving()
  end)
end

function moveToInner(x, y, z, depth)
  local start = determineStartPosition()
  local destination = createPoint(x, y, z)

  if canBeFlownFromPointToPoint(start, destination) then
    if not isMountedOnFlyingMount() then
      mountOnFlyingMount()
    end

    local playerPosition = retrievePlayerPosition()
    if GMR.IsGroundPosition(playerPosition.x, playerPosition.y, playerPosition.z) then
      liftUp()
      start = determineStartPosition()
    end

    if canFlyFromPointToPoint(start, destination) then
      print('direct fly')
      GMR.MoveTo(destination.x, destination.y, destination.z)
    else
      aStarPoints = {}

      local generateFlyingNeighborPointsAdaptively = function (point)
        local distanceToDestination = distanceBetween(point, destination)
        local distance
        if distanceToDestination <= 20 then
          distance = 5
        else
          distance = 10
        end
        return generateFlyingNeighborPoints(point, distance)
      end

      -- generateNeighborPoints(start)
      -- generateFlyingNeighborPointsAdaptively(start)
      -- local path = nil
      local path = findPath(start, destination, generateFlyingNeighborPointsAdaptively, MAXIMUM_SEARCH_TIME)
      afsdsd = path
      if path then
        if pathMover then
          pathMover.stop()
        end
        local pathLength = #path
        pathMover = createActionSequenceDoer2(Array.map(path, function (waypoint, index)
          return createMoveToAction3(waypoint, index < pathLength)
        end))
        pathMover.run()
        waitForPlayerStandingStill()
        if depth == 0 and not GMR.IsPlayerPosition(destination.x, destination.y, destination.z, 1) then
          moveToInner(destination.x, destination.y, destination.z, depth + 1)
        end
      end
    end
  else
    aStarPoints = {}

    local generateNeighborPointsAdaptively = function (point)
      local distanceToDestination = distanceBetween(point, destination)
      local distance
      if distanceToDestination <= 20 then
        distance = 5
      else
        distance = 5
      end
      return generateNeighborPoints(point, distance)
    end

    -- generateNeighborPointsAdaptively(start)
    -- local path = nil
    local path = findPath(start, destination, generateNeighborPointsAdaptively, MAXIMUM_SEARCH_TIME)
    print('path length', #path)
    afsdsd = path
    if path then
      if pathMover then
        pathMover.stop()
      end
      pathMover = createActionSequenceDoer2(Array.map(path, createMoveToAction2))
      pathMover.run()
      if depth == 0 and not GMR.IsPlayerPosition(destination.x, destination.y, destination.z, 1) then
        moveToInner(destination.x, destination.y, destination.z, depth + 1)
      end
    end
  end
end

function testA()
  return thereAreZeroCollisions(afsdsd[1], afsdsd[2])
end

function testADD()
  local z = GMR.GetGroundZ(savedPosition.x, savedPosition.y, savedPosition.z)
  print(z, GMR.GetDistanceToPosition(savedPosition.x, savedPosition.y, savedPosition.z - zOffset))
end

-- view distance = 5: 625
-- view distance = 10: 975
-- /dump testADD()

function waitForPlayerToBeOnPosition(position, radius)
  radius = radius or 3
  waitFor(function()
    return GMR.IsPlayerPosition(position.x, position.y, position.z, radius)
  end)
end

function faceDirection(point)
  local yielder = createYielder()
  while not GMR.IsFacingXYZ(point.x, point.y, point.z) do
    GMR.FaceSmoothly(point.x, point.y, point.z)
    yielder.yield()
  end
  GMR.FaceDirection(point.x, point.y, point.z)
end

function moveTo4(point, continueMoving)
  faceDirection(point)
  GMR.MoveForwardStart()
  waitForPlayerToBeOnPosition(point, 1)
  if not continueMoving then
    GMR.MoveForwardStop()
  end
end
