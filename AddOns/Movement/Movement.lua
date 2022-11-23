Movement = {}

local _ = {}

position1 = nil
position2 = nil
aStarPoints = nil
aStarPoints2 = nil

local DEVELOPMENT = true
local zOffset = 1.6
local MAXIMUM_FALL_HEIGHT = 30
local MAXIMUM_WATER_DEPTH = 1000
local GRID_LENGTH = 2
local MINIMUM_LIFT_HEIGHT = 0.25 -- Minimum flying lift height seems to be ~ 0.25 yards.
local TOLERANCE_RANGE = 0.5
local TARGET_LIFT_HEIGHT = TOLERANCE_RANGE
Movement.MAXIMUM_AIR_HEIGHT = 5000
local walkToPoint = nil
local MAXIMUM_WATER_DEPTH_FOR_WALKING = 1.4872055053711
canBeStoodOnPointCache = PointToValueMap:new()
local canBeStoodWithMountOnPointCache = PointToValueMap:new()
local DISTANCE = GRID_LENGTH
local FEMALE_HUMAN_CHARACTER_HEIGHT = 1.970519900322
Movement.MAXIMUM_RANGE_FOR_TRACE_LINE_CHECKS = 330
lines = {}

local cache = {}

local run = nil
local pathFinder = nil

function Movement.retrieveCharacterBoundingRadius()
  return HWT.UnitBoundingRadius('player')
end

function Movement.retrieveCharacterHeight()
  return HWT.ObjectHeight('player')
end

function Movement.retrieveUnmountedCharacterHeight()
  if IsMounted() then
    return MovementCharacterHeight
  else
    MovementCharacterHeight = Movement.retrieveCharacterHeight()
    return MovementCharacterHeight
  end
end

function Movement.retrieveUnmountedCharacterHeightBestEffort()
  return Movement.retrieveUnmountedCharacterHeight() or FEMALE_HUMAN_CHARACTER_HEIGHT
end

function Movement.addPointToCache(fromX, fromY, fromZ, toX, toY, toZ)
  local a = cache[fromX]
  if not a then
    cache[fromX] = {}
  end
  if not cache[fromX][fromY] then
    cache[fromX][fromY] = {}
  end
  cache[fromX][fromY][fromZ] = { toX, toY, toZ }
end

function Movement.retrievePointFromCache(x, y, z)
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

function Movement.findClosestDifferentPolygon(x, y, z)
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

function Movement.findClosestDifferentPolygonTowardsPosition(x, y, z, x5, y5, z5)
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

doWhenGMRIsFullyLoaded(function()
  GMR.LibDraw.Sync(function()
    Array.forEach(lines, function(line)
      local a = line[1]
      local b = line[2]
      GMR.LibDraw.Line(a.x, a.y, a.z, b.x, b.y, b.z)
    end)

    --if DEVELOPMENT then
    --  if not GMR.IsMeshLoaded() then
    --    GMR.LoadMeshFiles()
    --  end
    --
    --  local continentID = select(8, GetInstanceInfo())
    --
    --  local playerPosition = Movement.retrievePlayerPosition()
    --  if playerPosition then
    --    GMR.LibDraw.SetColorRaw(1, 1, 0, 1)
    --    for y = playerPosition.y - 4, playerPosition.y + 4 do
    --      for x = playerPosition.x - 4, playerPosition.x + 4 do
    --        local x2, y2, z2 = Movement.retrievePointFromCache(x, y, playerPosition.z)
    --        if not x2 then
    --          local z3 = GMR.GetGroundZ(x, y, playerPosition.z) or playerPosition.z
    --          x2, y2, z2 = GMR.GetClosestPointOnMesh(continentID, x, y, z3)
    --          if x2 then
    --            Movement.addPointToCache(x, y, playerPosition.z, x2, y2, z2)
    --          end
    --        end
    --        if x2 then
    --          GMR.LibDraw.Circle(x2, y2, z2, 0.1)
    --        end
    --      end
    --    end
    --  end
    --end

    --
    --      local playerPosition = retrievePlayerPosition()
    --      if playerPosition then
    --        local x2, y2, z2 = GMR.ObjectPosition('target')
    --        if x2 then
    --          local id, x, y, z, d = Movement.findClosestDifferentPolygonTowardsPosition(playerPosition.x, playerPosition.y,
    --            playerPosition.z, x2, y2, z2)
    --          if x then
    --            GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
    --            GMR.LibDraw.Circle(x, y, z, 4)
    --          end
    --        end
    --      end
    --
    if DEVELOPMENT then
      if savedPosition then
        GMR.LibDraw.SetColorRaw(1, 1, 0, 1)
        GMR.LibDraw.Circle(savedPosition.x, savedPosition.y, savedPosition.z, 0.5)
      end
    end
    --      --if walkToPoint then
    --      --  GMR.LibDraw.Circle(walkToPoint.x, walkToPoint.y, walkToPoint.z, 0.5)
    --      --end
    if DEVELOPMENT then
      if position1 and position2 then
        GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
        GMR.LibDraw.Line(
          position1.x,
          position1.y,
          position1.z,
          position2.x,
          position2.y,
          position2.z
        )
      end
    end

    local path = MovementPath
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
        GMR.LibDraw.Circle(point.x, point.y, point.z, Movement.retrieveCharacterBoundingRadius())
        previousPoint = point
      end
      local firstPoint = path[1]
      local lastPoint = path[#path]
      GMR.LibDraw.Circle(firstPoint.x, firstPoint.y, firstPoint.z, Movement.retrieveCharacterBoundingRadius())
      GMR.LibDraw.Circle(lastPoint.x, lastPoint.y, lastPoint.z, Movement.retrieveCharacterBoundingRadius())
    end

    if DEVELOPMENT then
      if aStarPoints then
        GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
        local radius = GRID_LENGTH / 2
        Array.forEach(aStarPoints, function(point)
          GMR.LibDraw.Circle(point.x, point.y, point.z, radius)
        end)
      end
    end

    --if DEVELOPMENT then
    --  if sellVendors then
    --    GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
    --    local radius = 0.75
    --    Array.forEach(sellVendors, function(point)
    --      local pointer = GMR.FindObject(point[4])
    --      if pointer then
    --        local x, y, z = GMR.ObjectPosition(pointer)
    --        GMR.LibDraw.Circle(x, y, z, radius)
    --      else
    --        GMR.LibDraw.Circle(point[1], point[2], point[3], radius)
    --      end
    --    end)
    --  end
    --end
    --
    --      if aStarPoints2 then
    --        GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
    --        Array.forEach(aStarPoints2, function(point)
    --          GMR.LibDraw.Circle(point.x, point.y, point.z, 0.1)
    --        end)
    --      end

    -- Visualization for maximum steepness
    --GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
    --local distance = CHARACTER_RADIUS
    --local point = Movement.positionInFrontOfPlayer(distance, 2)
    --local point2 = Movement.positionInFrontOfPlayer(distance, 0)
    --local collisionPoint = Movement.traceLineCollision(point, point2)
    --if collisionPoint then
    --  drawLine(point, collisionPoint)
    --  local playerPosition = Movement.retrievePlayerPosition()
    --  local height = collisionPoint.z - playerPosition.z
    --  print(height)
    --else
    --  drawLine(point, point2)
    --end
  end)
end)

function drawLine(from, to)
  GMR.LibDraw.Line(from.x, from.y, from.z, to.x, to.y, to.z)
end

function Movement.savePosition1()
  position1 = GMR.GetPlayerPosition()
end

function Movement.savePosition2()
  position2 = GMR.GetPlayerPosition()
end

function Movement.savePosition()
  local playerPosition = GMR.GetPlayerPosition()
  savedPosition = createPoint(playerPosition.x, playerPosition.y, playerPosition.z)
end

Movement.TraceLineHitFlags = {
  COLLISION = 1048849,
  WATER = 131072,
  WATER2 = 65536
}

function Movement.positionInFrontOfPlayer(distance, deltaZ)
  local playerPosition = Movement.retrievePlayerPosition()
  return createPoint(
    GMR.GetPositionFromPosition(
      playerPosition.x,
      playerPosition.y,
      playerPosition.z + (deltaZ or 0),
      distance,
      GMR.ObjectRawFacing('player'),
      GMR.GetPitch('player')
    )
  )
end

function Movement.positionInFrontOfPlayer2(distance, deltaZ)
  local playerPosition = Movement.retrievePlayerPosition()
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

function Movement.calculateIsObstacleInFrontToPosition(position)
  return createPoint(GMR.GetPositionFromPosition(position.x, position.y, position.z, 5,
    GMR.ObjectRawFacing('player'),
    0))
end

function Movement.isObstacleInFront(position)
  position1 = createPoint(
    position.x,
    position.y,
    position.z + zOffset
  )
  position2 = Movement.calculateIsObstacleInFrontToPosition(position1)
  return not Movement.thereAreZeroCollisions(position1, position2)
end

function Movement.canWalkTo(position)
  local playerPosition = GMR.GetPlayerPosition()
  local fromPosition = createPoint(
    playerPosition.x,
    playerPosition.y,
    playerPosition.z + zOffset
  )
  return Movement.thereAreZeroCollisions(fromPosition, position)
end

function Movement.canBeMovedFromPointToPoint(from, to)
  local a = Movement.canBeWalkedOrSwamFromPointToPoint(from, to)
  local b = Movement.canBeJumpedFromPointToPoint(from, to)
  local c = Movement.canBeFlownFromPointToPoint(from, to)
  print(a, b, c)
  return a or b or c
end

function Movement.isEnoughSpaceOnTop(from, to)
  local offset = 0.1
  local characterHeight = Movement.retrieveCharacterHeightForHeightCheck()
  local a = Movement.thereAreZeroCollisions(
    Movement.createPointWithZOffset(from, offset),
    Movement.createPointWithZOffset(from, characterHeight)
  )
  local b = Movement.thereAreZeroCollisions(
    Movement.createPointWithZOffset(to, offset),
    Movement.createPointWithZOffset(to, characterHeight)
  )

  local c = Movement.thereAreZeroCollisions2(Movement.createPointWithZOffset(from, offset),
    Movement.createPointWithZOffset(to, offset), characterHeight - offset)
  return a and b and c
end

function Movement.thereAreZeroCollisions2(from, to, zHeight, track)
  local function thereAreZeroCollisions(zOffset)
    return Movement.thereAreZeroCollisions(
      Movement.createPointWithZOffset(from, zOffset),
      Movement.createPointWithZOffset(to, zOffset),
      track
    )
  end
  local interval = 1
  return Array.isTrueForAllInInterval(0, zHeight, interval, thereAreZeroCollisions) and
    (zHeight % interval == 0 or thereAreZeroCollisions(zHeight))
end

function Movement.thereAreZeroCollisions3(from, to, zHeight)
  return (
    Movement.thereAreZeroCollisions2(from, to, zHeight, true) and
      Movement.thereAreZeroCollisions4(from, to, zHeight, true) and
      Movement.thereAreZeroCollisions5(from, to, zHeight, true)
  )
end

function Movement.thereAreZeroCollisions4(from, to, zHeight)
  local from2 = createPoint(
    GMR.GetPositionFromPosition(
      from.x,
      from.y,
      from.z,
      Movement.retrieveCharacterBoundingRadius(),
      Movement.calculateAngleBetweenTwoPoints(from, to) + 0.5 * PI,
      0
    )
  )
  local to2 = createPoint(
    GMR.GetPositionFromPosition(
      to.x,
      to.y,
      to.z,
      Movement.retrieveCharacterBoundingRadius(),
      Movement.calculateAngleBetweenTwoPoints(from, to) + 0.5 * PI,
      0
    )
  )
  return Movement.thereAreZeroCollisions2(from2, to2, zHeight, true)
end

function Movement.thereAreZeroCollisions5(from, to, zHeight)
  local from2 = createPoint(
    GMR.GetPositionFromPosition(
      from.x,
      from.y,
      from.z,
      Movement.retrieveCharacterBoundingRadius(),
      Movement.calculateAngleBetweenTwoPoints(from, to) - 0.5 * PI,
      0
    )
  )
  local to2 = createPoint(
    GMR.GetPositionFromPosition(
      to.x,
      to.y,
      to.z,
      Movement.retrieveCharacterBoundingRadius(),
      Movement.calculateAngleBetweenTwoPoints(from, to) - 0.5 * PI,
      0
    )
  )
  return Movement.thereAreZeroCollisions2(from2, to2, zHeight, true)
end

function Movement.calculateAngleBetweenTwoPoints(a, b)
  return GMR.GetAnglesBetweenPositions(a.x, a.y, a.z, b.x, b.y, b.z)
end

Movement.MAXIMUM_WALK_UP_TO_HEIGHT = 0.94
Movement.JUMP_DETECTION_HEIGHT = Movement.MAXIMUM_WALK_UP_TO_HEIGHT + 0.01
Movement.MAXIMUM_JUMP_HEIGHT = 1.675

function Movement.canBeWalkedOrSwamFromPointToPoint(from, to)
  print('a', Movement.canPlayerStandOnPoint(to))
  print('e', Movement.canBeMovedFromPointToPointCheckingSubSteps(from, to))
  return (
    (Movement.isPointInDeepWater(to) or Movement.canPlayerStandOnPoint(to)) and
      Movement.canBeMovedFromPointToPointCheckingSubSteps(from, to)
  )
end

function Movement.canBeMovedFromPointToPointCheckingSubSteps(from, to)
  if from.x == to.x and from.y == to.y then
    print(1)
    return (
      (to.z - from.z <= Movement.MAXIMUM_WALK_UP_TO_HEIGHT or (Movement.isPointInDeepWater(from) and Movement.isPointInDeepWater(to))) and
        Movement.thereAreZeroCollisions(Movement.createPointWithZOffset(from, 0.1), to)
    )
  end

  local totalDistance = euclideanDistance(from, to)

  local point1 = from
  local stepSize = 1
  local distance = stepSize
  while distance < totalDistance do
    local x, y, z = GMR.GetPositionBetweenPositions(from.x, from.y, from.z, to.x, to.y, to.z, distance)
    local point2 = createPoint(x, y, z)

    if not (Movement.isPointInDeepWater(point1) and Movement.isPointInDeepWater(point2)) then
      local z = Movement.retrieveGroundZ(createPoint(point2.x, point2.y, point1.z))

      if not z then
        print(2)
        return false
      end

      point2 = createPoint(x, y, z)

      local maximumDeltaZ = _.determineMaximumDeltaZ(point1, point2)

      if point1.x == x and point1.y == y then
        print(3)
        return z - point1.z <= maximumDeltaZ
      end

      if not (z - point1.z <= maximumDeltaZ) then
        print(4)
        return false
      end
    end

    if not Movement.thereAreZeroCollisions3(
      Movement.createPointWithZOffset(point1, Movement.MAXIMUM_WALK_UP_TO_HEIGHT),
      Movement.createPointWithZOffset(point2, Movement.MAXIMUM_WALK_UP_TO_HEIGHT),
      Movement.retrieveUnmountedCharacterHeightBestEffort() - Movement.MAXIMUM_WALK_UP_TO_HEIGHT
    ) then
      print(5)
      return false
    end

    point1 = point2
    distance = distance + stepSize
  end

  local maximumDeltaZ = _.determineMaximumDeltaZ(point1, to)
  print(6, 1, to.z - point1.z, maximumDeltaZ)
  print(6, 2, Movement.isPointInDeepWater(point1), Movement.isPointInDeepWater(to))
  if not (to.z - point1.z <= maximumDeltaZ or (Movement.isPointInDeepWater(point1) and Movement.isPointInDeepWater(to))) then
    print(6)
    return false
  end

  if not Movement.thereAreZeroCollisions3(
    Movement.createPointWithZOffset(point1, Movement.MAXIMUM_WALK_UP_TO_HEIGHT),
    Movement.createPointWithZOffset(to, Movement.MAXIMUM_WALK_UP_TO_HEIGHT),
    Movement.retrieveUnmountedCharacterHeightBestEffort() - Movement.MAXIMUM_WALK_UP_TO_HEIGHT
  ) then
    print(7)
    return false
  end

  return true
end

function _.determineMaximumDeltaZ(from, to)
  local maximumDeltaZ
  print('Movement.isPointInWater(from)', Movement.isPointInOrSlightlyAboveWater(from))
  print('Movement.isPointInWater(to)', Movement.isPointInOrSlightlyAboveWater(to))
  if Movement.isPointInOrSlightlyAboveWater(from) and Movement.isPointInOrSlightlyAboveWater(to) then
    maximumDeltaZ = Movement.retrieveCharacterHeight()
  else
    maximumDeltaZ = Movement.MAXIMUM_WALK_UP_TO_HEIGHT
  end
  return maximumDeltaZ
end

function Movement.canBeJumpedFromPointToPoint(from, to)
  return (
    Movement.isPointOnGround(from) and
      (Movement.isPointInDeepWater(to) or (Movement.isPointOnGround(to) and Movement.canPlayerStandOnPoint(to))) and
      to.z - from.z <= Movement.MAXIMUM_JUMP_HEIGHT and
      not _.thereAreCollisions2(
        Movement.createPointWithZOffset(from, Movement.MAXIMUM_JUMP_HEIGHT),
        Movement.createPointWithZOffset(to, Movement.MAXIMUM_JUMP_HEIGHT)
      )
  )
end

function Movement.retrievePlayerPosition()
  local playerPosition = GMR.GetPlayerPosition()
  if playerPosition then
    return createPoint(playerPosition.x, playerPosition.y, playerPosition.z)
  else
    return nil
  end
end

function Movement.canBeFlownFromPointToPoint(from, to)
  local playerPosition = Movement.retrievePlayerPosition()
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
  local a = Movement.isFlyingAvailableInZone() and Movement.canCharacterFly()
  local b = Movement.isEnoughSpaceOnTop(from, to)
  local c = Movement.canPlayerBeOnPoint(to, { withMount = true })
  return a and b and c
end

function Movement.canPlayerBeOnPoint(point, options)
  options = options or {}

  local pointALittleBitOver = Movement.createPointWithZOffset(point, 0.1)
  local pointOnMaximumWalkUpToHeight = Movement.createPointWithZOffset(
    point,
    Movement.MAXIMUM_WALK_UP_TO_HEIGHT
  )
  local pointALittleBitOverMaximumWalkUpToHeight = Movement.createPointWithZOffset(pointOnMaximumWalkUpToHeight, 0.1)
  local pointOnCharacterHeight = Movement.createPointWithZOffset(point,
    Movement.retrieveUnmountedCharacterHeightBestEffort())

  local function areThereZeroCollisionsAround()
    local points = Movement.generatePointsAround(pointALittleBitOverMaximumWalkUpToHeight,
      Movement.retrieveCharacterBoundingRadius(), 8)
    print('c', 1)
    return Array.all(points, function(point)
      return Movement.thereAreZeroCollisions(pointALittleBitOverMaximumWalkUpToHeight, point)
    end)
  end

  print('D', Movement.thereAreZeroCollisions(pointOnMaximumWalkUpToHeight, pointALittleBitOver),
    Movement.thereAreZeroCollisions(pointALittleBitOverMaximumWalkUpToHeight, pointOnCharacterHeight),
    areThereZeroCollisionsAround())
  local result = (
    Movement.thereAreZeroCollisions(pointOnMaximumWalkUpToHeight, pointALittleBitOver) and
      Movement.thereAreZeroCollisions(pointALittleBitOverMaximumWalkUpToHeight, pointOnCharacterHeight) and
      areThereZeroCollisionsAround()
  )

  print('c', 2)
  return result
end

function _.canPlayerBeOnPoint2(point, options)
  options = options or {}

  if Movement.isPositionInRangeForTraceLineChecks(point) then
    local pointALittleBitAbove = Movement.traceLineCollisionWithFallback(
      Movement.createPointWithZOffset(point, TOLERANCE_RANGE),
      point
    )
    if pointALittleBitAbove and pointALittleBitAbove.z > point.z then
      point = pointALittleBitAbove
    end

    local pointALittleBitOver = Movement.createPointWithZOffset(point, 0.1)
    local pointOnMaximumWalkUpToHeight = Movement.createPointWithZOffset(
      point,
      Movement.MAXIMUM_WALK_UP_TO_HEIGHT
    )
    local pointALittleBitOverMaximumWalkUpToHeight = Movement.createPointWithZOffset(pointOnMaximumWalkUpToHeight, 0.1)
    local pointOnCharacterHeight = Movement.createPointWithZOffset(point,
      Movement.retrieveUnmountedCharacterHeightBestEffort())

    local function areThereZeroCollisionsAround()
      local points = Movement.generatePointsAround(pointALittleBitOverMaximumWalkUpToHeight,
        Movement.retrieveCharacterBoundingRadius(), 8)
      print('c', 1)
      return Array.all(points, function(point)
        return Movement.thereAreZeroCollisions(pointALittleBitOverMaximumWalkUpToHeight, point)
      end)
    end

    print('D', Movement.thereAreZeroCollisions(pointOnMaximumWalkUpToHeight, pointALittleBitOver),
      Movement.thereAreZeroCollisions(pointALittleBitOverMaximumWalkUpToHeight, pointOnCharacterHeight),
      areThereZeroCollisionsAround())
    local result = (
      Movement.thereAreZeroCollisions(pointOnMaximumWalkUpToHeight, pointALittleBitOver) and
        Movement.thereAreZeroCollisions(pointALittleBitOverMaximumWalkUpToHeight, pointOnCharacterHeight) and
        areThereZeroCollisionsAround()
    )

    print('c', 2)
    return result
  else
    local closestPointOnMesh = Movement.retrieveClosestPointOnMesh(Movement.createPositionFromPoint(Movement.retrieveContinentID(),
      point.x, point.y, point.z))
    if closestPointOnMesh and Float.seemsCloseBy(closestPointOnMesh.x,
      point.x) and Float.seemsCloseBy(closestPointOnMesh.y, point.y) then
      return math.abs(closestPointOnMesh.z - point.z) <= TOLERANCE_RANGE
    end
  end

  return nil
end

function Movement.retrieveContinentID()
  local continentID = select(8, GetInstanceInfo())
  return continentID
end

function Movement.canPlayerStandOnPoint(point, options)
  options = options or {}

  if Movement.isPositionInRangeForTraceLineChecks(point) then
    if options.withMount then
      local value = canBeStoodWithMountOnPointCache:retrieveValue(point)
      if value ~= nil then
        print(1)
        return value
      end
    else
      local value = canBeStoodOnPointCache:retrieveValue(point)
      if value ~= nil then
        print(2)
        return value
      end
    end

    local pointOnMaximumWalkUpToHeight = Movement.createPointWithZOffset(
      point,
      Movement.MAXIMUM_WALK_UP_TO_HEIGHT
    )
    local pointALittleBitOverMaximumWalkUpToHeight = Movement.createPointWithZOffset(pointOnMaximumWalkUpToHeight, 0.1)

    local function canFallOff()
      local pointALittleBitUnderPoint = Movement.createPointWithZOffset(point, -0.1)
      local standOnPoint = Movement.traceLineCollisionWithFallback(
        pointALittleBitOverMaximumWalkUpToHeight,
        pointALittleBitUnderPoint
      )
      if standOnPoint then
        local MAXIMUM_STEEPNESS_HEIGHT = 0.55436325073242
        local points = Movement.generatePointsAround(standOnPoint, Movement.retrieveCharacterBoundingRadius(), 8)
        return not Array.all(points, function(point)
          local point1 = Movement.createPointWithZOffset(point, Movement.MAXIMUM_WALK_UP_TO_HEIGHT)
          print(3)
          return Movement.thereAreCollisions(
            point1,
            Movement.createPointWithZOffset(
              point1,
              -(MAXIMUM_STEEPNESS_HEIGHT + 0.00000000000001 + Movement.MAXIMUM_WALK_UP_TO_HEIGHT)
            )
          )
        end)
      else
        print(4)
        return false
      end
    end

    print('b', _.canPlayerBeOnPoint2(point, options))
    local result = (
      _.canPlayerBeOnPoint2(point, options) and
        not canFallOff()
    )

    if options.withMount then
      canBeStoodWithMountOnPointCache:setValue(point, result)
    else
      canBeStoodOnPointCache:setValue(point, result)
    end

    print(5)
    return result
  else
    return nil
  end
end

function Movement.isFlyingAvailableInZone()
  return IsFlyableArea()
end

local EXPERT_RIDING = 34092

function Movement.canCharacterFly()
  return toBoolean(GMR.IsSpellKnown(EXPERT_RIDING) and Movement.isAFlyingMountAvailable())
end

function Movement.receiveAvailableMountIDs()
  local mountIDs = C_MountJournal.GetMountIDs()
  return Array.filter(mountIDs, function(mountID)
    local isUsable = select(5, C_MountJournal.GetMountInfoByID(mountID))
    return isUsable
  end)
end

function Movement.isAFlyingMountAvailable()
  local mountIDs = Movement.receiveAvailableMountIDs()
  return Array.any(mountIDs, Movement.isFlyingMount)
end

function Movement.isAGroundMountAvailable()
  local mountIDs = Movement.receiveAvailableMountIDs()
  return Array.any(mountIDs, Movement.isGroundMount)
end

function Movement.receiveAnAvailableFlyingMount()
  local mountIDs = Movement.receiveAvailableMountIDs()
  local mountID = Array.find(mountIDs, Movement.isFlyingMount)
  return mountID
end

function Movement.receiveAnAvailableGroundMount()
  local isUsable = select(5, C_MountJournal.GetMountInfoByID(1434))
  if isUsable then
    return 1434 -- This one is also faster in water
  end

  local mountIDs = Movement.receiveAvailableMountIDs()
  local mountID = Array.find(mountIDs, Movement.isGroundMount)
  return mountID
end

-- TODO: Water mounts. See https://wowpedia.fandom.com/wiki/API_C_MountJournal.GetMountInfoExtraByID (mountTypeID).

local underWaterMountTypeIDs = Set.create({
  231,
  232,
  254,
  407
})

local onWaterMountTypeIDs = Set.create({
  269
})

local flyingMountTypeIDs = Set.create({
  242,
  247,
  248,
  407
})

function Movement.isFlyingMount(mountID)
  local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))
  return Set.contains(flyingMountTypeIDs, mountTypeID)
end

local groundMountTypeIDs = Set.create({
  230,
  247,
  248,
  269,
  284,
  398,
  407,
  408
})

function Movement.isGroundMount(mountID)
  local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))
  return Set.contains(groundMountTypeIDs, mountTypeID)
end

function Movement.retrieveGroundZ(position)
  local position1 = createPoint(position.x, position.y, position.z + Movement.MAXIMUM_JUMP_HEIGHT)
  local position2 = createPoint(position.x, position.y, position.z - 10)
  local collisionPoint = Movement.traceLineCollisionWithFallback(position1, position2)
  if not collisionPoint then
    -- There seemed to be one case where no z was returned at a position, even though it looked like that there was
    -- a surface.
    local offset = 0.6
    position1 = createPoint(position1.x + offset, position1.y + offset, position.z)
    position2 = createPoint(position2.x + offset, position2.y + offset, position2.z)
    collisionPoint = Movement.traceLineCollisionWithFallback(position1, position2)
  end

  if collisionPoint then
    return collisionPoint.z
  else
    return nil
  end
end

function Movement.isPositionFarerAwayThanMaxiumRangeForTraceLineChecks(position)
  return not Movement.isPositionInRangeForTraceLineChecks(position)
end

function Movement.isPositionInRangeForTraceLineChecks(position)
  return GMR.GetDistanceToPosition(position.x, position.y, position.z) <= Movement.MAXIMUM_RANGE_FOR_TRACE_LINE_CHECKS
end

function Movement.retrieveGroundZ2(position)
  local collisionPoint = Movement.traceLineCollisionWithFallback(position,
    Movement.createPointWithZOffset(position, -Movement.MAXIMUM_AIR_HEIGHT))
  if collisionPoint then
    return collisionPoint.z
  else
    return nil
  end
end

function Movement.thereAreCollisions(a, b, track)
  if track then
    table.insert(lines, { a, b })
  end
  local collisionPoint = Movement.traceLineCollisionWithFallback(a, b)
  return toBoolean(collisionPoint)
end

function Movement.thereAreZeroCollisions(a, b, track)
  if track then
    -- table.insert(lines, {a, b})
  end
  return not Movement.thereAreCollisions(a, b)
end

function Movement.isObstacleInFrontOfPlayer()
  local playerPosition = GMR.GetPlayerPosition()
  return Movement.isObstacleInFront(playerPosition)
end

function Movement.generateWaypoint()
  local playerPosition = GMR.GetPlayerPosition()
  return createPoint(
    GMR.GetPositionFromPosition(
      playerPosition.x, playerPosition.y, playerPosition.z, 5, GMR.ObjectRawFacing('player'), 0
    )
  )
end

function Movement.generateAngles(numberOfAngles)
  local angles = {}
  local angle = 0
  local delta = 2 * PI / numberOfAngles
  for i = 1, numberOfAngles do
    table.insert(angles, angle)
    angle = angle + delta
  end
  return angles
end

function Movement.generatePoints(fromPosition, distance, angles)
  return Array.map(angles, function(angle)
    return Movement.generatePoint(fromPosition, distance, angle)
  end)
end

function Movement.generateMiddlePointsAround(fromPosition, distance)
  return Array.selectTrue(Movement.generatePointsAroundOnGrid(fromPosition, distance, Movement.generateMiddlePoint))
end

function Movement.generateAbovePointsAround(fromPosition, distance)
  local points = {}
  local abovePoint = Movement.closestPointOnGrid(Movement.createPointWithZOffset(fromPosition, distance))
  table.insert(points, abovePoint)
  Array.append(points,
    Array.selectTrue(Movement.generatePointsAroundOnGrid(abovePoint, distance, Movement.generateAbovePoint)))
  return points
end

function Movement.generateBelowPointsAround(fromPosition, distance)
  local points = {}
  local belowPoint = Movement.closestPointOnGrid(Movement.createPointWithZOffset(fromPosition, -distance))
  table.insert(points, belowPoint)
  Array.append(points,
    Array.selectTrue(Movement.generatePointsAroundOnGrid(belowPoint, distance, Movement.generateBelowPoint)))
  return points
end

function Movement.generatePointsAroundOnGrid(fromPosition, distance, generatePoint)
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

function Movement.generateMiddlePoint(fromPosition, offsetX, offsetY)
  local point2 = Movement.closestPointOnGrid(
    createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
  )
  local isInAir = Movement.isPointInAir(point2)
  if isInAir and Movement.canCharacterFly() then
    local point3 = {
      x = point2.x,
      y = point2.y,
      z = point2.z,
      isInAir = isInAir
    }
    return point3
  elseif Movement.isPointInDeepWater(point2) then
    return point2
  else
    local point = Movement.closestPointOnGridWithZLeft(
      createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
    )
    local z2 = Movement.retrieveGroundZ(point)
    if z2 == nil then
      return nil
    end
    return createPoint(point.x, point.y, z2)
  end
end

function Movement.generateAbovePoint(fromPosition, offsetX, offsetY)
  local point = createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
  return {
    x = point.x,
    y = point.y,
    z = point.z,
    isInAir = Movement.isPointInAir(point)
  }
end

function Movement.generateBelowPoint(fromPosition, offsetX, offsetY)
  local point = createPoint(fromPosition.x + offsetX, fromPosition.y + offsetY, fromPosition.z)
  return {
    x = point.x,
    y = point.y,
    z = point.z,
    isInAir = Movement.isPointInAir(point)
  }
end

function Movement.generatePoint(fromPosition, distance, angle)
  local x, y, z = GMR.GetPositionFromPosition(fromPosition.x, fromPosition.y, fromPosition.z, distance, angle, 0)
  return createPoint(x, y, z)
end

function Movement.receiveWaterSurfacePoint(point)
  local waterSurfacePoint = Movement.traceLineWater(Movement.createPointWithZOffset(point, MAXIMUM_WATER_DEPTH), point)
  if waterSurfacePoint then
    return waterSurfacePoint
  else
    position1 = point
    position2 = Movement.createPointWithZOffset(point, -Movement.MAXIMUM_AIR_HEIGHT)
    return Movement.traceLineWater(point, Movement.createPointWithZOffset(point, -Movement.MAXIMUM_AIR_HEIGHT))
  end
end

function Movement.isPointInWater(point)
  -- local waterSurfacePoint = Movement.receiveWaterSurfacePoint(point)
  -- return toBoolean(waterSurfacePoint and waterSurfacePoint.z >= point.z)
  return toBoolean(GMR.IsPositionUnderwater(point.x, point.y, point.z))
end

function Movement.isPointInOrSlightlyAboveWater(point)
  return Movement.isPointInWater(point) or Movement.isPointSlightlyAboveWater(point)
end

function Movement.isPointSlightlyAboveWater(point)
  local waterSurfacePoint = Movement.receiveWaterSurfacePoint(point)
  print('aa', waterSurfacePoint and point.z - waterSurfacePoint.z)
  return waterSurfacePoint and point.z - waterSurfacePoint.z <= 1
end

function Movement.isPointInDeepWater(point)
  return toBoolean(GMR.IsPositionUnderwater(point.x, point.y, point.z)) and Movement.isWaterDeepAt(point)
end

function Movement.isWaterDeepAt(point)
  local waterDepth = Movement.determineWaterDepth(point)
  if waterDepth then
    return waterDepth > MAXIMUM_WATER_DEPTH_FOR_WALKING
  else
    return nil
  end
end

function Movement.determineWaterDepth(point)
  local waterSurfacePoint = Movement.receiveWaterSurfacePoint(point)
  if waterSurfacePoint then
    local groundPoint = Movement.retrieveGroundPointInWater(waterSurfacePoint)
    if groundPoint then
      return euclideanDistance(waterSurfacePoint, groundPoint)
    end
  end

  return nil
end

function Movement.retrieveGroundPointInWater(point)
  local deepPoint = Movement.createPointWithZOffset(point, -MAXIMUM_WATER_DEPTH)
  local collisionPoint = Movement.traceLineCollision(point, deepPoint)
  if collisionPoint then
    return collisionPoint
  else
    return deepPoint
  end
end

function Movement.generateNeighborPoints(fromPosition, distance)
  local points = Movement.generateNeighborPointsAround(fromPosition, distance)
  -- aStarPoints = points
  return Array.filter(points, function(point)
    return Movement.canBeMovedFromPointToPoint(fromPosition, point)
  end)
end

function Movement.generateNeighborPointsBasedOnNavMesh(fromPosition, distance)
  local points = Movement.generateMiddlePointsAround(fromPosition, distance)
  local continentID = select(8, GetInstanceInfo())
  local maxDistance = math.sqrt(2 * math.pow(distance, 2))
  return Array.selectTrue(Array.map(points, function(point)
    local x, y, z = GMR.GetClosestPointOnMesh(continentID, point.x, point.y, point.z)
    if x then
      local point = createPoint(x, y, z)
      if euclideanDistance2D(fromPosition, point) <= maxDistance and Movement.canBeMovedFromAToB(fromPosition,
        point) then
        return point
      end
    end

    return nil
  end))
end

function Movement.canBeMovedFromAToB(from, to)
  return (
    to.z - from.z <= Movement.MAXIMUM_JUMP_HEIGHT and
      Movement.thereAreZeroCollisions(
        Movement.createPointWithZOffset(from, Movement.MAXIMUM_WALK_UP_TO_HEIGHT + 0.1),
        Movement.createPointWithZOffset(to, Movement.MAXIMUM_WALK_UP_TO_HEIGHT + 0.1)
      )
  )
end

function Movement.generatePointsAround(position, distance, numberOfAngles)
  local angles = Movement.generateAngles(numberOfAngles)
  local points = Movement.generatePoints(position, distance, angles)
  return points
end

function Movement.createPointWithZOffset(point, zOffset)
  return createPoint(point.x, point.y, point.z + zOffset)
end

function Movement.generateNeighborPointsAround(position, distance)
  local a = Movement.generateMiddlePointsAround(position, distance)
  local b = Movement.generateAbovePointsAround(position, distance)
  local c = Movement.generateBelowPointsAround(position, distance)
  -- aStarPoints = a
  return Array.concat(
    a,
    b,
    c
  )
end

function Movement.isPositionInTheAir(position)
  return Movement.isPointInAir(position)
end

function Movement.isPositionLessOffGroundThanTheMaximum(position, maximumOffGroundDistance)
  local groundZ = Movement.retrieveGroundZ(position)
  return not groundZ or position.z - groundZ <= maximumOffGroundDistance
end

function Movement.isPointInAir(point)
  local z = Movement.retrieveGroundZ(Movement.createPointWithZOffset(point, 0.25))
  return not z or point.z - z >= MINIMUM_LIFT_HEIGHT
end

function Movement.isPointOnGround(point)
  local z = Movement.retrieveGroundZ(Movement.createPointWithZOffset(point, 0.25))
  if z then
    return math.abs(z - point.z) <= 0.0002
  else
    return false
  end
end

function Movement.canBeFlown()
  return Movement.isFlyingAvailableInZone() and GMR.IsOutdoors() and Movement.canCharacterFly()
end

function Movement.canBeGroundMounted()
  return GMR.IsOutdoors()
end

function Movement.canMountOnFlyingMount()
  return toBoolean(
    GMR.IsAlive('player') and
      Movement.canBeFlown() and
      Movement.isAFlyingMountAvailable() and
      Movement.canPlayerStandOnPoint(Movement.retrievePlayerPosition(), { withMount = true })
  )
end

function Movement.canMountOnGroundMount()
  return toBoolean(
    GMR.IsAlive('player') and
      Movement.canBeGroundMounted() and
      Movement.isAGroundMountAvailable() and
      Movement.canPlayerStandOnPoint(Movement.retrievePlayerPosition(), { withMount = true })
  )
end

function Movement.distanceOfPointToLine(point, line)
  local A = line[1]
  local B = line[2]

  local BA = Vector:new(
    point.x - A.x,
    point.y - A.y,
    point.z - A.z
  )

  local BC = Vector:new(
    B.x - A.x,
    B.y - A.y,
    B.z - A.z
  )

  return BA:cross(BC):magnitude() / BC:magnitude()
end

function Movement.canReachWaypointWithCurrentMovementDirection(waypoint)
  local playerPosition = Movement.retrievePlayerPosition()
  local pitch = GMR.GetPitch('player')
  local yaw = GMR.ObjectRawFacing('player')
  local movementVector = {
    x = math.cos(yaw) * math.cos(pitch),
    y = math.sin(yaw) * math.cos(pitch),
    z = math.sin(pitch),
  }
  local positionB = {
    x = playerPosition.x + movementVector.x,
    y = playerPosition.y + movementVector.y,
    z = playerPosition.z + movementVector.z
  }
  return Movement.distanceOfPointToLine(waypoint, { playerPosition, positionB }) <= TOLERANCE_RANGE
end

function Movement.isCharacterFlying()
  return Movement.isMountedOnFlyingMount() and Movement.isCharacterInTheAir()
end

function Movement.isCharacterInTheAir()
  local playerPosition = Movement.retrievePlayerPosition()
  return Movement.isPositionInTheAir(playerPosition)
end

function Movement.createMoveToAction3(waypoint, continueMoving, a, totalDistance, isLastWaypoint)
  local firstRun = true
  local initialDistance = nil
  local lastJumpTime = nil

  return {
    run = function(action, actionSequenceDoer)
      if not actionSequenceDoer.mounter then
        actionSequenceDoer.mounter = _.Mounter:new()
      end

      if firstRun then
        -- log('waypoint', waypoint.x, waypoint.y, waypoint.z)
        initialDistance = GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z)
      end

      local playerPosition = Movement.retrievePlayerPosition()

      if totalDistance > 10 and (not actionSequenceDoer.lastTimeDismounted or GetTime() - actionSequenceDoer.lastTimeDismounted >= 3) then
        actionSequenceDoer.mounter:mount()
      end

      local playerPosition = Movement.retrievePlayerPosition()
      if (
        Movement.canBeFlown() and
          Movement.isMountedOnFlyingMount() and
          (totalDistance > 10 or Movement.isPositionInTheAir(waypoint)) and
          (Movement.isPointOnGround(playerPosition) or (Movement.isPointInDeepWater(playerPosition) and not Movement.isPointInDeepWater(waypoint))) and
          (not isLastWaypoint or Movement.isPositionInTheAir(waypoint))
      ) then
        Movement.liftUp()
      end

      if _.areConditionsMetForFacingWaypoint(waypoint) then
        _.faceWaypoint(action, waypoint)
      end

      if not GMR.IsMoving() then
        GMR.MoveForwardStart()
      end

      if Movement.isSituationWhereCharacterMightOnlyFitThroughDismounted() then
        Movement.dismount()
        actionSequenceDoer.lastTimeDismounted = GetTime()
      end

      if not lastJumpTime or GetTime() - lastJumpTime > 1 then
        if (Movement.isJumpSituation(waypoint)) then
          lastJumpTime = GetTime()
          GMR.Jump()
        end
      end

      firstRun = false
    end,
    isDone = function()
      return (
        GMR.IsPlayerPosition(waypoint.x, waypoint.y, waypoint.z, TOLERANCE_RANGE) or
          (isLastWaypoint and _.isPointCloseToCharacterWithZTolerance(waypoint))
      )
    end,
    shouldCancel = function()
      return (
        a.shouldStop() or
          GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z) > initialDistance + 5 or
          not Movement.isPositionLessOffGroundThanTheMaximum(waypoint,
            TOLERANCE_RANGE) and not Movement.canMountOnFlyingMount()
      )
    end,
    whenIsDone = function(action, actionSequenceDoer)
      if not continueMoving then
        GMR.MoveForwardStop()
      end
    end,
    onCancel = function(action, actionSequenceDoer)
      print('Cancel')
      GMR.MoveForwardStop()
    end
  }
end

function _.isPointCloseToCharacterWithZTolerance(point)
  local playerPosition = Movement.retrievePlayerPosition()
  return (
    euclideanDistance2D(playerPosition, point) <= TOLERANCE_RANGE and
      point.z >= playerPosition.z and
      point.z <= playerPosition.z + Movement.retrieveCharacterHeight()
  )
end

function Movement.isSituationWhereCharacterMightOnlyFitThroughDismounted()
  return IsMounted() and _.thereSeemsToBeSomethingInFrontOfTheCharacterForWhichTheCharacterSeemsToHigh()
end

function _.thereSeemsToBeSomethingInFrontOfTheCharacterForWhichTheCharacterSeemsToHigh()
  local characterHeight = Movement.retrieveCharacterHeightForHeightCheck()
  local positionA = Movement.positionInFrontOfPlayer2(-1, characterHeight)
  local positionB = Movement.positionInFrontOfPlayer2(0.5, characterHeight)
  position1 = positionA
  position2 = positionB
  return _.thereAreCollisions2(positionA, positionB)
end

function Movement.retrieveCharacterHeightForHeightCheck()
  if Movement.isMountedOn(1434) then
    return 3.5
  else
    return Movement.retrieveCharacterHeight()
  end
end

function Movement.dismount()
  Dismount()
  Movement.waitForDismounted()
end

function _.areConditionsMetForFacingWaypoint(waypoint)
  return GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z) > 5 or
    not Movement.canReachWaypointWithCurrentMovementDirection(waypoint)
end

function _.faceWaypoint(action, waypoint)
  if GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z) <= 5 then
    GMR.MoveForwardStop()
  end
  local facingPoint
  if Movement.isPointOnGround(waypoint) and Movement.isMountedOnFlyingMount() and Movement.canBeFlown() then
    facingPoint = Movement.createPointWithZOffset(waypoint, TARGET_LIFT_HEIGHT)
  else
    facingPoint = waypoint
  end
  if Movement.isMountedOnFlyingMount() and Movement.canBeFlown() then
    local pointInAir = Movement.determinePointHeighEnoughToStayInAir(waypoint)
    if pointInAir and GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z) > 5 then
      facingPoint = pointInAir
    end
  end
  Movement.faceDirection(facingPoint, function()
    return action.isDone() or action.shouldCancel()
  end)
end

function _.stopForwardMovement()
  GMR.MoveForwardStop()
  Movement.waitForPlayerStandingStill()
end

_.Mounter = {}

function _.Mounter:new()
  local mounter = {
    positionWhereFailedToMountLastTime = nil
  }
  setmetatable(mounter, { __index = _.Mounter })
  return mounter
end

function _.Mounter:mount()
  if not self:stopTryingToMount() and _.canCharacterMountOnBetterMount() then
    print('mount')
    _.stopForwardMovement()
    local hasTriedToMount = false
    local wasAbleToMount = nil
    if Movement.canBeFlown() and Movement.canMountOnFlyingMount() then
      hasTriedToMount = true
      wasAbleToMount = Movement.mountOnFlyingMount()
    elseif Movement.canMountOnGroundMount() then
      hasTriedToMount = true
      wasAbleToMount = Movement.mountOnGroundMount()
    end
    if hasTriedToMount then
      if wasAbleToMount then
        self.positionWhereFailedToMountLastTime = nil
      else
        self.positionWhereFailedToMountLastTime = Movement.retrievePlayerPosition()
      end
    end
  end
end

function _.Mounter:stopTryingToMount()
  return self.positionWhereFailedToMountLastTime and GMR.IsPlayerPosition(self.positionWhereFailedToMountLastTime.x,
    self.positionWhereFailedToMountLastTime.y, self.positionWhereFailedToMountLastTime.z, 10)
end

function _.isCharacterAlreadyOnBestMount()
  return Movement.isMountedOnFlyingMount() or (not Movement.canBeFlown() and IsMounted())
end

function _.canCharacterMountOnBetterMount()
  return not _.isCharacterAlreadyOnBestMount() and (Movement.canMountOnFlyingMount() or Movement.canMountOnGroundMount())
end

function Movement.determinePointHeighEnoughToStayInAir(waypoint)
  local playerPosition = Movement.retrievePlayerPosition()
  local length = euclideanDistance(playerPosition, waypoint)
  local traceLineTargetPoint = Movement.positionInFrontOfPlayer(length, 0)
  local point = Movement.traceLineCollision(playerPosition, traceLineTargetPoint)
  if point then
    return Movement.createPointWithZOffset(point, TARGET_LIFT_HEIGHT)
  else
    return nil
  end
end

function _.thereAreCollisions2(from, to)
  local from2 = createPoint(
    GMR.GetPositionFromPosition(
      from.x,
      from.y,
      from.z,
      Movement.retrieveCharacterBoundingRadius(),
      Movement.calculateAngleBetweenTwoPoints(from, to) + 0.5 * PI,
      0
    )
  )
  local to2 = createPoint(
    GMR.GetPositionFromPosition(
      to.x,
      to.y,
      to.z,
      Movement.retrieveCharacterBoundingRadius(),
      Movement.calculateAngleBetweenTwoPoints(from, to) + 0.5 * PI,
      0
    )
  )
  local from3 = createPoint(
    GMR.GetPositionFromPosition(
      from.x,
      from.y,
      from.z,
      Movement.retrieveCharacterBoundingRadius(),
      Movement.calculateAngleBetweenTwoPoints(from, to) - 0.5 * PI,
      0
    )
  )
  local to3 = createPoint(
    GMR.GetPositionFromPosition(
      to.x,
      to.y,
      to.z,
      Movement.retrieveCharacterBoundingRadius(),
      Movement.calculateAngleBetweenTwoPoints(from, to) - 0.5 * PI,
      0
    )
  )
  lines = {}
  local a = Movement.thereAreCollisions(
    from,
    to,
    true
  )
  local b = Movement.thereAreCollisions(
    from2,
    to2,
    true
  )
  local c = Movement.thereAreCollisions(
    from3,
    to3,
    true
  )
  return a or b or c
end

function Movement.isJumpSituation(to)
  if Movement.isMountedOnFlyingMount() and Movement.canBeFlown() then
    return false
  end

  local playerPosition = Movement.retrievePlayerPosition()
  local positionA = Movement.createPointWithZOffset(playerPosition, Movement.JUMP_DETECTION_HEIGHT)
  local positionB = Movement.positionInFrontOfPlayer2(0.5, Movement.JUMP_DETECTION_HEIGHT)
  --position1 = positionA
  --position2 = positionB

  return _.thereAreCollisions2(positionA, positionB)
end

local function findPathToSavedPosition2()
  local from = Movement.retrievePlayerPosition()
  local to = savedPosition
  pathFinder = Movement.createPathFinder()
  local path = pathFinder.start(from, to)
  Movement.path = path
  MovementPath = Movement.path
  return path
end

function Movement.findPathToSavedPosition()
  local thread = coroutine.create(function()
    Movement.path = findPathToSavedPosition2()
    MovementPath = Movement.path
  end)
  return resumeWithShowingError(thread)
end

function Movement.findPathToQuestingPointToMove()
  local thread = coroutine.create(function()
    Movement.path = _.findPathToSavedPosition3()
    MovementPath = Movement.path
  end)
  return resumeWithShowingError(thread)
end

function _.findPathToSavedPosition3()
  local from = Movement.retrievePlayerPosition()
  local to = QuestingPointToMove
  pathFinder = Movement.createPathFinder()
  local path = pathFinder.start(from, to)
  Movement.path = path
  MovementPath = Movement.path
  return path
end

function Movement.moveToSavedPosition()
  local thread = coroutine.create(function()
    local path = findPathToSavedPosition2()
    Movement.path = path
    MovementPath = Movement.path
    if path then
      Movement.movePath(path)
    end
  end)
  return resumeWithShowingError(thread)
end

function Movement.moveToSavedPosition2()
  GMR.MeshTo(savedPosition.x, savedPosition.y, savedPosition.z)
end

function Movement.moveCloserTo(x, y, z)
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

function Movement.determineStartPosition()
  local playerPosition = GMR.GetPlayerPosition()
  return createPoint(playerPosition.x, playerPosition.y, playerPosition.z)
end

local pathMover = nil

function Movement.receiveActiveMount()
  local mountIDs = C_MountJournal.GetMountIDs()
  for _, mountID in ipairs(mountIDs) do
    local mountInfo = { C_MountJournal.GetMountInfoByID(mountID) }
    if mountInfo[4] then
      return unpack(mountInfo)
    end
  end
  return nil
end

function Movement.isMountedOnFlyingMount()
  if IsMounted() then
    local mountID = select(12, Movement.receiveActiveMount())
    if mountID then
      return Movement.isFlyingMount(mountID)
    end
  end
  return false
end

function Movement.isDismounted()
  return not IsMounted()
end

function Movement.isMountedOn(mountID)
  local activeMountID = select(12, Movement.receiveActiveMount())
  return activeMountID == mountID
end

function Movement.waitForDismounted()
  return waitFor(Movement.isDismounted)
end

function Movement.waitForMounted()
  waitFor(function()
    return IsMounted()
  end)
end

function Movement.isSpellNameForFlyingMount(spellName)
  if spellName then
    local spellID = select(7, GetSpellInfo(spellName))
    if spellID then
      local mountID = C_MountJournal.GetMountFromSpell(spellID)
      if mountID then
        return Movement.isFlyingMount(mountID)
      end
    end
  end

  return false
end

function Movement.receiveGroundMountID()
  return Movement.receiveAnAvailableGroundMount()
end

function Movement.receiveFlyingMountID()
  return Movement.receiveAnAvailableFlyingMount()
end

function Movement.mountOnGroundMount()
  if not IsMounted() then
    local mountID = Movement.receiveGroundMountID()
    if mountID then
      Movement.mountOnMount(mountID)
    end
  end
end

function Movement.mountOnFlyingMount()
  if not Movement.isMountedOnFlyingMount() then
    local mountID = Movement.receiveFlyingMountID()
    if mountID then
      Movement.mountOnMount(mountID)
    end
  end
end

function Movement.mountOnMount(mountID)
  if not Movement.isMountedOn(mountID) then
    local spellName = C_MountJournal.GetMountInfoByID(mountID)
    if spellName then
      GMR.CastSpellByName(spellName)
      -- There seems to be some buildings where `IsOutdoors()` returns `true` and there cannot be flown (one found in Bastion).
      waitForDuration(1)
      -- With this check we check if the casting works.
      local isCasting = toBoolean(UnitCastingInfo('player'))
      if isCasting then
        Movement.waitForMounted()
      end
    end
  end
end

function Movement.waitForIsInAir()
  return waitFor(Movement.isCharacterInTheAir)
end

function Movement.waitForIsInAirOrDismounted(timeout)
  return waitFor(function()
    return Movement.isCharacterInTheAir() or Movement.isDismounted()
  end, timeout)
end

function Movement.liftUp()
  GMR.JumpOrAscendStart()
  Movement.waitForIsInAirOrDismounted(3)
  GMR.AscendStop()
end

function Movement.createPathFinder()
  local shouldStop2 = false

  local a = {
    shouldStop = function()
      return shouldStop2
    end
  }

  return {
    start = function(from, to, toleranceDistance)
      if not GMR.IsMeshLoaded() then
        GMR.LoadMeshFiles()
      end

      return Movement.findPath2(from, to, toleranceDistance, a)
    end,
    stop = function()
      shouldStop2 = true
    end
  }
end

function Movement.waitForPlayerStandingStill()
  return waitFor(function()
    return not GMR.IsMoving()
  end)
end

function Movement.findPath2(from, to, toleranceDistance, a)
  return Movement.findPathInner(from, to, toleranceDistance, a)
end

function Movement.retrievePointIndex(point)
  return MovementSavedVariables.pointIndexes:retrieveValue(point)
end

function Movement.createPointIndex(point)
  local pointIndex = MovementSavedVariables.nextPointIndex
  MovementSavedVariables.pointIndexes:setValue(point, pointIndex)
  MovementSavedVariables.points[pointIndex] = point
  MovementSavedVariables.nextPointIndex = MovementSavedVariables.nextPointIndex + 1
  return pointIndex
end

local function retrievePoint(pointIndex)
  local point = MovementSavedVariables.points[pointIndex]
  return createPoint(point.x, point.y, point.z)
end

local function _retrieveNeighbor(pointIndex)
  return retrievePoint(pointIndex)
end

function Movement.retrieveConnections(pointIndex)
  local connections2 = MovementSavedVariables.connections[pointIndex]
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

function Movement.retrieveNeighbors(pointIndex)
  local neighborPointIndexes = MovementSavedVariables.neighbors[pointIndex]
  if neighborPointIndexes then
    local neighborPoints = Array.map(neighborPointIndexes, _retrieveNeighbor)
    return neighborPoints
  else
    return nil
  end
end

local function _storeNeighbor(pointIndex, neighbor)
  local neighborIndex = Movement.retrieveOrCreatePointIndex(neighbor)
  table.insert(MovementSavedVariables.neighbors[pointIndex], neighborIndex)
end

function Movement.retrieveOrCreatePointIndex(point)
  return Movement.retrievePointIndex(point) or Movement.createPointIndex(point)
end

function Movement.storeNeighbors(pointIndex, neighbors2)
  MovementSavedVariables.neighbors[pointIndex] = {}
  Array.forEach(neighbors2, Function.partial(_storeNeighbor, pointIndex))
end

local function isPoint(value)
  return value.x
end

function Movement.createPathIndex(path)
  local pathIndex = MovementSavedVariables.nextPathIndex
  MovementSavedVariables.paths[pathIndex] = Array.map(path, function(value)
    if isPoint(value) then
      return Movement.retrieveOrCreatePointIndex(value)
    else
      return value
    end
  end)
  MovementSavedVariables.nextPathIndex = MovementSavedVariables.nextPathIndex + 1
  return pathIndex
end

function Movement.retrievePathIndexFromPathReference(pathReference)
  return pathReference[1]
end

function Movement.retrievePath(pathIndex)
  return Array.flatMap(MovementSavedVariables.paths[pathIndex], function(value)
    if type(value) == 'table' then
      return Movement.retrievePath(Movement.retrievePathIndexFromPathReference(value))
    else
      return retrievePoint(value)
    end
  end)
end

local function createPathReference(pathIndex)
  return { pathIndex }
end

function Movement.addConnection(pointIndex, connection)
  if not MovementSavedVariables.connections[pointIndex] then
    MovementSavedVariables.connections[pointIndex] = {}
  end
  table.insert(MovementSavedVariables.connections[pointIndex], connection)
end

function Movement.addConnectionFromTo(closestPointOnGridFromFromPoint, from, to)
  Movement.addConnectionFromToWithInteractable(closestPointOnGridFromFromPoint, from, to, nil)
end

function Movement.addConnectionFromToWithInteractable(closestPointOnGridFromFromPoint, from, to, objectID)
  local closestPointOnGridIndexFromFromPoint = Movement.retrieveOrCreatePointIndex(closestPointOnGridFromFromPoint)
  local toPointIndex = Movement.retrieveOrCreatePointIndex(to)
  local pathIndex = Movement.createPathIndex({ from })
  local connection = {
    toPointIndex,
    pathIndex,
    objectID
  }
  Movement.addConnection(closestPointOnGridIndexFromFromPoint, connection)
end

function Movement.storeConnection(path)
  local destinationPointIndex = Movement.retrieveOrCreatePointIndex(path[#path])

  local index = #path - 1

  local subPath = Array.slice(path, index)
  local startPointIndex = Movement.retrieveOrCreatePointIndex(subPath[1])
  local pathIndex = Movement.createPathIndex(subPath)
  local connection = {
    destinationPointIndex,
    pathIndex
  }
  Movement.addConnection(startPointIndex, connection)

  for index = #path - 2, 1, -1 do
    local subPath = { path[index], createPathReference(pathIndex) }
    local startPointIndex = Movement.retrieveOrCreatePointIndex(subPath[1])
    pathIndex = Movement.createPathIndex(subPath)
    local connection = {
      destinationPointIndex,
      pathIndex
    }
    Movement.addConnection(startPointIndex, connection)
  end
end

function Movement.findPathInner(from, to, toleranceDistance, a)
  local path
  -- aStarPoints = {}

  local receiveNeighborPoints = function(point)
    return Movement.receiveNeighborPoints(point, DISTANCE)
  end

  --local points = receiveNeighborPoints(from)
  --DevTools_Dump(points)
  --aStarPoints = points

  -- local yielder = createYielder()
  local yielder = createYielderWithTimeTracking(1 / 60)
  Movement.yielder = yielder

  local path = nil
  local subPathWhichHasBeenGeneratedFromMovementPoints = nil

  path, subPathWhichHasBeenGeneratedFromMovementPoints = findPath(
    from,
    to,
    receiveNeighborPoints,
    a,
    yielder,
    toleranceDistance
  )

  Movement.path = path
  MovementPath = Movement.path

  if subPathWhichHasBeenGeneratedFromMovementPoints then
    Movement.storeConnection(subPathWhichHasBeenGeneratedFromMovementPoints)
  end

  return path
end

function Movement.resume()
  if Movement.yielder then
    Movement.yielder.resume()
  end
end

function Movement.receiveNeighborPoints(point, distance)
  local pointIndex = Movement.retrieveOrCreatePointIndex(point)
  local connections2 = Movement.retrieveConnections(pointIndex)
  local neighborPoints = connections2

  local neighborPointsRetrievedFromInGameMesh = Movement.retrieveNeighbors(pointIndex)
  if not neighborPointsRetrievedFromInGameMesh then
    neighborPointsRetrievedFromInGameMesh = Movement.generateNeighborPoints(point, distance)
    Movement.storeNeighbors(pointIndex, neighborPointsRetrievedFromInGameMesh)
  end
  local pointToConnectionPoint = PointToValueMap:new()
  Array.forEach(connections2, function(point)
    pointToConnectionPoint:setValue(point, point)
  end)
  neighborPointsRetrievedFromInGameMesh = Array.map(neighborPointsRetrievedFromInGameMesh, function(point)
    local connectionPoint = pointToConnectionPoint:retrieveValue(point)
    if connectionPoint then
      return connectionPoint
    else
      return point
    end
  end)
  Array.append(neighborPoints, neighborPointsRetrievedFromInGameMesh)

  return neighborPoints
end

function Movement.calculateTotalPathDistance(path)
  local totalDistance = 0
  for index = 2, #path do
    totalDistance = totalDistance + euclideanDistance2D(path[index - 1], path[index])
  end
  return totalDistance
end

function Movement.movePath(path, stop)
  Movement.stopMoving()
  local a = {
    shouldStop = stop or function()
      return false
    end
  }
  local pathLength = #path
  local totalDistance = Movement.calculateTotalPathDistance(path)
  local stopMoving = GMR.StopMoving
  GMR.StopMoving = Function.noOperation
  local dismount = GMR.Dismount
  GMR.Dismount = Function.noOperation
  pathMover = createActionSequenceDoer2(
    Array.map(path, function(waypoint, index)
      return Movement.createMoveToAction3(waypoint, index < pathLength, a, totalDistance, index == pathLength)
    end),
    {
      onStop = function()
        GMR.StopMoving = stopMoving
        GMR.Dismount = dismount
        GMR.MoveForwardStop()
      end
    }
  )
  pathMover.run()
  return pathMover
end

local function cleanUpPathFinding()
  pathFinder = nil
  run = nil
  aStarPoints = nil
  -- Movement.path = nil
  -- MovementPath = Movement.path
end

local function cleanUpPathMoving()
  pathMover = nil
  if not pathFinder then
    run = nil
  end
end

local function cleanUpPathFindingAndMoving()
  cleanUpPathFinding()
  cleanUpPathMoving()
end

local function stopPathFinding()
  if pathFinder then
    print('stop')
    pathFinder.stop()
    cleanUpPathFinding()
  end
end

Movement.stopPathFinding = stopPathFinding

function Movement.stopPathMoving()
  if pathMover then
    pathMover.stop()
    cleanUpPathMoving()
  end
end

function Movement.stopPathFindingAndMoving()
  stopPathFinding()
  Movement.stopPathMoving()
end

local function isPathFinding()
  return toBoolean(pathFinder)
end

local function isDifferentPathFindingRequestThanRun(to)
  return not run or to ~= run.to
end

function Movement.moveTo(to, options)
  options = options or {}

  local from = Movement.retrievePlayerPosition()
  local continentID = select(8, GetInstanceInfo())
  local x, y, z = GMR.GetClosestPointOnMesh(continentID, from.x, from.y, from.z)
  if x and y and z then
    from = createPoint(x, y, z)
  end

  if isDifferentPathFindingRequestThanRun(to) then
    Movement.stopPathFindingAndMoving()
    run = {
      from = from,
      to = to
    }
    pathFinder = Movement.createPathFinder()
    local path = pathFinder.start(from, to, options.toleranceDistance)
    pathFinder = nil
    Movement.path = path
    MovementPath = Movement.path
    if path then
      pathMover = Movement.movePath(path, options.stop)
      cleanUpPathFindingAndMoving()
    end
  end
end

local function moveToFromNonCoroutine(x, y, z)
  runAsCoroutine(function()
    Movement.moveTo(createPoint(x, y, z))
  end)
end

function Movement.replaceGMRMovementSystem()
  GMR.Mesh = moveToFromNonCoroutine
  GMR.MeshTo = moveToFromNonCoroutine
  GMR.UnstuckHandler = function()
  end
  GMR.UnstuckPathHandler = function()
  end
  --GMR.Mesh = hooksecurefunc(GMR, 'MeshTo', function()
  --  print('GMR.MeshTo')
  --  Movement.stopMoving()
  --end)
  --hooksecurefunc(GMR, 'Mesh', function()
  --  print('GMR.Mesh')
  --  Movement.stopMoving()
  --end)
  hooksecurefunc(GMR, 'EngageMeshTo', function()
    print('GMR.EngageMeshTo')
    Movement.stopMoving()
  end)
  hooksecurefunc(GMR.Questing, 'MoveTo', function()
    print('GMR.Questing.MoveTo')
    Movement.stopMoving()
  end)
  hooksecurefunc(GMR, 'MoveTo', function()
    print('GMR.MoveTo')
    Movement.stopMoving()
  end)

  doRegularlyWhenGMRIsFullyLoaded(function()
    if GMR.InCombat('player') then
      Movement.stopMoving()
    end
  end)
end

-- view distance = 5: 625
-- view distance = 10: 975

function Movement.waitForPlayerToBeOnPosition(position, radius)
  radius = radius or 3
  waitFor(function()
    return GMR.IsPlayerPosition(position.x, position.y, position.z, radius)
  end)
end

function Movement.faceSmoothly(point)
  local playerPosition = GMR.GetPlayerPosition()
  if (
    GMR.IsPositionUnderwater(playerPosition.x, playerPosition.y, playerPosition.z) or
      GMR.IsPointInTheAir(playerPosition.x, playerPosition.y, playerPosition.z)
  ) then
    local distance = euclideanDistance2D(playerPosition, point)

    if distance > 0.5 then
      GMR.FaceSmoothly(point.x, point.y, point.z)
    end

    if distance <= 0.5 then
      if point.z < playerPosition.z then
        GMR.SetPitch(-0.5 * PI)
      elseif point.z > playerPosition.z then
        GMR.SetPitch(0.5 * PI)
      end
    end
  else
    GMR.FaceSmoothly(point.x, point.y, point.z)
  end
end

function Movement.faceDirection(point, stop)
  local yielder = createYielder()
  while not GMR.IsFacingXYZ(point.x, point.y, point.z) and (not stop or not stop()) do
    local previousPlayerFacingAngle = GMR.ObjectRawFacing('player')
    Movement.faceSmoothly(point)
    yielder.yield()
    if GMR.ObjectRawFacing('player') == previousPlayerFacingAngle then
      break
    end
  end

  if not stop or not stop() then
    GMR.FaceDirection(point.x, point.y, point.z)
  end
end

function Movement.closestPointOnGrid(point)
  return createPoint(
    Movement.closestCoordinateOnGrid(point.x),
    Movement.closestCoordinateOnGrid(point.y),
    Movement.closestCoordinateOnGrid(point.z)
  )
end

function Movement.closestPointOnGridWithZLeft(point)
  return createPoint(
    Movement.closestCoordinateOnGrid(point.x),
    Movement.closestCoordinateOnGrid(point.y),
    point.z
  )
end

function Movement.closestPointOnGridWithZOnGround(point)
  point = Movement.closestPointOnGridWithZLeft(point)
  return createPoint(
    point.x,
    point.y,
    Movement.retrieveGroundZ(point)
  )
end

function Movement.closestCoordinateOnGrid(coordinate)
  return Math.round(coordinate / GRID_LENGTH) * GRID_LENGTH
end

function Movement.convertPointToArray(point)
  return { point.x, point.y, point.z }
end

function Movement.convertArrayToPoint(point)
  return createPoint(unpack(point))
end

function Movement.convertPathToGMRPath(path)
  return Array.map(path, Movement.convertPointToArray)
end

function Movement.convertGMRPathToPath(path)
  return Array.map(path, Movement.convertArrayToPoint)
end

function Movement.moveToSavedPath()
  local thread = coroutine.create(function()
    Movement.movePath(path)
  end)
  return resumeWithShowingError(thread)
end

function Movement.traceLine(from, to, hitFlags)
  if Movement.isPositionInRangeForTraceLineChecks(from) then
    print(1)
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
  else
    print(2)
    return nil
  end
end

function Movement.traceLineCollisionWithFallback(from, to)
  if Movement.isPositionInRangeForTraceLineChecks(from) and Movement.isPositionInRangeForTraceLineChecks(from) then
    return Movement.traceLine(from, to, Movement.TraceLineHitFlags.COLLISION)
  elseif Float.seemsCloseBy(from.x, to.x) and Float.seemsCloseBy(from.y, to.y) then
    local x = from.x
    local y = from.y
    local closestPointOnMesh = Movement.retrieveClosestPointOnMesh(Movement.createPositionFromPoint(Movement.retrieveContinentID(),
      from))
    local minZ = math.min(from.z, to.z)
    local maxZ = math.max(from.z, to.z)
    if (
      closestPointOnMesh and
        Float.seemsCloseBy(closestPointOnMesh.x, x) and
        Float.seemsCloseBy(closestPointOnMesh.y, y) and
        closestPointOnMesh.z >= minZ and closestPointOnMesh.z <= maxZ
    ) then
      return closestPointOnMesh
    end
  else
    return nil
  end
end

function Movement.createPositionFromPoint(continentID, point)
  return {
    continentID = continentID,
    x = point.x,
    y = point.y,
    z = point.z
  }
end

function Movement.retrieveClosestPointOnMesh(position)
  local x, y, z = HWT.GetClosestPositionOnMesh(position.continentID, position.x, position.y, position.z)
  if x and y and z then
    return createPoint(x, y, z)
  else
    return nil
  end
end

function Movement.traceLineCollision(from, to)
  return Movement.traceLine(from, to, Movement.TraceLineHitFlags.COLLISION)
end

function Movement.traceLineWater(from, to)
  return Movement.traceLine(from, to, Movement.TraceLineHitFlags.WATER)
end

function Movement.retrievePositionBetweenPositions(a, b, distanceFromA)
  local x, y, z = GMR.GetPositionBetweenPositions(a.x, a.y, a.z, b.x, b.y, b.z, distanceFromA)
  return createPoint(x, y, z)
end

function Movement.generateWalkToPointFromCollisionPoint(from, collisionPoint)
  local pointWithDistanceToCollisionPoint = Movement.retrievePositionBetweenPositions(collisionPoint, from,
    Movement.retrieveCharacterBoundingRadius())
  local z = Movement.retrieveGroundZ(pointWithDistanceToCollisionPoint)
  return createPoint(pointWithDistanceToCollisionPoint.x, pointWithDistanceToCollisionPoint.y, z)
end

function Movement.isFirstPointCloserToThanSecond(fromA, fromB, to)
  return euclideanDistance(fromA, to) < euclideanDistance(fromB, to)
end

function Movement.findClosestPointThatCanBeWalkedTo(from, to)
  local walkToPoint = from
  while true do
    local pointOnMaximumWalkUpToHeight = Movement.createPointWithZOffset(walkToPoint,
      Movement.MAXIMUM_WALK_UP_TO_HEIGHT)
    local destinationOnMaximumWalkUpToHeight = Movement.createPointWithZOffset(to, Movement.MAXIMUM_WALK_UP_TO_HEIGHT)
    local collisionPoint = Movement.traceLineCollision(pointOnMaximumWalkUpToHeight, destinationOnMaximumWalkUpToHeight)
    if collisionPoint then
      local potentialWalkToPoint = Movement.generateWalkToPointFromCollisionPoint(pointOnMaximumWalkUpToHeight,
        collisionPoint)
      if not walkToPoint or Movement.isFirstPointCloserToThanSecond(potentialWalkToPoint, walkToPoint, to) then
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

function Movement.moveTowards(x, y, z)
  local playerPosition = Movement.retrievePlayerPosition()
  local destination = createPoint(x, y, z)
  local walkToPoint = Movement.findClosestPointThatCanBeWalkedTo(playerPosition, destination)

  if walkToPoint ~= playerPosition then
    GMR.MoveTo(walkToPoint.x, walkToPoint.y, walkToPoint.z)
  end
end

function Movement.moveTowardsSavedPosition()
  local thread = coroutine.create(function()
    Movement.moveTowards(savedPosition.x, savedPosition.y, savedPosition.z)
  end)
  return resumeWithShowingError(thread)
end

function Movement.havePointsSameCoordinates(a, b)
  return a.x == b.x and a.y == b.y and a.z == b.z
end

function Movement.stopMoving()
  -- local playerPosition = Movement.retrievePlayerPosition()
  -- GMR.Questing.MoveTo(playerPosition.x, playerPosition.y, playerPosition.z)
  -- GMR.StopMoving()
  if pathMover then
    pathMover.stop()
    pathMover = nil
    Movement.path = nil
    MovementPath = Movement.path
  end
end

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
    ticker:Cancel()

    -- TODO: Continent ID

    Movement.addConnectionFromTo(
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

    Movement.addConnectionFromToWithInteractable(
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

function Movement.onEvent(self, event, ...)
  if event == 'ADDON_LOADED' then
    Movement.onAddonLoaded(...)
  end
end

function Movement.onAddonLoaded(addonName)
  if addonName == 'Movement' then
    Movement.initializeSavedVariables()
  end
end

function Movement.initializeSavedVariables()
  if not MovementSavedVariables then
    MovementSavedVariables = {}
  end
  if not MovementSavedVariables.connections then
    MovementSavedVariables.connections = {}
  end
  if not MovementSavedVariables.points then
    MovementSavedVariables.points = {}
  end
  if not MovementSavedVariables.pointIndexes then
    MovementSavedVariables.pointIndexes = PointToValueMap:new()
  else
    local pointIndexes = MovementSavedVariables.pointIndexes
    MovementSavedVariables.pointIndexes = PointToValueMap:new()
    MovementSavedVariables.pointIndexes._values = pointIndexes._values
  end
  if not MovementSavedVariables.nextPointIndex then
    MovementSavedVariables.nextPointIndex = 1
  end
  if not MovementSavedVariables.neighbors then
    MovementSavedVariables.neighbors = {}
  end
  if not MovementSavedVariables.paths then
    MovementSavedVariables.paths = {}
  end
  if not MovementSavedVariables.nextPathIndex then
    MovementSavedVariables.nextPathIndex = 1
  end
end

Movement.frame = CreateFrame('Frame')
Movement.frame:SetScript('OnEvent', Movement.onEvent)
Movement.frame:RegisterEvent('ADDON_LOADED')

function findPathE()
  Movement.path = Movement.convertGMRPathToPath(GMR.GetPath(savedPosition.x, savedPosition.y, savedPosition.z, false))
  MovementPath = Movement.path
end

function findPathE2()
  local playerPosition = Movement.retrievePlayerPosition()
  Movement.path = Movement.convertGMRPathToPath(GMR.GetPathBetweenPoints(playerPosition.x, playerPosition.y,
    playerPosition.z, savedPosition.x, savedPosition.y, savedPosition.z))
  MovementPath = Movement.path
end

function findPathE3()
  local playerPosition = Movement.retrievePlayerPosition()
  Movement.path = Movement.convertGMRPathToPath(GMR.GetPathBetweenPoints(playerPosition.x, playerPosition.y,
    playerPosition.z, savedPosition.x, savedPosition.y, savedPosition.z))
  MovementPath = Movement.path
  return AStar.canPathBeMoved(Movement.path)
end

function findPathE4()
  local path = GMR.GetPath(QuestingPointToMove.x, QuestingPointToMove.y, QuestingPointToMove.z, false)
  if path then
    path = Movement.convertGMRPathToPath(path)
  end
  Movement.path = path
  MovementPath = Movement.path
end

function findPathE5()
  local continentID = Movement.retrieveContinentID()
  local playerPosition = Movement.retrievePlayerPosition()
  local start = createPoint(HWT.GetClosestPositionOnMesh(continentID, playerPosition.x, playerPosition.y, playerPosition.z))
  print('start')
  DevTools_Dump(start)
  local path = HWT.FindPath(continentID, start.x, start.y, start.z, QuestingPointToMove.x, QuestingPointToMove.y, QuestingPointToMove.z, false, 1024, 0, 1, false)
  print('path')
  DevTools_Dump(path)
  if path then
    path = Movement.convertGMRPathToPath(path)
  end
  Movement.path = path
  MovementPath = Movement.path
end

function aaaaaaa2394ui2u32uio()
  return Movement.canPlayerStandOnPoint(position1)
end

-- position2 = Movement.createPointWithZOffset(Movement.retrievePlayerPosition(), Movement.retrieveCharacterHeight())
