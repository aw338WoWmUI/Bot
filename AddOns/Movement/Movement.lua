position1 = nil
position2 = nil
afsdsd = nil
aStarPoints = nil

-- Minimum flying lift height seems to be ~ 0.25 yards.

local zOffset = 1.6
local MAXIMUM_FALL_HEIGHT = 30
local A = 0.75

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and _G.GMR.LibDraw and _G.GMR.LibDraw.clearCanvas then
    ticker:Cancel()

    hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
      if savedPosition then
        GMR.LibDraw.Circle(savedPosition.x, savedPosition.y, savedPosition.z, 0.5)
      end
      --if position1 and position2 then
      --  GMR.LibDraw.Line(
      --    position1.x,
      --    position1.y,
      --    position1.z,
      --    position2.x,
      --    position2.y,
      --    position2.z
      --  )
      --end

      if afsdsd then
        local previousPoint = afsdsd[1]
        GMR.LibDraw.Circle(previousPoint.x, previousPoint.y, previousPoint.z, A)
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
          GMR.LibDraw.Circle(point.x, point.y, point.z, A)
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
  savedPosition = createPoint(playerPosition.x, playerPosition.y, playerPosition.z)
end

local TraceLineHitFlags = {
  COLLISION = 1048849,
  WATER = 131072,
  WATER2 = 65536
}

function positionInFrontOfPlayer(distance, deltaZ)
  local playerPosition = retrievePlayerPosition()
  return createPoint(
    GMR.GetPositionFromPosition(
      playerPosition.x,
      playerPosition.y,
      playerPosition.z + (deltaZ or 0),
      distance,
      GMR.ObjectRawFacing('player'),
      0
    )
  )
end

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
    canBeMovedFromPointToPoint(from, to)
    -- or canBeJumpedFromPointToPoint(from, to)
    -- or canBeFlownFromPointToPoint(from, to)
  )
end

function canFlyFromPointToPoint(from, to)
  local a = thereAreZeroCollisions(createPointWithZOffset(from, 0.1), to)
  local b = isEnoughSpaceOnTop(from, to)
  print(a, b)
  return a and b
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

MAXIMUM_WALK_UP_TO_HEIGHT = 0.94
local JUMP_DETECTION_HEIGHT = 1.5
local MAXIMUM_JUMP_HEIGHT = 1.675

function canBeMovedFromPointToPoint(from, to)
  local from2 = {
    x = from.x,
    y = from.y,
    z = from.z + MAXIMUM_WALK_UP_TO_HEIGHT + 0.01
  }
  local to2 = {
    x = to.x,
    y = to.y,
    z = to.z + MAXIMUM_WALK_UP_TO_HEIGHT + 0.01
  }
  local a = thereAreZeroCollisions(from2, to2)
  local b = canPlayerStandOnPoint(to)
  local c = canBeMovedFromPointToPointCheckingSubSteps(from, to)
  -- print(a, b, c)
  return (
    a and
      b and
      c
  )
end

-- /dump canBeWalkedUpTo(path[13], path[14])

function canBeMovedFromPointToPointCheckingSubSteps(from, to)
  if from.x == to.x and from.y == to.y then
    return to.z - from.z <= MAXIMUM_WALK_UP_TO_HEIGHT or (isPointInWater(from) and isPointInWater(to))
  end

  local totalDistance = distanceBetween(from, to)

  local point1 = from
  local stepSize = 1
  local distance = stepSize
  while distance < totalDistance do
    local x, y, z = GMR.GetPositionBetweenPositions(from.x, from.y, from.z, to.x, to.y, to.z, distance)
    local point2 = createPoint(x, y, z)

    if not (isPointInWater(point1) and isPointInWater(point2)) then
      local z = GMR.GetGroundZ(x, y, z)

      if not z then
        return false
      end

      point2 = createPoint(x, y, z)

      if point1.x == x and point1.y == y then
        return z - point1.z <= MAXIMUM_WALK_UP_TO_HEIGHT
      end

      if not (z - point1.z <= MAXIMUM_WALK_UP_TO_HEIGHT) then
        return false
      end
    end

    point1 = point2
    distance = distance + stepSize
  end

  if not (to.z - point1.z <= MAXIMUM_WALK_UP_TO_HEIGHT or (isPointInWater(point1) and isPointInWater(to))) then
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
  local points = generatePointsAround(position2, A, 8) -- the radius might vary race by race
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

local MAXIMUM_WATER_DEPTH = 1000

function retrieveGroundZ(position)
  local x, y, z = GMR.TraceLine(position.x, position.y, position.z, position.x, position.y,
    position.z - MAXIMUM_WATER_DEPTH, TraceLineHitFlags.COLLISION)
  return z
end

function thereAreCollisions(a, b)
  local x, y, z = GMR.TraceLine(a.x, a.y, a.z, b.x, b.y, b.z, TraceLineHitFlags.COLLISION)
  return toBoolean(x)
end

function thereAreZeroCollisions(a, b)
  return not thereAreCollisions(a, b)
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
  return Array.selectTrue(
    Array.map(angles, function(angle)
      return generateGroundPoint(fromPosition, distance, angle)
    end)
  )
end

function generateGroundOrWaterPoints(fromPosition, distance)
  return Array.selectTrue(generatePointsAroundOnGrid(fromPosition, distance, generateGroundOrWaterPoint))
end

function generateFlyingPoints(fromPosition, distance)
  return generatePointsAroundOnGrid(fromPosition, distance, generateFlyingPoint)
end

function generatePointsAroundOnGrid(fromPosition, distance, generatePoint)
  return {
    generatePoint(fromPosition, -distance, distance),
    generatePoint(fromPosition, 0, distance),
    generatePoint(fromPosition, distance, distance),
    generatePoint(fromPosition, -distance, 0),
    generatePoint(fromPosition, distance, 0),
    generatePoint(fromPosition, -distance, -distance),
    generatePoint(fromPosition, 0, -distance),
    generatePoint(fromPosition, distance, -distance)
  }
end

function generateGroundPoint(fromPosition, distance, angle)
  local point = createPoint(GMR.GetPositionFromPosition(fromPosition.x, fromPosition.y, fromPosition.z, distance, angle,
    0))
  point = closestPointOnGridWithZLeft(point)
  local z2 = GMR.GetGroundZ(point.x, point.y, point.z)
  if z2 == nil then
    return nil
  end
  return createPoint(point.x, point.y, z2)
end

function generateGroundOrWaterPoint(fromPosition, offsetX, offsetY)
  local point = closestPointOnGridWithZLeft(
    createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
  )
  if isPointInWater(point) then
    return point
  else
    local z2 = GMR.GetGroundZ(point.x, point.y, point.z)
    if z2 == nil then
      return nil
    end
    return createPoint(point.x, point.y, z2)
  end
end

function generateFlyingPoint(fromPosition, offsetX, offsetY)
  return closestPointOnGrid(
    createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
  )
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
  local points = generateGroundOrWaterPointsAround(fromPosition, distance)

  -- aStarPoints = points

  local points2 = Array.filter(points, function(point)
    return canMoveFromPointToPoint(fromPosition, point)
  end)

  -- aStarPoints = points2
  return points2
end

function receiveWaterSurfacePoint(point)
  local x, y, z = GMR.TraceLine(point.x, point.y, point.z + MAXIMUM_WATER_DEPTH, point.x, point.y, point.z,
    TraceLineHitFlags.WATER)
  if x then
    return createPoint(x, y, z)
  else
    return nil
  end
end

function isPointInWater(point)
  -- local waterSurfacePoint = receiveWaterSurfacePoint(point)
  -- return toBoolean(waterSurfacePoint and waterSurfacePoint.z >= point.z)
  return toBoolean(GMR.IsPositionUnderwater(point.x, point.y, point.z))
end

function findWaterPointAbove(point, distance)
  local waterSurfacePoint = receiveWaterSurfacePoint(point)
  if waterSurfacePoint and waterSurfacePoint.z > point.z then
    return createPoint(point.x, point.y, math.min(point.z + distance, waterSurfacePoint.z))
  else
    return nil
  end
end

function findWaterPointBelow(point, distance)
  local groundZ = retrieveGroundZ(point)
  local z
  if groundZ and groundZ >= point.z - distance then
    z = groundZ
  else
    z = point.z - distance
  end
  if z ~= point.z then
    return createPoint(point.x, point.y, z)
  else
    return nil
  end
end

function generateFlyingNeighborPoints(fromPosition, distance)
  local points = generateFlyingPointsAround(fromPosition, distance)
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

function generateGroundOrWaterPointsAround(position, distance)
  local points = generateGroundOrWaterPoints(position, distance)

  if isPointInWater(position) then
    local waterPointAbove = findWaterPointAbove(position, distance)
    if waterPointAbove then
      table.insert(points, waterPointAbove)
      Array.append(points, generateGroundOrWaterPoints(waterPointAbove, distance))
    end
  end

  local pointBelow = findWaterPointBelow(position, distance)
  if pointBelow and isPointInWater(pointBelow) then
    table.insert(points, pointBelow)
    Array.append(points, generateGroundOrWaterPoints(pointBelow, distance))
  end

  return points
end

function createPointWithZOffset(point, zOffset)
  return createPoint(point.x, point.y, point.z + zOffset)
end

function generateFlyingPointsAround(position, distance)
  local pointAbove = closestPointOnGridWithZLeft(createPointWithZOffset(position, distance))
  local pointBelow = closestPointOnGridWithZLeft(createPointWithZOffset(position, -distance))
  local points = Array.concat(
    {
      pointAbove,
      pointBelow
    },
    generateFlyingPoints(position, distance),
    generateFlyingPoints(pointAbove, distance),
    generateFlyingPoints(pointBelow, distance)
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

  local points = generateNeighborPoints(fromPosition, 4)
  local mostOptimalPosition = findMostOptimalPosition(points, destination)

  return mostOptimalPosition
end

function isPositionInTheAir(position)
  return GMR.IsPointInTheAir(position.x, position.y, position.z)
end

function createMoveToAction3(waypoint, continueMoving, a)
  local stopMoving = nil
  local firstRun = true
  local initialDistance = nil
  local lastJumpTime = nil

  local function cleanUp()
    if stopMoving then
      GMR.StopMoving = stopMoving
    end
  end

  return {
    run = function()
      if firstRun then
        stopMoving = GMR.StopMoving
        GMR.StopMoving = function()
        end
        initialDistance = GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z)
        firstRun = false
      end

      if isPositionInTheAir(waypoint) then
        if not isMountedOnFlyingMount() then
          mountOnFlyingMount()
        end
        local playerPosition = retrievePlayerPosition()
        if GMR.IsGroundPosition(playerPosition.x, playerPosition.y, playerPosition.z) then
          liftUp()
        end
      end

      local playerPosition = retrievePlayerPosition()
      if canBeMovedFromPointToPoint(playerPosition, waypoint) then
        if firstRun or not GMR.IsMoving() then
          GMR.MoveTo(waypoint.x, waypoint.y, waypoint.z)
        end
      else
        if firstRun then
          faceDirection(waypoint)
          GMR.MoveForwardStart()
        end
      end

      if not lastJumpTime or GetTime() - lastJumpTime > 1 then
        if (isJumpSituation()) then
          print('jump')
          lastJumpTime = GetTime()
          GMR.Jump()
        end
      end
    end,
    isDone = function()
      return GMR.IsPlayerPosition(waypoint.x, waypoint.y, waypoint.z, 1)
    end,
    shouldCancel = function()
      return (
        a.shouldStop() or
          GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z) > initialDistance + 5
      )
    end,
    whenIsDone = function()
      cleanUp()
      if not continueMoving then
        GMR.MoveForwardStop()
      end
    end,
    onCancel = function()
      print('Cancel')
      cleanUp()
      GMR.MoveForwardStop()
    end
  }
end

function isJumpSituation()
  --local playerPosition = retrievePlayerPosition()
  --local positionA = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + JUMP_DETECTION_HEIGHT)
  --local positionB = positionInFrontOfPlayer(3, JUMP_DETECTION_HEIGHT)
  --position1 = positionA
  --position2 = positionB
  --local a = thereAreCollisions(
  --  positionA,
  --  positionB
  --)
  ----position1 = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + MAXIMUM_JUMP_HEIGHT)
  ----position2 = positionInFrontOfPlayer(3, MAXIMUM_JUMP_HEIGHT)
  ----local b = thereAreZeroCollisions(
  ----  position1,
  ----  position2
  ----)
  ----print('a', a)
  ----print('b', b)
  --return (
  --  a
  --  --and b
  --)
  return false
end

local function findPathToSavedPosition2()
  local destination = savedPosition
  local pathFinder = createPathFinder()
  debugprofilestart()
  local path = pathFinder.start(destination.x, destination.y, destination.z)
  local duration = debugprofilestop()
  logToFile(duration)
  print(duration)
  afsdsd = path
  return path
end

function findPathToSavedPosition()
  local thread = coroutine.create(function()
    path = findPathToSavedPosition2()
  end)
  return resumeWithShowingError(thread)
end

function moveToSavedPosition()
  local thread = coroutine.create(function()
    local path = findPathToSavedPosition2()
    if path then
      path = Array.map(path, function(point)
        return { point.x, point.y, point.z }
      end)
      --for index = 2, #path do
      --  local previousWaypoint = path[index - 1]
      --  local waypoint = path[index]
      --  GMR.ModifyPath(previousWaypoint[1], previousWaypoint[2], previousWaypoint[3], waypoint[1], waypoint[2], waypoint[3])
      --end
      print('go path')
      GMR.ExecutePath(true, path)
    end
  end)
  return resumeWithShowingError(thread)
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
    local mountInfo = { C_MountJournal.GetMountInfoByID(mountID) }
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
  return waitFor(function()
    return not IsMounted()
  end)
end

function waitForMounted()
  return waitFor(function()
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
  return waitFor(function()
    local playerPosition = retrievePlayerPosition()
    return isPositionInTheAir(playerPosition)
  end)
end

function liftUp()
  GMR.JumpOrAscendStart()
  waitForIsInAir()
  GMR.AscendStop()
end

local MAXIMUM_SEARCH_TIME = nil -- seconds

function createPathFinder()
  local shouldStop2 = false

  local a = {
    shouldStop = function()
      return shouldStop2
    end
  }

  return {
    start = function(x, y, z)
      return findPath2(x, y, z, a)
    end,
    stop = function()
      shouldStop2 = true
    end
  }
end

function waitForPlayerStandingStill()
  return waitFor(function()
    return not GMR.IsMoving()
  end)
end

function findPath2(x, y, z, a)
  return findPathInner(x, y, z, a, 0)
end

points = {}
pointIndexes = {}
nextPointIndex = 1
neighbors = {}
connections = {}
paths = {}
nextPathIndex = 1

function retrievePointIndex(point)
  local x = point.x
  local y = point.y
  local z = point.z
  local a = pointIndexes[x]
  if a then
    local b = a[y]
    if b then
      local c = b[z]
      if c then
        return c
      end
    end
  end
  return nil
end

function createPointIndex(point)
  local x = point.x
  local y = point.y
  local z = point.z
  local pointIndex = nextPointIndex
  local a = pointIndexes[x]
  if not a then
    pointIndexes[x] = {}
  end
  if not pointIndexes[x][y] then
    pointIndexes[x][y] = {}
  end
  pointIndexes[x][y][z] = pointIndex
  points[pointIndex] = point
  nextPointIndex = nextPointIndex + 1
  return pointIndex
end

local function retrievePoint(pointIndex)
  return points[pointIndex]
end

local function _retrieveNeighbor(pointIndex)
  return retrievePoint(pointIndex)
end

function retrieveConnections(pointIndex)
  local connections2 = connections[pointIndex]
  if connections2 then
    return Array.map(connections2, function(connection)
      local point = retrievePoint(connection[1])
      return createPointWithPathTo(point.x, point.y, point.z, connection[2])
    end)
  else
    return {}
  end
end

function retrieveNeighbors(pointIndex)
  local neighborPointIndexes = neighbors[pointIndex]
  if neighborPointIndexes then
    local neighborPoints = Array.map(neighborPointIndexes, _retrieveNeighbor)
    return neighborPoints
  else
    return nil
  end
end

local function _storeNeighbor(pointIndex, neighbor)
  local neighborIndex = retrieveOrCreatePointIndex(neighbor)
  table.insert(neighbors[pointIndex], neighborIndex)
end

function retrieveOrCreatePointIndex(point)
  return retrievePointIndex(point) or createPointIndex(point)
end

function storeNeighbors(pointIndex, neighbors2)
  neighbors[pointIndex] = {}
  Array.forEach(neighbors2, Function.partial(_storeNeighbor, pointIndex))
end

function receiveOrGenerateNeighborPoints(generateNeighborPoints, point)
  local pointIndex = retrievePointIndex(point)
  if not pointIndex then
    pointIndex = createPointIndex(point)
  end

  local neighbours2 = retrieveNeighbors(pointIndex)
  if not neighbours2 then
    neighbours2 = generateNeighborPoints(point)
    storeNeighbors(pointIndex, neighbours2)
  end

  local connections2 = retrieveConnections(pointIndex)

  return Array.concat(connections2, neighbours2)
end

function createReceiveOrGenerateNeighborPoints(generateNeighborPoints)
  return Function.partial(receiveOrGenerateNeighborPoints, generateNeighborPoints)
end

local function isPoint(value)
  return value.x
end

function createPathIndex(path)
  local pathIndex = nextPathIndex
  paths[pathIndex] = Array.map(path, function(value)
    if isPoint(value) then
      return retrieveOrCreatePointIndex(value)
    else
      return value
    end
  end)
  nextPathIndex = nextPathIndex + 1
  return pathIndex
end

function retrievePathIndexFromPathReference(pathReference)
  return pathReference[1]
end

function retrievePath(pathIndex)
  return Array.flatMap(paths[pathIndex], function(value)
    if type(value) == 'table' then
      return retrievePath(retrievePathIndexFromPathReference(value))
    else
      return retrievePoint(value)
    end
  end)
end

local function createPathReference(pathIndex)
  return { pathIndex }
end

function addConnection(pointIndex, connection)
  if not connections[pointIndex] then
    connections[pointIndex] = {}
  end
  table.insert(connections[pointIndex], connection)
end

function storeConnection(path)
  print('store connection')
  local destinationPointIndex = retrieveOrCreatePointIndex(path[#path])

  local index = #path - 1

  local subPath = Array.slice(path, index)
  local startPointIndex = retrieveOrCreatePointIndex(subPath[1])
  local pathIndex = createPathIndex(subPath)
  local connection = {
    destinationPointIndex,
    pathIndex
  }
  addConnection(startPointIndex, connection)

  for index = #path - 2, 1, -1 do
    local subPath = { path[index], createPathReference(pathIndex) }
    local startPointIndex = retrieveOrCreatePointIndex(subPath[1])
    pathIndex = createPathIndex(subPath)
    local connection = {
      destinationPointIndex,
      pathIndex
    }
    addConnection(startPointIndex, connection)
  end
end

function findPathInner(x, y, z, a)
  local start = determineStartPosition()
  local destination = createPoint(x, y, z)

  local path
  local withFlying
  local generateNeighborPoints2
  local distance = 2
  aStarPoints = {}

  if canBeFlownFromPointToPoint(start, destination) then
    generateNeighborPoints2 = function (point)
      return generateFlyingNeighborPoints(point, distance)
    end
    withFlying = true
  else
    generateNeighborPoints2 = function (point)
      return generateNeighborPoints(point, distance)
    end
    withFlying = false
  end

  local receiveNeighborPoints = createReceiveOrGenerateNeighborPoints(generateNeighborPoints2)

  --log('withFlying', withFlying)
  --local points = receiveNeighborPoints(start)
  --aStarPoints = points
  --log('points', points)

  path = findPath(
    start,
    destination,
    receiveNeighborPoints,
    MAXIMUM_SEARCH_TIME,
    withFlying,
    a
  )

  --print('path')
  --DevTools_Dump(path)

  if path then
    storeConnection(path)
  end

  return path
end

function movePath(path)
  if pathMover then
    pathMover.stop()
  end
  local a = {
    shouldStop = function ()
      return false
    end
  }
  local pathLength = #path
  pathMover = createActionSequenceDoer2(Array.map(path, function(waypoint, index)
    return createMoveToAction3(waypoint, index < pathLength, a)
  end))
  pathMover.run()
  return pathMover
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
    print('aaaa')
    local previousPlayerFacingAngle = GMR.ObjectRawFacing('player')
    GMR.FaceSmoothly(point.x, point.y, point.z)
    yielder.yield()
    if GMR.ObjectRawFacing('player') == previousPlayerFacingAngle then
      break
    end
  end
  GMR.FaceDirection(point.x, point.y, point.z)
end

local GRID_LENGTH = 2

function closestPointOnGrid(point)
  return createPoint(
    closestCoordinateOnGrid(point.x),
    closestCoordinateOnGrid(point.y),
    closestCoordinateOnGrid(point.z)
  )
end

function closestPointOnGridWithZLeft(point)
  return createPoint(
    closestCoordinateOnGrid(point.x),
    closestCoordinateOnGrid(point.y),
    point.z
  )
end

function closestCoordinateOnGrid(coordinate)
  return Math.round(coordinate / GRID_LENGTH) * GRID_LENGTH
end

function testaa()
  GMR.GetSurroundingWaterXYZ()
  local playerPosition = retrievePlayerPosition()
  local z2 = GMR.GetGroundZ(playerPosition.x, playerPosition.y, playerPosition.z)
  savedPosition = createPoint(playerPosition.x, playerPosition.y, z2)
end

function testaa2()
  local playerPosition = retrievePlayerPosition()
  local x, y, z = GMR.TraceLine(playerPosition.x, playerPosition.y, playerPosition.z + 1000, playerPosition.x,
    playerPosition.y, playerPosition.z, bit.bor(TraceLineHitFlags.COLLISION, 131072))
  savedPosition = createPoint(x, y, z)
end

function testaa3()
  local playerPosition = retrievePlayerPosition()
  local x, y, z = GMR.TraceLine(playerPosition.x, playerPosition.y, playerPosition.z + 1000, playerPosition.x,
    playerPosition.y, playerPosition.z, 131072)
  savedPosition = createPoint(x, y, z)
end

function convertPointToArray(point)
  return { point.x, point.y, point.z }
end

function convertPathToGMRPath(path)
  return Array.map(path, convertPointToArray)
end
