position1 = nil
position2 = nil
aStarPoints = nil
aStarPoints2 = nil

local DEVELOPMENT = false
local zOffset = 1.6
local MAXIMUM_FALL_HEIGHT = 30
local CHARACTER_RADIUS = 0.75 -- the radius might vary race by race
local MAXIMUM_WATER_DEPTH = 1000
local GRID_LENGTH = 2
local MINIMUM_LIFT_HEIGHT = 0.25 -- Minimum flying lift height seems to be ~ 0.25 yards.
local MAXIMUM_AIR_HEIGHT = 5000
local walkToPoint = nil

local cache = {}

function addPointToCache(fromX, fromY, fromZ, toX, toY, toZ)
  local a = cache[fromX]
  if not a then
    cache[fromX] = {}
  end
  if not cache[fromX][fromY] then
    cache[fromX][fromY] = {}
  end
  cache[fromX][fromY][fromZ] = { toX, toY, toZ }
end

function retrievePointFromCache(x, y, z)
  local a = cache[x]
  if a then
    local b = a[y]
    if b then
      local c = b[z]
      if c then
        return unpack(c)
      end
    end
  end
end

function findClosestDifferentPolygon(x, y, z)
  local continentID = select(8, GetInstanceInfo())
  local id, x2, y2, z2 = GMR.GetClosestMeshPolygon(continentID, x, y, z, 1, 1, 1000)
  if id then
    local stepSize = 1

    local function checkPoint(x3, y3)
      local z3 = GMR.GetGroundZ(x3, y3, z) or z
      local id2, x4, y4, z4 = GMR.GetClosestMeshPolygon(continentID, x3, y3, z3, 1, 1, 1000)
      if id2 and id2 ~= id then
        return id2, x4, y4, z4
      else
        return nil
      end
    end

    for distance = 1, 1000 do
      local y3 = y + distance
      for x3 = x - distance, x + distance, stepSize do
        local id2, x4, y4, z4 = checkPoint(x3, y3)
        if id2 then
          return id2, x4, y4, z4
        end
      end

      local y3 = y - distance
      for x3 = x - distance, x + distance, stepSize do
        local id2, x4, y4, z4 = checkPoint(x3, y3)
        if id2 then
          return id2, x4, y4, z4
        end
      end

      local x3 = x - distance
      for y3 = y - distance + stepSize, y + distance - stepSize, stepSize do
        local id2, x4, y4, z4 = checkPoint(x3, y3)
        if id2 then
          return id2, x4, y4, z4
        end
      end

      local x3 = x + distance
      for y3 = y - distance + stepSize, y + distance - stepSize, stepSize do
        local id2, x4, y4, z4 = checkPoint(x3, y3)
        if id2 then
          return id2, x4, y4, z4
        end
      end
    end
  end

  return nil
end

function findClosestDifferentPolygonTowardsPosition(x, y, z, x5, y5, z5)
  local continentID = select(8, GetInstanceInfo())
  local id, x2, y2, z2 = GMR.GetClosestMeshPolygon(continentID, x, y, z, 1, 1, 1000)
  if id then
    local stepSize = 1

    local totalDistance = GMR.GetDistanceBetweenPositions(x, y, z, x5, y5, z5)

    function checkPoint(distance)
      local x3, y3, z3 = GMR.GetPositionBetweenPositions(x, y, z, x5, y5, z5, distance)
      local z3 = GMR.GetGroundZ(x3, y3, z) or z
      local id2, x4, y4, z4, d = GMR.GetClosestMeshPolygon(continentID, x3, y3, z3, 1, 1, 1000)
      if id2 and id2 ~= id then
        return id2, x4, y4, z4, d
      end
    end

    local distance = stepSize
    while distance < totalDistance do
      local id2, x4, y4, z4, d = checkPoint(distance)
      if id2 then
        return id2, x4, y4, z4, d
      end
      distance = distance + stepSize
    end
    local id2, x4, y4, z4, d = checkPoint(totalDistance)
    if id2 then
      return id2, x4, y4, z4, d
    end
  end

  return nil
end

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and _G.GMR.LibDraw and _G.GMR.LibDraw.clearCanvas then
    ticker:Cancel()

    hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
      if DEVELOPMENT then
        if not GMR.IsMeshLoaded() then
          GMR.LoadMeshFiles()
        end

        local continentID = select(8, GetInstanceInfo())

        local playerPosition = retrievePlayerPosition()
        if playerPosition then
          GMR.LibDraw.SetColorRaw(1, 1, 0, 1)
          for y = playerPosition.y - 4, playerPosition.y + 4 do
            for x = playerPosition.x - 4, playerPosition.x + 4 do
              local x2, y2, z2 = retrievePointFromCache(x, y, playerPosition.z)
              if not x2 then
                local z3 = GMR.GetGroundZ(x, y, playerPosition.z) or playerPosition.z
                x2, y2, z2 = GMR.GetClosestPointOnMesh(continentID, x, y, z3)
                if x2 then
                  addPointToCache(x, y, playerPosition.z, x2, y2, z2)
                end
              end
              if x2 then
                GMR.LibDraw.Circle(x2, y2, z2, 0.1)
              end
            end
          end
        end
      end

      --
      --      local playerPosition = retrievePlayerPosition()
      --      if playerPosition then
      --        local x2, y2, z2 = GMR.ObjectPosition('target')
      --        if x2 then
      --          local id, x, y, z, d = findClosestDifferentPolygonTowardsPosition(playerPosition.x, playerPosition.y,
      --            playerPosition.z, x2, y2, z2)
      --          if x then
      --            GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
      --            GMR.LibDraw.Circle(x, y, z, 4)
      --          end
      --        end
      --      end
      --
      --      --if savedPosition then
      --      --  GMR.LibDraw.Circle(savedPosition.x, savedPosition.y, savedPosition.z, 0.5)
      --      --end
      --      --if walkToPoint then
      --      --  GMR.LibDraw.Circle(walkToPoint.x, walkToPoint.y, walkToPoint.z, 0.5)
      --      --end
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

      if GMR.IsChecked('DisplayMovement') and path then
        GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
        local previousPoint = path[1]
        for index = 2, #path do
          local point = path[index]
          GMR.LibDraw.Line(
            previousPoint.x,
            previousPoint.y,
            previousPoint.z,
            point.x,
            point.y,
            point.z
          )
          GMR.LibDraw.Circle(point.x, point.y, point.z, CHARACTER_RADIUS)
          previousPoint = point
        end
        local firstPoint = path[1]
        local lastPoint = path[#path]
        GMR.LibDraw.Circle(firstPoint.x, firstPoint.y, firstPoint.z, CHARACTER_RADIUS)
        GMR.LibDraw.Circle(lastPoint.x, lastPoint.y, lastPoint.z, CHARACTER_RADIUS)
      end
      --
      --      if aStarPoints then
      --        GMR.LibDraw.SetColorRaw(0, 0, 1, 1)
      --        Array.forEach(aStarPoints, function(point)
      --          GMR.LibDraw.Circle(point.x, point.y, point.z, 0.1)
      --        end)
      --      end
      --
      --      if aStarPoints2 then
      --        GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
      --        Array.forEach(aStarPoints2, function(point)
      --          GMR.LibDraw.Circle(point.x, point.y, point.z, 0.1)
      --        end)
      --      end
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

TraceLineHitFlags = {
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
  return createPoint(GMR.GetPositionFromPosition(position.x, position.y, position.z, 5,
    GMR.ObjectRawFacing('player'),
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

function canBeMovedFromPointToPoint(from, to)
  return (
    canBeWalkedOrSwamFromPointToPoint(from, to)
      or canBeJumpedFromPointToPoint(from, to)
      or canBeFlownFromPointToPoint(from, to)
  )
end

function isEnoughSpaceOnTop(from, to)
  return (
    thereAreZeroCollisions(createPointWithZOffset(from, 0.1), createPointWithZOffset(to, 0.1)) and
      thereAreZeroCollisions(createPointWithZOffset(from, 3), createPointWithZOffset(to, 3))
  )
end

MAXIMUM_WALK_UP_TO_HEIGHT = 0.94
JUMP_DETECTION_HEIGHT = 1.5
MAXIMUM_JUMP_HEIGHT = 1.675

function canBeWalkedOrSwamFromPointToPoint(from, to)
  local b = canPlayerStandOnPoint(to)
  local c = canBeMovedFromPointToPointCheckingSubSteps(from, to)
  return (
    b and
      c
  )
end

function canBeMovedFromPointToPointCheckingSubSteps(from, to)
  if from.x == to.x and from.y == to.y then
    return to.z - from.z <= MAXIMUM_WALK_UP_TO_HEIGHT or (isPointInWater(from) and isPointInWater(to))
  end

  local totalDistance = euclideanDistance(from, to)

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
      isEnoughSpaceOnTop(from, to)
  )
end

function canPlayerStandOnPoint(point)
  local point2 = createPoint(
    point.x,
    point.y,
    point.z + MAXIMUM_WALK_UP_TO_HEIGHT
  )

  local point3 = createPointWithZOffset(point2, 0.1)

  if thereAreZeroCollisions(point2, createPointWithZOffset(point, 0.1)) then
    local points = generatePointsAround(point3, CHARACTER_RADIUS, 8)
    return Array.all(points, function(point)
      return thereAreZeroCollisions(point3, point)
    end)
  end

  return false
end

function isFlyingAvailableInZone()
  return IsFlyableArea()
end

function retrieveGroundZ(position)
  local x, y, z = GMR.TraceLine(position.x, position.y, position.z + 8, position.x, position.y,
    position.z - MAXIMUM_AIR_HEIGHT, TraceLineHitFlags.COLLISION)
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
  return createPoint(
    GMR.GetPositionFromPosition(
      playerPosition.x, playerPosition.y, playerPosition.z, 5, GMR.ObjectRawFacing('player'), 0
    )
  )
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

function generateMiddlePointsAround(fromPosition, distance)
  return Array.selectTrue(generatePointsAroundOnGrid(fromPosition, distance, generateMiddlePoint))
end

function generateAbovePointsAround(fromPosition, distance)
  local abovePoint = createPointWithZOffset(fromPosition, distance)
  return Array.selectTrue(generatePointsAroundOnGrid(abovePoint, distance, generateAbovePoint))
end

function generateBelowPointsAround(fromPosition, distance)
  local belowPoint = createPointWithZOffset(fromPosition, -distance)
  return Array.selectTrue(generatePointsAroundOnGrid(belowPoint, distance, generateBelowPoint))
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

function generateMiddlePoint(fromPosition, offsetX, offsetY)
  local point = closestPointOnGridWithZLeft(
    createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
  )
  if isPointInAir(point) or isPointInWater(point) then
    return point
  else
    local z2 = retrieveGroundZ(point)
    if z2 == nil then
      return nil
    end
    return createPoint(point.x, point.y, z2)
  end
end

function generateAbovePoint(fromPosition, offsetX, offsetY)
  return closestPointOnGrid(
    createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
  )
end

function generateBelowPoint(fromPosition, offsetX, offsetY)
  return closestPointOnGrid(
    createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
  )
end

function generatePoint(fromPosition, distance, angle)
  local x, y, z = GMR.GetPositionFromPosition(fromPosition.x, fromPosition.y, fromPosition.z, distance, angle, 0)
  return createPoint(x, y, z)
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

function generateNeighborPoints(fromPosition, distance)
  local points = generateNeighborPointsAround(fromPosition, distance)
  -- aStarPoints = points
  return Array.filter(points, function(point)
    return canBeMovedFromPointToPoint(fromPosition, point)
  end)
end

function generateNeighborPoints3(fromPosition, distance)
  local points = generateMiddlePointsAround(fromPosition, distance)
  local continentID = select(8, GetInstanceInfo())
  local maxDistance = math.sqrt(2 * math.pow(distance, 2))
  return Array.selectTrue(Array.map(points, function(point)
    local x, y, z = GMR.GetClosestPointOnMesh(continentID, point.x, point.y, point.z)
    if x then
      local point = createPoint(x, y, z)
      if euclideanDistance2D(fromPosition, point) <= maxDistance and canBeMovedFromAToB(fromPosition, point) then
        return point
      end
    end

    return nil
  end))
end

function canBeMovedFromAToB(from, to)
  return thereAreZeroCollisions(
    createPointWithZOffset(from, MAXIMUM_WALK_UP_TO_HEIGHT + 0.1),
    createPointWithZOffset(to, MAXIMUM_WALK_UP_TO_HEIGHT + 0.1)
  )
end

function generatePointsAround(position, distance, numberOfAngles)
  local angles = generateAngles(numberOfAngles)
  local points = generatePoints(position, distance, angles)
  return points
end

function createPointWithZOffset(point, zOffset)
  return createPoint(point.x, point.y, point.z + zOffset)
end

function generateNeighborPointsAround(position, distance)
  return Array.concat(
    generateMiddlePointsAround(position, distance),
    generateAbovePointsAround(position, distance),
    generateBelowPointsAround(position, distance)
  )
end

function isPositionInTheAir(position)
  return isPointInAir(position)
end

function isPointInAir(point)
  local z = retrieveGroundZ(createPointWithZOffset(point, 0.25))
  return not z or point.z - z >= MINIMUM_LIFT_HEIGHT
end

function canBeFlown()
  return isFlyingAvailableInZone() and GMR.IsOutdoors()
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
        -- log('waypoint', waypoint.x, waypoint.y, waypoint.z)
        stopMoving = GMR.StopMoving
        GMR.StopMoving = function()
        end
        initialDistance = GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z)
      end

      local playerPosition = retrievePlayerPosition()
      if isPositionInTheAir(waypoint) and canBeFlown() then
        if not isMountedOnFlyingMount() then
          waitForPlayerStandingStill()
          mountOnFlyingMount()
        end
        local playerPosition = retrievePlayerPosition()
        if GMR.IsGroundPosition(playerPosition.x, playerPosition.y, playerPosition.z) then
          liftUp()
        end
      end

      local playerPosition = retrievePlayerPosition()
      if not GMR.IsGroundPosition(playerPosition.x, playerPosition.y, playerPosition.z) then
        -- flying or in water
        if firstRun then
          faceDirection(waypoint)
        end
        if not GMR.IsMoving() then
          GMR.MoveForwardStart()
        end
      else
        if firstRun or not GMR.IsMoving() then
          GMR.MoveTo(waypoint.x, waypoint.y, waypoint.z)
        end
      end

      if not lastJumpTime or GetTime() - lastJumpTime > 1 then
        if (isJumpSituation()) then
          lastJumpTime = GetTime()
          GMR.Jump()
        end
      end

      firstRun = false
    end,
    isDone = function()
      return GMR.IsPlayerPosition(waypoint.x, waypoint.y, waypoint.z, 2)
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
  local playerPosition = retrievePlayerPosition()
  local positionA = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + JUMP_DETECTION_HEIGHT)
  local positionB = positionInFrontOfPlayer(3, JUMP_DETECTION_HEIGHT)
  position1 = positionA
  position2 = positionB
  return thereAreCollisions(
    positionA,
    positionB
  )
end

local function findPathToSavedPosition2()
  local destination = savedPosition
  local pathFinder = createPathFinder()
  debugprofilestart()
  path = pathFinder.start(destination.x, destination.y, destination.z)
  local duration = debugprofilestop()
  -- log(duration)
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
    path = findPathToSavedPosition2()
    if path then
      print('go path')
      movePath(path)
    end
  end)
  return resumeWithShowingError(thread)
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
  return createPoint(playerPosition.x, playerPosition.y, playerPosition.z)
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

function waitForIsInAir()
  return waitFor(function()
    local playerPosition = retrievePlayerPosition()
    return isPositionInTheAir(playerPosition)
  end)
end

function liftUp()
  GMR.MoveForwardStop()
  GMR.JumpOrAscendStart()
  waitForIsInAir()
  GMR.AscendStop()
  waitForPlayerStandingStill()
end

function createPathFinder()
  local shouldStop2 = false

  local a = {
    shouldStop = function()
      return shouldStop2
    end
  }

  return {
    start = function(x, y, z)
      if not GMR.IsMeshLoaded() then
        GMR.LoadMeshFiles()
      end

      local from = retrievePlayerPosition()
      local to = createPoint(x, y, z)
      local continentID = select(8, GetInstanceInfo())
      local x, y, z = GMR.GetClosestPointOnMesh(continentID, from.x, from.y, from.z)
      local x2, y2, z2 = GMR.GetClosestPointOnMesh(continentID, to.x, to.y, to.z)
      if x and y and z and x2 and y2 and z2 then
        local path2 = GMR.GetPathBetweenPoints(x, y, z, x2, y2, z2)
        if path2 then
          path2 = convertGMRPathToPath(path2)
          local path1 = findPath2(from, path2[1], a)
          local path3 = findPath2(path2[#path2], to, a)
          if path1 and path2 and path3 then
            path = Array.concat(path1, path2, path3)
            return path
          end
        else
          return findPath2(from, to, a)
        end
      else
        return findPath2(from, to, a)
      end
      return findPath2(from, to, a)
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

function findPath2(from, to, a)
  return findPathInner(from, to, a, 0)
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
  local point = points[pointIndex]
  return createPoint(point.x, point.y, point.z)
end

local function _retrieveNeighbor(pointIndex)
  return retrievePoint(pointIndex)
end

function retrieveConnections(pointIndex)
  local connections2 = connections[pointIndex]
  if connections2 then
    return Array.map(connections2, function(connection)
      local point = retrievePoint(connection[1])
      if connection[2] then
        if connection[3] then
          return createPointWithPathToAndObjectID(point.x, point.y, point.z, connection[2], connection[3])
        else
          return createPointWithPathTo(point.x, point.y, point.z, connection[2])
        end
      end
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
  local pointIndex = retrieveOrCreatePointIndex(point)
  local neighbours2 = retrieveNeighbors(pointIndex)
  if not neighbours2 then
    neighbours2 = generateNeighborPoints(point)
    storeNeighbors(pointIndex, neighbours2)
  end

  local connections2 = retrieveConnections(pointIndex)

  local navMeshPoints = {}
  local x, y, z = GMR.GetClosestPointOnMesh(GMR.GetMapId(), point.x, point.y, point.z)
  if x and y and z and (x ~= point.x or y ~= point.y or z ~= point.z) then
    table.insert(navMeshPoints, createPoint(x, y, z))
  end

  return Array.concat(navMeshPoints, connections2, neighbours2)
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

function addConnectionFromTo(closestPointOnGridFromFromPoint, from, to)
  addConnectionFromToWithInteractable(closestPointOnGridFromFromPoint, from, to, nil)
end

function addConnectionFromToWithInteractable(closestPointOnGridFromFromPoint, from, to, objectID)
  local closestPointOnGridIndexFromFromPoint = retrieveOrCreatePointIndex(closestPointOnGridFromFromPoint)
  local toPointIndex = retrieveOrCreatePointIndex(to)
  local pathIndex = createPathIndex({ from })
  local connection = {
    toPointIndex,
    pathIndex,
    objectID
  }
  addConnection(closestPointOnGridIndexFromFromPoint, connection)
end

function storeConnection(path)
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

function findPathInner(from, to, a)
  local path
  local generateNeighborPoints2
  local distance = 2
  -- aStarPoints = {}

  generateNeighborPoints2 = function(point)
    local pointIndex = retrieveOrCreatePointIndex(point)
    local connections2 = retrieveConnections(pointIndex)
    local neighborPoints = connections2
    Array.append(neighborPoints, generateNeighborPoints3(point, distance))
    return neighborPoints
  end

  local receiveNeighborPoints = generateNeighborPoints2

  --log('withFlying', withFlying)
  -- local points = receiveNeighborPoints(from)
  -- aStarPoints = points
  --log('points', points)

  path = findPath(
    from,
    to,
    receiveNeighborPoints,
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
    shouldStop = function()
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

-- view distance = 5: 625
-- view distance = 10: 975

function waitForPlayerToBeOnPosition(position, radius)
  radius = radius or 3
  waitFor(function()
    return GMR.IsPlayerPosition(position.x, position.y, position.z, radius)
  end)
end

function faceDirection(point)
  local yielder = createYielder()
  while not GMR.IsFacingXYZ(point.x, point.y, point.z) do
    local previousPlayerFacingAngle = GMR.ObjectRawFacing('player')
    GMR.FaceSmoothly(point.x, point.y, point.z)
    yielder.yield()
    if GMR.ObjectRawFacing('player') == previousPlayerFacingAngle then
      break
    end
  end
  GMR.FaceDirection(point.x, point.y, point.z)
end

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

function closestPointOnGridWithZOnGround(point)
  point = closestPointOnGridWithZLeft(point)
  return createPoint(
    point.x,
    point.y,
    retrieveGroundZ(point)
  )
end

function closestCoordinateOnGrid(coordinate)
  return Math.round(coordinate / GRID_LENGTH) * GRID_LENGTH
end

function convertPointToArray(point)
  return { point.x, point.y, point.z }
end

function convertArrayToPoint(point)
  return createPoint(unpack(point))
end

function convertPathToGMRPath(path)
  return Array.map(path, convertPointToArray)
end

function convertGMRPathToPath(path)
  return Array.map(path, convertArrayToPoint)
end

function moveToSavedPath()
  local thread = coroutine.create(function()
    movePath(path)
  end)
  return resumeWithShowingError(thread)
end

function traceLine(from, to, hitFlags)
  local x, y, z = GMR.TraceLine(
    from.x,
    from.y,
    from.z,
    to.x,
    to.y,
    to.z,
    hitFlags
  )
  if x then
    return createPoint(x, y, z)
  else
    return nil
  end
end

function traceLineCollision(from, to)
  return traceLine(from, to, TraceLineHitFlags.COLLISION)
end

function retrievePositionBetweenPositions(a, b, distanceFromA)
  local x, y, z = GMR.GetPositionBetweenPositions(a.x, a.y, a.z, b.x, b.y, b.z, distanceFromA)
  return createPoint(x, y, z)
end

function generateWalkToPointFromCollisionPoint(from, collisionPoint)
  local pointWithDistanceToCollisionPoint = retrievePositionBetweenPositions(collisionPoint, from, CHARACTER_RADIUS)
  local z = retrieveGroundZ(pointWithDistanceToCollisionPoint)
  return createPoint(pointWithDistanceToCollisionPoint.x, pointWithDistanceToCollisionPoint.y, z)
end

function isFirstPointCloserToThanSecond(fromA, fromB, to)
  return euclideanDistance(fromA, to) < euclideanDistance(fromB, to)
end

function findClosestPointThatCanBeWalkedTo(from, to)
  local walkToPoint = from
  while true do
    local pointOnMaximumWalkUpToHeight = createPointWithZOffset(walkToPoint, MAXIMUM_WALK_UP_TO_HEIGHT)
    local destinationOnMaximumWalkUpToHeight = createPointWithZOffset(to, MAXIMUM_WALK_UP_TO_HEIGHT)
    local collisionPoint = traceLineCollision(pointOnMaximumWalkUpToHeight, destinationOnMaximumWalkUpToHeight)
    if collisionPoint then
      local potentialWalkToPoint = generateWalkToPointFromCollisionPoint(pointOnMaximumWalkUpToHeight,
        collisionPoint)
      if not walkToPoint or isFirstPointCloserToThanSecond(potentialWalkToPoint, walkToPoint, to) then
        walkToPoint = potentialWalkToPoint
      else
        break
      end
    else
      walkToPoint = to
      break
    end
  end

  return walkToPoint
end

function moveTowards(x, y, z)
  local playerPosition = retrievePlayerPosition()
  local destination = createPoint(x, y, z)
  local walkToPoint = findClosestPointThatCanBeWalkedTo(playerPosition, destination)

  if walkToPoint ~= playerPosition then
    GMR.MoveTo(walkToPoint.x, walkToPoint.y, walkToPoint.z)
  end
end

function moveTowardsSavedPosition()
  local thread = coroutine.create(function()
    moveTowards(savedPosition.x, savedPosition.y, savedPosition.z)
  end)
  return resumeWithShowingError(thread)
end

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
    ticker:Cancel()

    -- TODO: Continent ID

    addConnectionFromTo(
      createPoint(
        -1728,
        1284,
        5451.509765625
      ),
      createPoint(
        -1728.5428466797,
        1283.0802001953,
        5451.509765625
      ),
      createPoint(
        -4357.6801757812,
        800.40002441406,
        -40.990001678467
      )
    )

    addConnectionFromToWithInteractable(
      createPoint(
        -4366,
        814,
        -40.849704742432
      ),
      createPoint(
        -4366.2514648438,
        813.20324707031,
        -40.817531585693
      ),
      createPoint(
        -4357.6801757812,
        800.40002441406,
        -40.990001678467
      ),
      373592
    )
  end
end)

--log(closestPointOnGridWithZOnGround(createPoint(
--  -4366.2514648438,
--  813.20324707031,
--  -40.817531585693
--)))
