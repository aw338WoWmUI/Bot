Core = {}

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
  return toBoolean(UnitCastingInfo('player'))
end

local AUTO_ATTACK_SPELL_ID = 6603

function Core.isCharacterAttacking()
  return IsCurrentSpell(AUTO_ATTACK_SPELL_ID)
end

local DRINK_ICON_ID = 132794

function Core.isCharacterDrinking()
  return toBoolean(Core.findAuraByIcon(DRINK_ICON_ID, 'player'))
end

function Core.findAuraByIcon(icon, unit, filter)
  return AuraUtil.FindAura(_.iconPredicate, unit, filter, icon)
end

function _.iconPredicate(iconToFind, _, _, _, icon)
  return icon == iconToFind
end

local FOOD_ICON_ID = 134062

function Core.isCharacterEating()
  return toBoolean(Core.findAuraByIcon(FOOD_ICON_ID, 'player'))
end

function Core.isCharacterGhost()
  return toBoolean(UnitIsGhost('player'))
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

function Core.createWorldPosition(continentID, x, y, z)
  return {
    continentID = continentID,
    x = x,
    y = y,
    z = z
  }
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
  local playerPosition = Movement.retrieveCharacterPosition()
  if euclideanDistance2D(playerPosition, worldPosition) <= MAXIMUM_RANGE_FOR_TRACE_LINE_CHECKS then
    print(3)
    local collisionPoint = Movement.traceLineCollision(
      Core.createPosition(worldPosition.x, worldPosition.y, MAX_Z),
      Core.createPosition(worldPosition.x, worldPosition.y, MIN_Z)
    )
    if collisionPoint then
      z = collisionPoint.z
    end
  end

  if not z then
    print(4)
    z = Core.retrieveZCoordinate(Core.createWorldPosition(continentID, worldPosition.x, worldPosition.y, nil))
  end

  return Core.createWorldPosition(continentID, worldPosition.x, worldPosition.y, z)
end

function Core.retrieveZCoordinate(position)
  position = Core.createWorldPosition(position.continentID, position.x, position.y, position.z or 0)
  polygon = Core.retrieveClosestMeshPolygon(position, 0, 0, 10000)
  local vertexes = HWT.GetMeshPolygonVertices(position.continentID, polygon, 0, 0, 10000)
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

  local a = (vector2.y * position.x - vector2.x * position.y) / (vector1.x * vector2.y - vector2.x * vector1.y)
  local b = (vector1.y * position.x - vector1.x * position.y) / (vector2.x * vector1.y - vector1.x * vector2.y)

  local z = vertex1[3] + a * vector1.z + b * vector2.z

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
  local objectPointers = select(3, HWT.GetObjectCount())
  return objectPointers
end

function Core.retrieveObjectPosition(objectIdentifier)
  return Core.createWorldPosition(Core.retrieveCurrentContinentID(), HWT.ObjectPosition(objectIdentifier))
end

function Core.retrieveCharacterPosition()
  return Core.retrieveObjectPosition('player')
end

function Core.findClosestObject(objectIDs)
  if type(objectIDs) == 'number' then
    objectIDs = { objectIDs }
  end

  local objectIDsSet = Set.create(objectIDs)

  local objectWithOneTheObjectIDs = Array.filter(Core.retrieveObjectPointers(), function(pointer)
    return Set.contains(objectIDsSet, HWT.ObjectId(pointer))
  end)

  local characterPosition = Core.retrieveCharacterPosition()
  local closestObject = Array.min(objectWithOneTheObjectIDs, function(pointer)
    local position = Core.retrieveObjectPosition(pointer)
    return euclideanDistance(position, characterPosition)
  end)

  return closestObject
end

function Core.calculateDistanceBetweenPositions(a, b)
  return HWT.GetDistanceBetweenPositions(a.x, a.y, a.z, b.x, b.y, b.z)
end

function Core.calculateDistanceFromCharacterToPosition(position)
  local characterPosition = Core.retrieveCharacterPosition()
  return Core.calculateDistanceBetweenPositions(characterPosition, position)
end

function Core.calculateDistanceToObject(objectIdentifier)
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

function Core.isMapLoadedForCurrentCotinent()
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
  return Core.createPosition(HWT.GetPositionBetweenPositions(from.x, from.y, from.z, to.x, to.y, to.z, distance))
end

function Core.isCharacterAlive()
  return Core.isAlive('player')
end

function Core.isAlive(objectIdentifier)
  return Core.isDead(objectIdentifier)
end

function Core.isDead(objectIdentifier)
	return UnitIsDead(objectIdentifier)
end

function Core.isCharacterMoving()
  return GetUnitSpeed('player') > 0
end

function Core.startMovingForward()
  MoveForwardStart()
end

function Core.jumpOrStartAscend()
  JumpOrAscendStart()
end

function Core.isCharacterCloseToPosition(position, maximumDistance)
  local characterPosition = Core.retrieveCharacterPosition()
  return (
    (not position.continentID or position.continentID == characterPosition.continentID) and
      euclideanDistance(position, characterPosition) <= maximumDistance
  )
end

function Core.stopMovingForward()
  MoveForwardStop()
end

function Core.doesPathExistFromCharacterTo(to, includeWater, searchCapacity, agentRadius, searchDeviation, isSmooth)
  return toBoolean(Core.FindPathFromCharacterTo(to, includeWater, searchCapacity, agentRadius, searchDeviation,
    isSmooth))
end

function Core.FindPath(from, to, includeWater, searchCapacity, agentRadius, searchDeviation, isSmooth)
  if includeWater == nil then
    includeWater = true
  end
  return HWT.FindPath(from.continentID, from.x, from.y, from.z, to.x, to.y, to.z, not includeWater, searchCapacity,
    agentRadius, searchDeviation, isSmooth)
end

function Core.FindPathFromCharacterTo(to, includeWater, searchCapacity, agentRadius, searchDeviation, isSmooth)
  local characterPosition = Core.retrieveCharacterPosition()
  return Core.FindPath(characterPosition, to, includeWater, searchCapacity, agentRadius, searchDeviation, isSmooth)
end

function Core.CastSpellByName(name, target)
  return CastSpellByName(name, target)
end

function Core.stopAscending()
  AscendStop()
end

function Core.calculateAnglesBetweenTwoPoints(a, b)
  local vector = CreateVector3D(
    b.x - a.x,
    b.y - a.y,
    b.z - a.z
  )
  vector:Normalize()
  local yaw = 2 * PI - math.asin(-vector.y)
  local pitch = math.atan2(vector.x, vector.z) - 0.5 * PI
  return yaw, pitch
end

function Core.startStrafingLeft()
  StrafeLeftStart()
end

function Core.startMovingBackward()
  MoveBackwardStart()
end

function Core.startStrafingRight()
  StrafeRightStart()
end

function Core.stopStrafingLeft()
  StrafeLeftStop()
end

function Core.stopMovingBackward()
  MoveBackwardStop()
end

function Core.stopStrafingRight()
  StrafeRightStop()
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
    local x, y = select(2, HWT.WorldToScreen(position.x, position.y, position.z))
    return Core.createScreenPosition(
      x * WorldFrame:GetWidth(),
      y * WorldFrame:GetHeight()
    )
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
  local isObjectiveComplete = select(3, GetQuestObjectiveInfo(questID, objectiveIndex))
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
      ID = HWT.ObjectId(pointer),
      x = x,
      y = y,
      z = z
    }
  end)
end

function Core.retrieveObjectWhichAreCloseToTheCharacter(maximumDistance)
	return Array.filter(Core.retrieveObjects(), function (object)
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
  return InteractUnit(objectIdentifier)
end

function Core.useItemByID(itemID, target)
  local itemName = Core.retrieveItemName(itemID)
  Core.useItemByName(itemName, target)
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
