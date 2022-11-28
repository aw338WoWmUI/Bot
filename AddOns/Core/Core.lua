local addOnName, AddOn = ...
--- @class Core
Core = Core or {}

Core.RANGE_IN_WHICH_OBJECTS_SEEM_TO_BE_SHOWN = 50

Core.TraceLineHitFlags = {
  COLLISION = 1048849,
  WATER = 131072,
  WATER2 = 65536
}

local _ = {}

--- This list has been based on https://github.com/TrinityCore/TrinityCore/blob/4b06b8ec1e3ccc153a44b3eb2e8487641cfae98d/src/server/game/Entities/Unit/UnitDefines.h#L275-L310
--- which is licensed under the GNU General Public License v2.0 (full license: https://github.com/TrinityCore/TrinityCore/blob/75c06d25da76f0c4f0ea680e6f5ed1bc3bf1d42e/COPYING).
--- By the conditions of the license, this list is also licensed under the same license.
--- Modifications have been made (appropriate structure for LUA, name modifications, and entry selections).
Core.NpcFlags = {
  None = 0x0,
  Gossip = 0x1,
  QuestGiver = 0x2,
  Trainer = 0x10,
  ClassTrainer = 0x20,
  Vendor = 0x80,
  AmmoVendor = 0x100,
  FoodVendor = 0x200,
  PoisonVendor = 0x400,
  ReagentVendor = 0x800,
  Repair = 0x1000,
  FlightMaster = 0x2000,
  Innkeeper = 0x10000,
  Banker = 0x20000,
  Petitioner = 0x40000,
  TabardDesigner = 0x80000,
  BattleMaster = 0x100000,
  Auctioneer = 0x200000,
  StableMaster = 0x400000,
  GuildBanker = 0x800000,
  SpellClick = 0x1000000,
  PlayerVehicle = 0x2000000,
  Mailbox = 0x4000000,
  ArtifactPowerRespec = 0x8000000,
  Transmogrifier = 0x10000000,
  Vaultkeeper = 0x20000000,
  WildBattlePet = 0x40000000,
  BlackMarket = 0x80000000,
}

Core.ClassID = {
  Warrior = 1,
  Paladin = 2,
  Hunter = 3,
  Rogue = 4,
  Priest = 5,
  DeathKnight = 6,
  Shaman = 7,
  Mage = 8,
  Warlock = 9,
  Monk = 10,
  Druid = 11,
  DemonHunter = 12,
  Evoker = 13
}

function Core.isUnit(object)
  return HWT.ObjectIsType(object, HWT.GetObjectTypeFlagsTable().Unit)
end

function Core.isGameObject(object)
  return HWT.ObjectIsType(object, HWT.GetObjectTypeFlagsTable().GameObject)
end

function Core.isItem(object)
  return HWT.ObjectIsType(object, HWT.GetObjectTypeFlagsTable().Item)
end

function Core.areFlagsSet(bitMap, flags)
  return bit.band(bitMap, flags) == flags
end

function Core.areUnitNPCFlagsSet(object, flags)
  local npcFlags = Core.retrieveObjectNPCFlags(object)
  return Core.areFlagsSet(npcFlags, flags)
end

function Core.isUnitNPCType(object, flags)
  return Core.isUnit(object) and Core.areUnitNPCFlagsSet(object, flags)
end

function Core.retrieveObjectNPCFlags(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__npcFlags,
    HWT.GetValueTypesTable().ULong)
end

function Core.retrieveUnitDataFlags(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__flags,
    HWT.GetValueTypesTable().ULong)
end

function Core.retrieveUnitDataFlags2(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__flags2,
    HWT.GetValueTypesTable().ULong)
end

function Core.retrieveUnitDataFlags3(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__flags3,
    HWT.GetValueTypesTable().ULong)
end

function Core.retrieveObjectDataDynamicFlags(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGObjectData__m_dynamicFlags,
    HWT.GetValueTypesTable().ULong)
end

function Core.isFoodVendor(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.FoodVendor)
end

function Core.isFoodVendor(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.FoodVendor)
end

function Core.isInnkeeper(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.Innkeeper)
end

function Core.isBanker(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.Banker)
end

function Core.isRepair(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.Repair)
end

function Core.isFlightMaster(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.FlightMaster)
end

function Core.hasGossip(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.Gossip)
end

local sellVendorFlags = {
  Core.NpcFlags.Vendor,
  Core.NpcFlags.AmmoVendor,
  Core.NpcFlags.FoodVendor,
  Core.NpcFlags.PoisonVendor,
  Core.NpcFlags.ReagentVendor,
  Core.NpcFlags.Repair
}

function Core.isSellVendor(object)
  if Core.isUnit(object) then
    local npcFlags = Core.retrieveObjectNPCFlags(object)
    return Array.any(sellVendorFlags, function(flags)
      return Core.areFlagsSet(npcFlags, flags)
    end)
  end

  return false
end

function Core.isFlightMasterDiscoverable(object)
  local value = HWT.ObjectDescriptor(object, 88, HWT.GetValueTypesTable().ULong)
  return Core.areFlagsSet(value, 2)
end

function Core.isDiscoverableFlightMaster(object)
  return Core.isFlightMaster(object) and Core.unitReaction('player',
    object) >= 4 and Core.isFlightMasterDiscoverable(object)
end

function Core.includePointerInObject(objects)
  local result = {}
  for pointer, object in pairs(objects) do
    object.pointer = pointer
    table.insert(result, object)
  end
  return result
end

function Core.isCharacterCasting()
  return Boolean.toBoolean(UnitCastingInfo('player'))
end

local AUTO_ATTACK_SPELL_ID = 6603

function Core.isCharacterAttacking()
  return IsCurrentSpell(AUTO_ATTACK_SPELL_ID)
end

local DRINK_ICON_ID = 132794

function Core.isCharacterDrinking()
  return Boolean.toBoolean(Core.findAuraByIcon(DRINK_ICON_ID, 'player'))
end

function Core.findAuraByIcon(icon, unit, filter)
  return AuraUtil.FindAura(_.iconPredicate, unit, filter, icon)
end

function _.iconPredicate(iconToFind, _, _, _, icon)
  return icon == iconToFind
end

local FOOD_ICON_ID = 134062

function Core.isCharacterEating()
  return Boolean.toBoolean(Core.findAuraByIcon(FOOD_ICON_ID, 'player'))
end

function Core.isCharacterGhost()
  return Boolean.toBoolean(UnitIsGhost('player'))
end

function Core.receiveMapIDForWhereTheCharacterIsAt()
  return C_Map.GetBestMapForUnit('player')
end

local MAXIMUM_RANGE_FOR_TRACE_LINE_CHECKS = 330

local MAX_Z = 10000
local MIN_Z = -10000

function Core.createPosition(x, y, z)
  return {
    x = x,
    y = y,
    z = z
  }
end

Core.WorldPosition = {}

function Core.WorldPosition:isEqual(otherPosition)
  return (
    self.continentID == otherPosition.continentID and
    Float.seemsCloseBy(self.x, otherPosition.x) and
    Float.seemsCloseBy(self.y, otherPosition.y) and
    Float.seemsCloseBy(self.z, otherPosition.z)
  )
end

function Core.WorldPosition:isDifferent(otherPosition)
  return not Core.WorldPosition:isEqual(otherPosition)
end

function Core.createWorldPosition(continentID, x, y, z)
  local worldPosition = {
    continentID = continentID,
    x = x,
    y = y,
    z = z
  }
  setmetatable(worldPosition, { __index = Core.WorldPosition })
  return worldPosition
end

function Core.createScreenPosition(x, y)
  return {
    x = x,
    y = y
  }
end

function Core.createWorldPositionFromPosition(continentID, position)
  return Core.createWorldPosition(continentID, position.x, position.y, position.z)
end

function Core.retrieveClosestPositionOnMesh(worldPosition, includeWater)
  if includeWater == nil then
    includeWater = true
  end

  Core.loadMapForContinentIfNotLoaded(worldPosition.continentID)

  local x, y, z = HWT.GetClosestPositionOnMesh(
    worldPosition.continentID, worldPosition.x, worldPosition.y, worldPosition.z, not includeWater)

  if x and y and z then
    return Core.createWorldPosition(worldPosition.continentID, x, y, z)
  else
    return nil
  end
end

function Core.retrieveWorldPositionFromMapPosition(mapPosition)
  if mapPosition.x > 1 or mapPosition.y > 1 then
    print('mapPosition.x > 1 or mapPosition.y > 1', debugstack())
  end
  local continentID, worldPosition = C_Map.GetWorldPosFromMapPos(mapPosition.mapID, mapPosition)
  local z
  local playerPosition = Core.retrieveCharacterPosition()
  if Math.euclideanDistance2D(playerPosition, worldPosition) <= MAXIMUM_RANGE_FOR_TRACE_LINE_CHECKS then
    local collisionPoint = Core.traceLineCollision(
      Core.createPosition(worldPosition.x, worldPosition.y, MAX_Z),
      Core.createPosition(worldPosition.x, worldPosition.y, MIN_Z)
    )
    if collisionPoint then
      z = collisionPoint.z
    end
  end

  if not z then
    z = Core.retrieveZCoordinate(Core.createWorldPosition(continentID, worldPosition.x, worldPosition.y, nil))
  end

  return Core.createWorldPosition(continentID, worldPosition.x, worldPosition.y, z)
end

local function lessThan(a, b)
  return a < b
end

function Core.retrieveZCoordinate(position)
  local DISTANCE_TO_POINT = 0.1

  local searchSpaces = {
    {
      from = MIN_Z,
      to = MAX_Z
    }
  }
  local zCoordinates = BinaryHeap.minUnique(lessThan)
  local numberOfZCoordinatesBefore = nil
  while true do
    local numberOfZCoordinatesBefore = zCoordinates:size()

    local zCoordinatesOfIteration = BinaryHeap.minHeap(lessThan)

    Array.forEach(searchSpaces, function(searchSpace)
      local deltaZ = (searchSpace.to - searchSpace.from) / 2
      local z = searchSpace.from + deltaZ
      local polygon = Core.retrieveClosestMeshPolygon(Core.createWorldPosition(position.continentID, position.x,
        position.y, z), 0, 0, deltaZ)
      if polygon then
        local z = Core.retrieveZCoordinateOnPolygon(position, polygon)
        if not zCoordinates.reverse[z] then
          zCoordinates:insert(z, z)
          zCoordinatesOfIteration:insert(z)
        end
      end
    end)

    local numberOfZCoordinatesAfter = zCoordinates:size()

    if numberOfZCoordinatesAfter == numberOfZCoordinatesBefore then
      break
    end

    local zCoordinatesToConstructSearchSpacesFrom = zCoordinatesOfIteration

    local smallestZCoordinateOfIteration = zCoordinatesOfIteration.values[1]
    local indexOfSmallestZCoordinateInZCoordinates = zCoordinates.reverse[smallestZCoordinateOfIteration]
    local smallerZCoordinateThanSmallestOneOfIteration
    if indexOfSmallestZCoordinateInZCoordinates == 1 then
      smallerZCoordinateThanSmallestOneOfIteration = MIN_Z
    else
      smallerZCoordinateThanSmallestOneOfIteration = zCoordinates.values[indexOfSmallestZCoordinateInZCoordinates - 1]
    end
    zCoordinatesToConstructSearchSpacesFrom:insert(smallerZCoordinateThanSmallestOneOfIteration)

    local biggestZCoordinateOfIteration = zCoordinatesOfIteration.values[zCoordinatesOfIteration:size()]
    local indexOfBiggerstZCoordinateInZCoordinates = zCoordinates.reverse[biggestZCoordinateOfIteration]
    local biggerZCoordinateThanSmallestOneOfIteration
    if indexOfBiggerstZCoordinateInZCoordinates == zCoordinates:size() then
      biggerZCoordinateThanSmallestOneOfIteration = MAX_Z
    else
      biggerZCoordinateThanSmallestOneOfIteration = zCoordinates.values[indexOfBiggerstZCoordinateInZCoordinates + 1]
    end
    zCoordinatesToConstructSearchSpacesFrom:insert(biggerZCoordinateThanSmallestOneOfIteration)

    searchSpaces = {}
    for index = 2, zCoordinatesToConstructSearchSpacesFrom:size() - 1 do
      local z = zCoordinatesToConstructSearchSpacesFrom.values[index]

      local fromZ1 = zCoordinatesToConstructSearchSpacesFrom.values[index - 1]
      local toZ1 = z - DISTANCE_TO_POINT
      if toZ1 > fromZ1 then
        table.insert(searchSpaces, {
          from = fromZ1,
          to = toZ1
        })
      end

      local fromZ2 = z + DISTANCE_TO_POINT
      local toZ2 = zCoordinatesToConstructSearchSpacesFrom.values[index + 1]
      if fromZ2 < toZ2 then
        table.insert(searchSpaces, {
          from = fromZ2,
          to = toZ2
        })
      end
    end

    if Array.isEmpty(searchSpaces) then
      break
    end
  end

  local positionAndPathObjects = Array.map(zCoordinates.values, function(z)
    local to = Core.createWorldPosition(position.continentID, position.x, position.y, z)
    local path = Core.findPathFromCharacterTo(to)
    return {
      position = to,
      path = path
    }
  end)

  local positionsWithPathsWherePathExistsTo = Array.filter(positionAndPathObjects, function(positionAndPath)
    return positionAndPath.path
  end)

  local positionAndPath
  if position.z then
    positionAndPath = Array.min(positionsWithPathsWherePathExistsTo, function(positionAndPath)
      return math.abs(position.z - positionAndPath.position.z)
    end)
  else
    positionAndPath = Array.min(positionsWithPathsWherePathExistsTo, function(positionAndPath)
      return Core.calculatePathLength(positionAndPath.path)
    end)
  end

  if positionAndPath then
    return positionAndPath.position.z
  else
    return nil
  end
end

function Core.calculatePathLength(path)
  local length = 0
  for index = 1, #path - 1 do
    length = length + Core.calculateDistanceBetweenPositions(path[index], path[index + 1])
  end
  return length
end

function Core.retrieveZCoordinate2(position, deltaZ)
  position = Core.createWorldPosition(position.continentID, position.x, position.y, position.z or 0)
  polygon = Core.retrieveClosestMeshPolygon(position, 0, 0, deltaZ)
  if polygon then
    return Core.retrieveZCoordinateOnPolygon(position, polygon)
  else
    return nil
  end
end

function Core.retrieveZCoordinateOnPolygon(position, polygon)
  Core.loadMapForContinentIfNotLoaded(position.continentID)
  local vertexes = HWT.GetMeshPolygonVertices(position.continentID, polygon)
  local vertex1 = vertexes[1]
  local vertex2 = vertexes[2]
  local vector1 = Vector:new(
    vertex2[1] - vertex1[1],
    vertex2[2] - vertex1[2],
    vertex2[3] - vertex1[3]
  )
  local vertex3 = vertexes[#vertexes]
  local vector2 = Vector:new(
    vertex3[1] - vertex1[1],
    vertex3[2] - vertex1[2],
    vertex3[3] - vertex1[3]
  )

  local targetVector = Vector:new(
    position.x - vertex1[1],
    position.y - vertex1[2],
    nil
  )

  local a = (vector2.y * targetVector.x - vector2.x * targetVector.y) / (vector1.x * vector2.y - vector2.x * vector1.y)
  local b = (vector1.y * targetVector.x - vector1.x * targetVector.y) / (vector2.x * vector1.y - vector1.x * vector2.y)

  local z = vertex1[3] + a * vector1.z + b * vector2.z

  local closestPositionOnMesh = Core.retrieveClosestPositionOnMesh(
    Core.createWorldPosition(position.continentID, position.x, position.y, z)
  )
  if closestPositionOnMesh and Float.seemsCloseBy(closestPositionOnMesh.x,
    position.x) and Float.seemsCloseBy(closestPositionOnMesh.y, position.y) then
    return closestPositionOnMesh.z
  else
    return z
  end

  return z
end

function Core.retrieveClosestMeshPolygon(worldPosition, deltaX, deltaY, deltaZ, includeWater)
  if includeWater == nil then
    includeWater = true
  end
  Core.loadMapForContinentIfNotLoaded(worldPosition.continentID)
  return HWT.GetClosestMeshPolygon(worldPosition.continentID, worldPosition.x, worldPosition.y, worldPosition.z, deltaX,
    deltaY, deltaZ, not includeWater)
end

function _.haveVectorsSameDirection(vector1, vector2)
  local scale = vector2.x / vector1.x
  local scaledVector2 = Vector:new(
    scale * vector2.x,
    scale * vector2.y,
    scale * vector2.z
  )
  return Float.seemsCloseBy(vector1.x, scaledVector2.x) and Float.seemsCloseBy(vector1.y,
    scaledVector2.y) and Float.seemsCloseBy(vector1.z, scaledVector2.z)
end

function Core.retrieveObjectPointers()
  local objectPointers = {}
  local count = HWT.GetObjectCount()
  for index = 1, count do
    local objectPointer = HWT.GetObjectWithIndex(index)
    table.insert(objectPointers, objectPointer)
  end

  return objectPointers
end

function Core.retrieveObjectPosition(objectIdentifier)
  local x, y, z = HWT.ObjectPosition(objectIdentifier)
  if not x or not y or not z then
    print('Core.retrieveObjectPosition', x, y, z)
  end
  if x and y and z then
    return Core.createWorldPosition(Core.retrieveCurrentContinentID(), x, y, z)
  else
    return nil
  end
end

function Core.findClosestObjectWithOneOfObjectIDsTo(objectIDs, to, customDistance)
  if type(objectIDs) == 'number' then
    objectIDs = { objectIDs }
  end

  local objectIDsSet = Set.create(objectIDs)

  return Core.findClosestObjectTo(
    to,
    function(pointer)
      local objectID = HWT.ObjectId(pointer)
      return Set.contains(objectIDsSet, objectID)
    end,
    customDistance
  )
end

function Core.retrieveCharacterPosition()
  return Core.retrieveObjectPosition('player')
end

function Core.findClosestObjectTo2D(objectIDs, to)
  return Core.findClosestObjectWithOneOfObjectIDsTo(objectIDs, to, Math.euclideanDistance2D)
end

function Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectIDs)
  local characterPosition = Core.retrieveCharacterPosition()
  return Core.findClosestObjectWithOneOfObjectIDsTo(objectIDs, characterPosition)
end

function Core.findClosestQuestRelatedObjectTo(questID, to)
  return Core.findClosestObjectTo(
    to,
    function(pointer)
      local questIDs = Set.create(ObjectQuests.ObjectQuests(pointer))
      return Set.contains(questIDs, questID)
    end
  )
end

function Core.findClosestObjectTo(to, customFilter, customDistance)
  if type(objectIDs) == 'number' then
    objectIDs = { objectIDs }
  end

  local filter = customFilter or Function.alwaysTrue
  local calculateDistance = customDistance or Core.calculateDistanceBetweenPositions

  local objectIDsSet = Set.create(objectIDs)

  local pointers = Core.retrieveObjectPointers()
  local filteredObjects = Array.filter(pointers, filter)

  local closestObject = Array.min(filteredObjects, function(pointer)
    local position = Core.retrieveObjectPosition(pointer)
    return calculateDistance(position, to)
  end)

  return closestObject
end

function Core.findClosestObjectToCharacter(customFilter)
  local characterPosition = Core.retrieveCharacterPosition()
  return Core.findClosestObjectTo(characterPosition, customFilter)
end

function Core.calculateDistanceBetweenPositions(a, b)
  if a.x == nil or a.y == nil or a.z == nil or b.x == nil or b.y == nil or b.z == nil then
    Logging.log(debugstack())
  end
  if a.z and b.z then
    return HWT.GetDistanceBetweenPositions(a.x, a.y, a.z, b.x, b.y, b.z)
  else
    return Math.euclideanDistance2D(a, b)
  end
end

function Core.calculate2DDistanceBetweenPositions(a, b)
  return Math.euclideanDistance2D(a, b)
end

function Core.calculateDistanceFromCharacterToPosition(position)
  local characterPosition = Core.retrieveCharacterPosition()
  return Core.calculateDistanceBetweenPositions(characterPosition, position)
end

function Core.calculateDistanceFromCharacterToObject(objectIdentifier)
  local characterPosition = Core.retrieveCharacterPosition()
  local objectPosition = Core.retrieveObjectPosition(objectIdentifier)
  return Core.calculateDistanceBetweenPositions(characterPosition, objectPosition)
end

function Core.retrieveCurrentContinentID()
  local continentID = select(8, GetInstanceInfo())
  return continentID
end

function Core.loadMapForCurrentContinentIfNotLoaded()
  Core.loadMapForContinentIfNotLoaded(Core.retrieveCurrentContinentID())
end

function Core.loadMapForContinentIfNotLoaded(continentID)
  if not HWT.IsMapLoaded(continentID) then
    HWT.LoadMap(continentID)
  end
end

function Core.isMapLoadedForCurrentContinent()
  return HWT.IsMapLoaded(Core.retrieveCurrentContinentID())
end

function Core.unitReaction(objectIdentifier1, objectIdentifier2)
  return UnitReaction(objectIdentifier1, objectIdentifier2)
end

function Core.retrievePositionFromPosition(position, distance, facing, pitch)
  return Core.createPosition(HWT.GetPositionFromPosition(
    position.x,
    position.y,
    position.z,
    distance,
    facing,
    pitch
  ))
end

function Core.retrievePositionBetweenPositions(from, to, distance)
  local vector = CreateVector3D(
    to.x - from.x,
    to.y - from.y,
    to.z - from.z
  )
  vector:Normalize()
  local x = from.x + distance * vector.x
  local y = from.y + distance * vector.y
  local z = from.z + distance * vector.z
  return Core.createPosition(x, y, z)
end

function Core.isCharacterAlive()
  return Core.isAlive('player')
end

function Core.isAlive(objectIdentifier)
  return not Core.isDead(objectIdentifier)
end

function Core.isDead(objectIdentifier)
  return UnitIsDead(objectIdentifier)
end

function Core.isCharacterMoving()
  return GetUnitSpeed('player') > 0
end

function Core.startMovingForward()
  MoveForwardStart()
  HWT.ResetAfk()
end

function Core.jumpOrStartAscend()
  JumpOrAscendStart()
  HWT.ResetAfk()
end

function Core.isCharacterCloseToPosition(position, maximumDistance)
  local characterPosition = Core.retrieveCharacterPosition()
  return (
    (not position.continentID or position.continentID == characterPosition.continentID) and
      Math.euclideanDistance(position, characterPosition) <= maximumDistance
  )
end

function Core.stopMovingForward()
  MoveForwardStop()
  HWT.ResetAfk()
end

function Core.doesPathExistFromCharacterTo(to, options)
  return Boolean.toBoolean(Core.findPathFromCharacterTo(to, options))
end

function Core.findPath(from, to, options)
  options = options or {}

  local includeWater
  if options.includeWater == nil then
    includeWater = true
  else
    includeWater = options.includeWater
  end

  local searchCapacity = options.searchCapacity or 1024
  local agentRadius = options.agentRadius or 0
  local searchDeviation = options.searchDeviation or 3
  local isSmooth = options.isSmooth or false

  local continentID = from.continentID
  Core.loadMapForContinentIfNotLoaded(continentID)
  local path = HWT.FindPath(continentID, from.x, from.y, from.z, to.x, to.y, to.z, not includeWater, searchCapacity,
    agentRadius, searchDeviation, isSmooth)
  if path then
    path = Core.convertHWTPathToPath(path)
  end
  return path
end

function Core.retrieveCharacterBoundingRadius()
  return HWT.UnitBoundingRadius('player')
end

function Core.findPathFromCharacterTo(to, options)
  local characterPosition = Core.retrieveCharacterPosition()
  return Core.findPath(characterPosition, to, options)
end

function Core.convertHWTPathToPath(path)
  return Array.map(path, Core.convertPositionArrayToPosition)
end

function Core.convertPositionArrayToPosition(positionArray)
  return Core.createPosition(unpack(positionArray))
end

function Core.castSpellByName(name, target)
  return CastSpellByName(name, target)
end

function Core.castSpellByID(spellID, target)
  return CastSpellByID(spellID, target)
end

function Core.stopAscending()
  AscendStop()
  HWT.ResetAfk()
end

function Core.calculateAnglesBetweenTwoPoints(a, b)
  local vector = CreateVector3D(
    b.x - a.x,
    b.y - a.y,
    (b.z or 0) - (a.z or 0)
  )
  vector:Normalize()
  local yaw, pitch = Vector3D_CalculateYawPitchFromNormalVector(vector)
  yaw = _.normalizeAngle(yaw)
  if a.z and b.z then
    pitch = _.normalizeAngle(pitch)
  else
    pitch = nil
  end
  return yaw, pitch
end

function _.normalizeAngle(angle)
  angle = angle % (2 * PI)
  if angle < 0 then
    angle = 2 * PI + angle
  end
  return angle
end

function Core.startStrafingLeft()
  StrafeLeftStart()
  HWT.ResetAfk()
end

function Core.startMovingBackward()
  MoveBackwardStart()
  HWT.ResetAfk()
end

function Core.startStrafingRight()
  StrafeRightStart()
  HWT.ResetAfk()
end

function Core.stopStrafingLeft()
  StrafeLeftStop()
  HWT.ResetAfk()
end

function Core.stopMovingBackward()
  MoveBackwardStop()
  HWT.ResetAfk()
end

function Core.stopStrafingRight()
  StrafeRightStop()
  HWT.ResetAfk()
end

function Core.isTrainerFrameShown()
  return ClassTrainerFrame:IsShown()
end

function Core.pressExtraActionButton1()
  ExtraActionButton1:Click()
end

function Core.isCharacterInVehicle()
  return UnitInVehicle('player')
end

function Core.runMacroText(text)
  RunMacroText(text)
end

function Core.canUnitAttackOtherUnit(unit1, unit2)
  return UnitCanAttack(unit1, unit2)
end

function Core.retrieveCharacterFaction()
  local unitFactionGroup = UnitFactionGroup('player')
  return unitFactionGroup
end

function Core.retrieveObjectName(objectIdentifier)
  return UnitName(objectIdentifier)
end

function Core.isLootable(objectIdentifier)
  return HWT.UnitIsLootable(objectIdentifier)
end

function Core.targetUnit(objectIdentifier)
  TargetUnit(objectIdentifier)
end

function Core.startAttacking()
  if not Core.isCharacterAttacking() then
    AttackTarget()
  end
end

function Core.isOnMeshPoint(position, includeWater)
  local closestMeshPoint = Core.retrieveClosestPositionOnMesh(position, includeWater)
  return (
    Float.seemsCloseBy(position.x, closestMeshPoint.x) and
      Float.seemsCloseBy(position.y, closestMeshPoint.y) and
      Float.seemsCloseBy(position.z, closestMeshPoint.z)
  )
end

function Core.convertWorldPositionToScreenPosition(position)
  if not position.continentID or position.continentID == Core.retrieveCurrentContinentID() then
    local isVisibleOnScreen, x, y = HWT.WorldToScreen(position.x, position.y, position.z)
    return Core.createScreenPosition(
      x * WorldFrame:GetWidth(),
      y * WorldFrame:GetHeight()
    ), isVisibleOnScreen
  else
    return nil
  end
end

function Core.isUnitInCombat(objectIdentifier)
  return UnitAffectingCombat(objectIdentifier)
end

function Core.isCharacterInCombat()
  return Core.isUnitInCombat('player')
end

function Core.retrieveObjectPointer(objectIdentifier)
  return HWT.GetObject(objectIdentifier)
end

function Core.isObjectiveComplete(questID, objectiveIndex)
  print(questID, objectiveIndex)
  local isObjectiveComplete = select(3, GetQuestObjectiveInfo(questID, objectiveIndex, false))
  return isObjectiveComplete
end

function Core.retrieveDistanceBetweenObjects(objectIdentifier1, objectIdentifier2)
  return HWT.GetDistanceBetweenObjects(objectIdentifier1, objectIdentifier2)
end

function Core.isUnitAttackingTheCharacter(unit)
  return Core.isUnitInCombat(unit) and HWT.UnitTarget(unit) == Core.retrieveObjectPointer('player')
end

function Core.receiveUnitsThatAttackTheCharacter()
  return Array.filter(Core.retrieveObjectPointers(), Core.isUnitAttackingTheCharacter)
end

function Core.retrieveObjects()
  local objectPointers = Core.retrieveObjectPointers()
  return Array.map(objectPointers, function(pointer)
    local x, y, z = HWT.ObjectPosition(pointer)
    return {
      pointer = pointer,
      objectID = HWT.ObjectId(pointer),
      x = x,
      y = y,
      z = z
    }
  end)
end

function Core.retrieveObjectWhichAreCloseToTheCharacter(maximumDistance)
  return Array.filter(Core.retrieveObjects(), function(object)
    return Core.isCharacterCloseToPosition(object, maximumDistance)
  end)
end

function Core.abandonQuest(questID)
  Compatibility.QuestLog.SetAbandonQuest(questID)
  Compatibility.QuestLog.AbandonQuest()
end

function Core.receiveCorpsePosition()
  return HWT.GetCorpsePosition()
end

function Core.interactWithObject(objectIdentifier)
  return C_PlayerInteractionManager.InteractUnit(objectIdentifier)
end

function Core.useItemByID(itemID, target)
  local itemName = Core.retrieveItemName(itemID)
  Core.useItemByName(itemName, target)
  Coroutine.waitForDuration(1)
  Coroutine.waitFor(function()
    return not Core.isCharacterCasting()
  end)
end

function Core.useItemByName(itemName, target)
  UseItemByName(itemName, target)
end

function Core.retrieveItemName(itemID)
  local item = Item:CreateFromItemID(itemID)
  _.waitForItemToLoad(item)
  return item:GetItemName()
end

function _.waitForItemToLoad(item)
  if not item:IsItemDataCached() then
    local thread = coroutine.running()

    item:ContinueOnItemLoad(function()
      coroutine.resume(thread)
    end)

    coroutine.yield()
  end
end

function Core.clickPosition(position, rightClick)
  HWT.ClickPosition(position.x, position.y, position.z, rightClick)
end

function Core.retrieveCharacterCombatRange()
  return HWT.UnitCombatReach('player')
end

function Core.isCharacterFlying()
  return Core.areFlagsSet(HWT.UnitMovementFlags('player'), HWT.GetUnitMovementFlagsTable().Flying)
end

function Core.isCharacterSwimming()
  return Core.areFlagsSet(HWT.UnitMovementFlags('player'), HWT.GetUnitMovementFlagsTable().Swimming)
end

function Core.retrieveClosestPositionWithPathTo(position, maximumDistance)
  if Core.doesPathExistFromCharacterTo(position) then
    return position
  else
    local closestPositionOnMesh = Core.retrieveClosestPositionOnMesh(position)
    if closestPositionOnMesh and Core.doesPathExistFromCharacterTo(closestPositionOnMesh) then
      return closestPositionOnMesh
    else
      local startAngle = math.rad(0)
      local deltaAngle = math.rad(90)

      for angle = startAngle, math.rad(360), deltaAngle do
        local x = position.x + math.cos(angle) * maximumDistance
        local y = position.y + math.sin(angle) * maximumDistance
        local z = Core.retrieveZCoordinate(Core.createWorldPosition(position.continentID, x, y, position.z))
        if z then
          return Core.createWorldPosition(position.continentID, x, y, z)
        end
      end
    end
  end

  return nil
end

function Core.stopMoving()
	Core.stopMovingForward()
end

Core.MAXIMUM_RANGE_FOR_TRACE_LINE_CHECKS = 330

function Core.isPositionInRangeForTraceLineChecks(position)
  return Core.calculateDistanceFromCharacterToPosition(position) <= Core.MAXIMUM_RANGE_FOR_TRACE_LINE_CHECKS
end

function Core.traceLine(from, to, hitFlags)
  if Core.isPositionInRangeForTraceLineChecks(from) then
    local x, y, z = HWT.TraceLine(
      from.x,
      from.y,
      from.z,
      to.x,
      to.y,
      to.z,
      hitFlags
    )
    if x then
      return Core.createPosition(x, y, z)
    else
      return nil
    end
  else
    return nil
  end
end

function Core.traceLineCollision(from, to)
  return Core.traceLine(from, to, Core.TraceLineHitFlags.COLLISION)
end

function Core.traceLineWater(from, to)
  return Core.traceLine(from, to, Core.TraceLineHitFlags.WATER)
end
