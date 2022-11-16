Movement = {}

position1 = nil
position2 = nil
aStarPoints = nil
aStarPoints2 = nil

local DEVELOPMENT = true
local zOffset = 1.6
local MAXIMUM_FALL_HEIGHT = 30
local CHARACTER_RADIUS = 0.55 -- the radius might vary race by race
local MAXIMUM_WATER_DEPTH = 1000
local GRID_LENGTH = 2
local MINIMUM_LIFT_HEIGHT = 0.25 -- Minimum flying lift height seems to be ~ 0.25 yards.
local TOLERANCE_RANGE = 1
local TARGET_LIFT_HEIGHT = TOLERANCE_RANGE
local MAXIMUM_AIR_HEIGHT = 5000
local walkToPoint = nil
local CHARACTER_HEIGHT = 2 -- ~ for human
local MOUNTED_CHARACTER_HEIGHT = 3 -- only an approximation. Seems to depend on mount and maybe also character model.
local canBeStoodOnPointCache = PointToValueMap:new()
local canBeStoodWithMountOnPointCache = PointToValueMap:new()
local DISTANCE = GRID_LENGTH

local cache = {}

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
  hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
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

    local path = Movement.path
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
  return a or b or c
end

function Movement.isEnoughSpaceOnTop(from, to)
  local offset = 0.1
  local a = Movement.thereAreZeroCollisions(
    Movement.createPointWithZOffset(from, offset),
    Movement.createPointWithZOffset(from, MOUNTED_CHARACTER_HEIGHT)
  )
  local b = Movement.thereAreZeroCollisions(
    Movement.createPointWithZOffset(to, offset),
    Movement.createPointWithZOffset(to, MOUNTED_CHARACTER_HEIGHT)
  )

  local c = Movement.thereAreZeroCollisions2(Movement.createPointWithZOffset(from, offset),
    Movement.createPointWithZOffset(to, offset), MOUNTED_CHARACTER_HEIGHT - offset)
  return a and b and c
end

function Movement.thereAreZeroCollisions2(from, to, zHeight)
  local function thereAreZeroCollisions(zOffset)
    return Movement.thereAreZeroCollisions(
      Movement.createPointWithZOffset(from, zOffset),
      Movement.createPointWithZOffset(to, zOffset)
    )
  end
  local interval = 1
  return Array.isTrueForAllInInterval(0, zHeight, interval, thereAreZeroCollisions) and
    (zHeight % interval == 0 or thereAreZeroCollisions(zHeight))
end

Movement.MAXIMUM_WALK_UP_TO_HEIGHT = 0.94
Movement.JUMP_DETECTION_HEIGHT = 1.5
Movement.MAXIMUM_JUMP_HEIGHT = 1.675

function Movement.canBeWalkedOrSwamFromPointToPoint(from, to)
  return (
    (Movement.isPointInWater(to) or Movement.canPlayerStandOnPoint(to)) and
      Movement.canBeMovedFromPointToPointCheckingSubSteps(from, to)
  )
end

function Movement.canBeMovedFromPointToPointCheckingSubSteps(from, to)
  if from.x == to.x and from.y == to.y then
    return to.z - from.z <= Movement.MAXIMUM_WALK_UP_TO_HEIGHT or (Movement.isPointInWater(from) and Movement.isPointInWater(to))
  end

  local totalDistance = euclideanDistance(from, to)

  local point1 = from
  local stepSize = 1
  local distance = stepSize
  while distance < totalDistance do
    local x, y, z = GMR.GetPositionBetweenPositions(from.x, from.y, from.z, to.x, to.y, to.z, distance)
    local point2 = createPoint(x, y, z)

    if not (Movement.isPointInWater(point1) and Movement.isPointInWater(point2)) then
      local z = GMR.GetGroundZ(x, y, z)

      if not z then
        return false
      end

      point2 = createPoint(x, y, z)

      if point1.x == x and point1.y == y then
        return z - point1.z <= Movement.MAXIMUM_WALK_UP_TO_HEIGHT
      end

      if not (z - point1.z <= Movement.MAXIMUM_WALK_UP_TO_HEIGHT) then
        return false
      end
    end

    if not Movement.thereAreZeroCollisions(
      Movement.createPointWithZOffset(point1, Movement.MAXIMUM_WALK_UP_TO_HEIGHT),
      Movement.createPointWithZOffset(point2, Movement.MAXIMUM_WALK_UP_TO_HEIGHT)
    ) then
      return false
    end

    point1 = point2
    distance = distance + stepSize
  end

  if not (to.z - point1.z <= Movement.MAXIMUM_WALK_UP_TO_HEIGHT or (Movement.isPointInWater(point1) and Movement.isPointInWater(to))) then
    return false
  end

  if not Movement.thereAreZeroCollisions(
    Movement.createPointWithZOffset(point1, Movement.MAXIMUM_WALK_UP_TO_HEIGHT),
    Movement.createPointWithZOffset(to, Movement.MAXIMUM_WALK_UP_TO_HEIGHT)
  ) then
    return false
  end

  return true
end

function Movement.canBeJumpedFromPointToPoint(from, to)
  return (
    Movement.isPointOnGround(from) and
      (Movement.isPointInWater(to) or (Movement.isPointOnGround(to) and Movement.canPlayerStandOnPoint(to))) and
      to.z - from.z <= Movement.MAXIMUM_JUMP_HEIGHT and
      Movement.thereAreZeroCollisions(
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

  local height
  if options.withMount then
    height = MOUNTED_CHARACTER_HEIGHT
  else
    height = CHARACTER_HEIGHT
  end

  local pointALittleBitOver = Movement.createPointWithZOffset(point, 0.1)
  local pointOnMaximumWalkUpToHeight = Movement.createPointWithZOffset(
    point,
    Movement.MAXIMUM_WALK_UP_TO_HEIGHT
  )
  local pointALittleBitOverMaximumWalkUpToHeight = Movement.createPointWithZOffset(pointOnMaximumWalkUpToHeight, 0.1)
  local pointOnCharacterHeight = Movement.createPointWithZOffset(point, height)

  local function areThereCollisionsAround()
    local points = Movement.generatePointsAround(pointALittleBitOverMaximumWalkUpToHeight, CHARACTER_RADIUS, 8)
    return Array.all(points, function(point)
      return Movement.thereAreZeroCollisions(pointALittleBitOverMaximumWalkUpToHeight, point)
    end)
  end

  local result = (
    Movement.thereAreZeroCollisions(pointOnMaximumWalkUpToHeight, pointALittleBitOver) and
      Movement.thereAreZeroCollisions(pointALittleBitOverMaximumWalkUpToHeight, pointOnCharacterHeight) and
      areThereCollisionsAround()
  )

  return result
end

function Movement.canPlayerStandOnPoint(point, options)
  options = options or {}

  if options.withMount then
    local value = canBeStoodWithMountOnPointCache:retrieveValue(point)
    if value ~= nil then
      return value
    end
  else
    local value = canBeStoodOnPointCache:retrieveValue(point)
    if value ~= nil then
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
    local standOnPoint = Movement.traceLineCollision(
      pointALittleBitOverMaximumWalkUpToHeight,
      pointALittleBitUnderPoint
    )
    if standOnPoint then
      local MAXIMUM_STEEPNESS_HEIGHT = 0.55436325073242
      local points = Movement.generatePointsAround(standOnPoint, CHARACTER_RADIUS, 8)
      return not Array.all(points, function(point)
        local point1 = Movement.createPointWithZOffset(point, Movement.MAXIMUM_WALK_UP_TO_HEIGHT)
        return Movement.thereAreCollisions(
          point1,
          Movement.createPointWithZOffset(
            point1,
            -(MAXIMUM_STEEPNESS_HEIGHT + 0.00000000000001 + Movement.MAXIMUM_WALK_UP_TO_HEIGHT)
          )
        )
      end)
    else
      return false
    end
  end

  local result = (
    Movement.canPlayerBeOnPoint(point, options) and
      not canFallOff()
  )

  if options.withMount then
    canBeStoodWithMountOnPointCache:setValue(point, result)
  else
    canBeStoodOnPointCache:setValue(point, result)
  end

  return result
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

function Movement.receiveAnAvailableFlyingMount()
  local mountIDs = Movement.receiveAvailableMountIDs()
  return Array.find(mountIDs, Movement.isFlyingMount)
end

function Movement.isFlyingMount(mountID)
  local mountTypeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))
  return mountTypeID == 247 or mountTypeID == 248 or mountTypeID == 242
end

function Movement.retrieveGroundZ(position)
  local x, y, z = GMR.TraceLine(
    position.x, position.y, position.z + Movement.MAXIMUM_JUMP_HEIGHT,
    position.x, position.y, position.z - MAXIMUM_AIR_HEIGHT,
    Movement.TraceLineHitFlags.COLLISION
  )
  return z
end

function Movement.thereAreCollisions(a, b)
  local x, y, z = GMR.TraceLine(a.x, a.y, a.z, b.x, b.y, b.z, Movement.TraceLineHitFlags.COLLISION)
  return toBoolean(x)
end

function Movement.thereAreZeroCollisions(a, b)
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
  elseif Movement.isPointInWater(point2) then
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
  local x, y, z = GMR.TraceLine(point.x, point.y, point.z + MAXIMUM_WATER_DEPTH, point.x, point.y, point.z,
    Movement.TraceLineHitFlags.WATER)
  if x then
    return createPoint(x, y, z)
  else
    return nil
  end
end

function Movement.isPointInWater(point)
  -- local waterSurfacePoint = Movement.receiveWaterSurfacePoint(point)
  -- return toBoolean(waterSurfacePoint and waterSurfacePoint.z >= point.z)
  return toBoolean(GMR.IsPositionUnderwater(point.x, point.y, point.z))
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

function Movement.canMountOnFlyingMount()
  return (
    GMR.IsAlive('player') and
      Movement.canBeFlown() and
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
      if firstRun then
        -- log('waypoint', waypoint.x, waypoint.y, waypoint.z)
        initialDistance = GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z)
      end

      local playerPosition = Movement.retrievePlayerPosition()
      if (
        Movement.canBeFlown() and
          (totalDistance > 10 or Movement.isPositionInTheAir(waypoint))
      ) then
        if not Movement.isMountedOnFlyingMount() and Movement.canMountOnFlyingMount() then
          GMR.MoveForwardStop()
          Movement.waitForPlayerStandingStill()
          Movement.mountOnFlyingMount()
        end
        if Movement.isMountedOnFlyingMount() then
          local playerPosition = Movement.retrievePlayerPosition()
          if (
            (Movement.isPointOnGround(playerPosition) or (Movement.isPointInWater(playerPosition) and not Movement.isPointInWater(waypoint))) and
              (not isLastWaypoint or Movement.isPositionInTheAir(waypoint))
          ) then
            Movement.liftUp()
          end
        end
      end

      if not Movement.canReachWaypointWithCurrentMovementDirection(waypoint) then
        if GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z) <= 5 then
          print('GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z) <= 5')
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
      if not GMR.IsMoving() then
        GMR.MoveForwardStart()
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
      return GMR.IsPlayerPosition(waypoint.x, waypoint.y, waypoint.z, TOLERANCE_RANGE)
    end,
    shouldCancel = function()
      return (
        a.shouldStop() or
          GMR.GetDistanceToPosition(waypoint.x, waypoint.y, waypoint.z) > initialDistance + 5
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

function Movement.isJumpSituation(to)
  if GMR.IsUnitFlying('player') or Movement.isMountedOnFlyingMount() and Movement.isFlyingAvailableInZone() then
    return false
  end

  local playerPosition = Movement.retrievePlayerPosition()
  if to.z - playerPosition.z > Movement.MAXIMUM_WALK_UP_TO_HEIGHT then
    local positionA = createPoint(playerPosition.x, playerPosition.y, playerPosition.z + Movement.JUMP_DETECTION_HEIGHT)
    local positionB = Movement.positionInFrontOfPlayer(3, Movement.JUMP_DETECTION_HEIGHT)
    --position1 = positionA
    --position2 = positionB
    return Movement.thereAreCollisions(
      positionA,
      positionB
    )
  end
end

local function findPathToSavedPosition2()
  local from = Movement.retrievePlayerPosition()
  local to = savedPosition
  local pathFinder = Movement.createPathFinder()
  debugprofilestart()
  local path = pathFinder.start(from, to)
  Movement.path = path
  local duration = debugprofilestop()
  -- log(duration)
  return path
end

function Movement.findPathToSavedPosition()
  local thread = coroutine.create(function()
    Movement.path = findPathToSavedPosition2()
  end)
  return resumeWithShowingError(thread)
end

function Movement.moveToSavedPosition()
  local thread = coroutine.create(function()
    local path = findPathToSavedPosition2()
    Movement.path = path
    if path then
      -- print('go path')
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

function Movement.waitForDismounted()
  return waitFor(Movement.isDismounted)
end

function Movement.waitForMounted()
  return waitFor(function()
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

function Movement.receiveFlyingMountSpellName()
  local spellName = GMR.GetFlyingMount()
  if not Movement.isSpellNameForFlyingMount(spellName) then
    spellName = nil
    local mountID = Movement.receiveAnAvailableFlyingMount()
    print('mountID', mountID)
    if mountID then
      spellName = C_MountJournal.GetMountInfoByID(mountID)
    end
  end

  return spellName
end

function Movement.mountOnFlyingMount()
  print('Movement.mountOnFlyingMount()')
  if not Movement.isMountedOnFlyingMount() then
    local spellName = Movement.receiveFlyingMountSpellName()
    if spellName then
      if IsMounted() then
        GMR.Dismount()
      end
      Movement.waitForDismounted()
      GMR.CastSpellByName(spellName)
      Movement.waitForMounted()
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
  print('Movement.liftUp()')
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
    start = function(from, to)
      if not GMR.IsMeshLoaded() then
        GMR.LoadMeshFiles()
      end

      return Movement.findPath2(from, to, a)
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

function Movement.findPath2(from, to, a)
  return Movement.findPathInner(from, to, a, 0)
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

function Movement.findPathInner(from, to, a)
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
    yielder
  )

  Movement.path = path

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
  print('Movement.movePath')
  Movement.stopMoving()
  local a = {
    shouldStop = stop or function()
      return false
    end
  }
  local pathLength = #path
  local totalDistance = Movement.calculateTotalPathDistance(path)
  local stopMoving = GMR.StopMoving
  GMR.StopMoving = function()
  end
  pathMover = createActionSequenceDoer2(
    Array.map(path, function(waypoint, index)
      return Movement.createMoveToAction3(waypoint, index < pathLength, a, totalDistance, index == pathLength)
    end),
    {
      onStop = function()
        GMR.StopMoving = stopMoving
        GMR.MoveForwardStop()
      end
    }
  )
  pathMover.run()
  return pathMover
end

local run = nil
local pathFinder = nil

local function cleanUpPathFinding()
  pathFinder = nil
  run = nil
  aStarPoints = nil
  Movement.path = nil
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
    pathFinder.stop()
    cleanUpPathFinding()
  end
end

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

local function moveTo(x, y, z)
  if x and y and z then
    local from = Movement.retrievePlayerPosition()
    local to = createPoint(x, y, z)

    if isDifferentPathFindingRequestThanRun(to) then
      Movement.stopPathFindingAndMoving()
      run = {
        from = from,
        to = to
      }
      pathFinder = Movement.createPathFinder()
      local path = pathFinder.start(from, to)
      pathFinder = nil
      Movement.path = path
      if path then
        pathMover = Movement.movePath(path)
        cleanUpPathFindingAndMoving()
      end
    end
  end
end

local function moveToFromNonCoroutine(x, y, z)
  coroutine.wrap(function()
    moveTo(x, y, z)
  end)()
end

doWhenGMRIsFullyLoaded(function()
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
end)

doRegularlyWhenGMRIsFullyLoaded(function()
  if GMR.InCombat('player') then
    Movement.stopMoving()
  end
end)

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

function Movement.traceLineCollision(from, to)
  return Movement.traceLine(from, to, Movement.TraceLineHitFlags.COLLISION)
end

function Movement.retrievePositionBetweenPositions(a, b, distanceFromA)
  local x, y, z = GMR.GetPositionBetweenPositions(a.x, a.y, a.z, b.x, b.y, b.z, distanceFromA)
  return createPoint(x, y, z)
end

function Movement.generateWalkToPointFromCollisionPoint(from, collisionPoint)
  local pointWithDistanceToCollisionPoint = Movement.retrievePositionBetweenPositions(collisionPoint, from,
    CHARACTER_RADIUS)
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
    print('Movement.path = nil')
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
