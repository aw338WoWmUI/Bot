local playerPosition = Core.retrieveCharacterPosition(); print(Core.calculateDistanceBetweenPositions(playerPosition, Movement.path[5]))
Movement.isPositionInTheAir(Movement.path[2])
Movement.moveToSavedPath()
coroutine.wrap(function () DevTools_Dump(retrieveQuestStartPoints()) end)()

Core.retrieveDistanceBetweenObjects('player', 'target')

Core.calculateDistanceFromCharacterToPosition(Movement.path[8])

Movement.canBeMovedFromAToB(Movement.path[#Movement.path - 1], Movement.path[#Movement.path])

Movement.canBeMovedFromPointToPoint(Movement.path[1], Movement.path[2])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[1], Movement.path[2])

Movement.canBeJumpedFromPointToPoint(Movement.path[1], Movement.path[2])  -- true

Movement.canBeFlownFromPointToPoint(Movement.path[1], Movement.path[2])

Movement.canBeMovedFromPointToPoint(Movement.path[6], Movement.path[7])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[6], Movement.path[7]) -- true

Movement.canBeJumpedFromPointToPoint(Movement.path[6], Movement.path[7])

Movement.canBeFlownFromPointToPoint(Movement.path[6], Movement.path[7])

Movement.canPlayerStandOnPoint(Movement.path[7])

Movement.canBeMovedFromPointToPointCheckingSubSteps(Movement.path[6], Movement.path[7])

Movement.canBeMovedFromPointToPoint(Movement.path[4], Movement.path[5])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[4], Movement.path[5])

Movement.canBeJumpedFromPointToPoint(Movement.path[4], Movement.path[5])

Movement.canBeMovedFromPointToPoint(Movement.path[5], Movement.path[6])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[5], Movement.path[6])

Movement.canBeJumpedFromPointToPoint(Movement.path[5], Movement.path[6]) -- true

Movement.canBeFlownFromPointToPoint(Movement.path[5], Movement.path[6])

-- CHARACTER_HEIGHT

local pz = Core.retrieveCharacterPosition().z; print(Movement.path[8].z - pz)

Movement.canBeMovedFromPointToPoint(Movement.path[9], Movement.path[10])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[9], Movement.path[10])

Movement.canBeJumpedFromPointToPoint(Movement.path[9], Movement.path[10])

Movement.canBeFlownFromPointToPoint(Movement.path[9], Movement.path[10])

Movement.canBeMovedFromPointToPoint(Movement.path[17], Movement.path[18])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[17], Movement.path[18])

Movement.canBeJumpedFromPointToPoint(Movement.path[17], Movement.path[18])

Movement.canBeFlownFromPointToPoint(Movement.path[17], Movement.path[18])

Movement.canBeMovedFromPointToPoint(Movement.path[18], Movement.path[19])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[18], Movement.path[19])

Movement.canBeJumpedFromPointToPoint(Movement.path[18], Movement.path[19])

Movement.canBeFlownFromPointToPoint(Movement.path[18], Movement.path[19])

Movement.canPlayerStandOnPoint(Movement.path[19], { withMount = true })

p = PointToValueMap:new()

p:retrieveValue({ x = 0, y = 0, z = 0})

p:setValue({ x = 0, y = 0, z = 0}, 1)

p:setValue({ x = 1, y = 2, z = 3}, 2)

p:retrieveValue({ x = 1, y = 2, z = 3})

Movement.canBeFlownFromPointToPoint(Movement.path[2], Movement.path[3])

Core.retrieveObjectPointer('target')

Core.retrieveObjectWhichAreCloseToTheCharacter(250)

coroutine.wrap(function () DevTools_Dump(retrieveQuestStartPoints()) end)()

C_SuperTrack.GetSuperTrackedQuestID()

shouldQuestBeAvailable(Array.find(quests, function (quest) return quest.id == 26391 end))

Compatibility.QuestLog.isQuestFlaggedCompleted(quest.id)

Compatibility.QuestLog.isQuestFlaggedCompleted(26389)

retrieveAvailableQuestLines(425)

retrieveAvailableQuestLines(37)

C_Map.GetBestMapForUnit('player')

WorldMapFrame:GetMapID()

coroutine.wrap(function () DevTools_Dump(retrieveObjectPoints()) end)()

questID = C_SuperTrack.GetSuperTrackedQuestID()

C_GossipInfo.GetOptions()

-- 38009

C_QuestLog.GetNextWaypoint(C_SuperTrack.GetSuperTrackedQuestID())

coroutine.wrap(function () DevTools_Dump(retrieveNavigationPosition()) end)()

__A.ObjectQuests(Core.retrieveObjectPointer('target'))

-- __A.ObjectIsQuestObjective()
-- __A.ObjectQuestGiverStatus()
 __A.ObjectQuestGiverStatus('target')
-- __A.GetObjectQuestGiverStatusesTable()

HWT.ObjectQuests(Core.findClosestObjectToCharacter(209436))

HWT.GameObjectType(Core.findClosestObjectToCharacter(209436))

coroutine.wrap(function () DevTools_Dump(retrieveObjectivePoints()) end)()
coroutine.wrap(function () DevTools_Dump(retrieveQuestStartPoints()) end)()
coroutine.wrap(function () DevTools_Dump(retrieveObjectPoints()) end)()
HWT.ObjectQuests(Core.findClosestObjectToCharacter(209463))
HWT.GameObjectType(Core.findClosestObjectToCharacter(209463))
HWT.ObjectTypeFlags(Core.findClosestObjectToCharacter(209463))
HWT.ObjectIsQuestObjective(Core.findClosestObjectToCharacter(209463))
-- 209550
HWT.ObjectIsQuestObjective(Core.findClosestObjectToCharacter(209550), false)
seemsToBeQuestObject(Core.findClosestObjectToCharacter(209550))

coroutine.wrap(function () DevTools_Dump(retrieveFlightMasterDiscoveryPoints()) end)()

coroutine.wrap(function () DevTools_Dump(retrievePoints()) end)()

coroutine.wrap(function () Movement.mountOnFlyingMount() end)()

runAsCoroutine(function () DevTools_Dump(retrieveObjectivePoints()) end)

runAsCoroutine(function () DevTools_Dump(retrieveQuestStartPoints()) end)

runAsCoroutine(function () DevTools_Dump(retrieveQuestStartPoints()) end)

runAsCoroutine(function () DevTools_Dump(retrieveObjectPoints()) end)

log(QuestieDB:GetQuest(6).Objectives)

log(QuestieDB:GetQuest(76).Objectives)

Core.calculateAnglesBetweenTwoPoints(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

Movement.canBeMovedFromPointToPointCheckingSubSteps(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

Movement.canBeMovedFromPointToPoint(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

Movement.canBeJumpedFromPointToPoint(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

HWT.ObjectFacing('player')

HWT.ObjectQuests(Core.findClosestObjectToCharacter(42940))

Movement.canBeMovedFromPointToPointCheckingSubSteps(position1, position2)

aaaaaaa2394ui2u32uio()

HWT.ObjectTypeFlags(Core.findClosestObjectToCharacter(203972)) -- 257
HWT.ObjectIsQuestObjective(Core.findClosestObjectToCharacter(203972), false)
HWT.GameObjectType(Core.findClosestObjectToCharacter(203972))

Movement.isJumpSituation(savedPosition)

AStar.canPathBeMoved(Movement.path)

Movement.traceLineCollision(Movement.createPointWithZOffset(MovementPath[10], 1), Movement.createPointWithZOffset(MovementPath[10], -1000))

-- z

Movement.canPlayerStandOnPoint(MovementPath[6])

Movement.canPlayerStandOnPoint(MovementPath[4])

Compatibility.QuestLog.isComplete(C_SuperTrack.GetSuperTrackedQuestID())

position1 = Movement.retrieveCharacterPosition()
position2 = Movement.createPointWithZOffset(position1, 3.5)

C_QuestLog.GetQuestsOnMap(Core.receiveMapIDForWhereTheCharacterIsAt())

pointer = HWT.GetObject('target')

Core.calculateDistanceFromCharacterToObject(pointer)

runAsCoroutine(function () DevTools_Dump(Questing_.retrieveQuestStartPointsFromQuestLines()) end)

HWT.IsMapLoaded(Core.receiveMapIDForWhereTheCharacterIsAt())

HWT.LoadMap(0)

Core.retrieveClosestPositionOnMesh(Core.retrieveObjectPosition('target'))

p = Core.retrieveObjectPosition('target')

Core.retrieveClosestPositionOnMesh(Core.createWorldPosition(p.continentID, p.x, p.y, 10000))

Core.retrieveZCoordinate(Core.retrieveObjectPosition('target'))

HWT.GetAnglesBetweenObjects('player', 'target')

Core.calculateAnglesBetweenTwoPoints(Core.retrieveObjectPosition('player'), Core.retrieveObjectPosition('target'))

HWT.LoadMap(Core.retrieveCurrentContinentID(), 'retail2')

HWT.IsMapLoaded(Core.retrieveCurrentContinentID())

HWT.LoadMap(Core.retrieveCurrentContinentID())

HWT.UnloadMap(Core.retrieveCurrentContinentID())

Core.retrieveZCoordinate(QuestingPointToShow)

-- QuestingPointToShow.z

Core.retrieveZCoordinate(Core.createWorldPosition(QuestingPointToShow.continentID, QuestingPointToShow.x, QuestingPointToShow.y, 0))

Core.retrieveZCoordinate2(Core.createWorldPosition(QuestingPointToShow.continentID, QuestingPointToShow.x, QuestingPointToShow.y, QuestingPointToShow.z - 1), 1)

Core.retrieveZCoordinate(Core.createWorldPosition(QuestingPointToShow.continentID, QuestingPointToShow.x, QuestingPointToShow.y, nil))

Core.retrieveZCoordinate(Core.createWorldPosition(Core.retrieveCurrentContinentID(), savedPosition.x, savedPosition.y, nil))

Core.calculateAnglesBetweenTwoPoints(Core.retrieveCharacterPosition(), Core.retrieveObjectPosition('target'))
HWT.ObjectFacing('player')
HWT.UnitPitch('player')

-- MovementPath[5]

Movement.canReachWaypointWithCurrentMovementDirection(MovementPath[5])

Movement.canReachWaypointWithCurrentMovementDirection(MovementPath[1])

Movement.canReachWaypointWithCurrentMovementDirection(savedPosition)

runAsCoroutine(function () Movement.facePoint(Core.retrieveObjectPosition('target')) end)

Core.findClosestObjectToCharacter(63596)

HWT.GetObjectCount(); print(HWT.GetObjectWithIndex(1))

print(HWT.GetObjectWithIndex(1))

select(2, C_Navigation.GetFrame():GetCenter())

-- /script z2 = Core.retrieveCharacterPosition()

Movement.canBeWalkedOrSwamFromPointToPoint(MovementPath[25], MovementPath[26])
Movement.canPlayerStandOnPoint(MovementPath[26])
Movement.canBeMovedFromPointToPointCheckingSubSteps(MovementPath[25], MovementPath[26])
Movement_.canPlayerBeOnPoint2(MovementPath[26])

C_TooltipInfo.GetUnit('target')
-- C_TooltipInfo.GetUnit('target').lines
-- C_TooltipInfo.GetUnit('target').lines[index].args

function tooltipa()
  local tooltip = C_TooltipInfo.GetUnit('target')
  TooltipUtil.SurfaceArgs(tooltip.lines[6])
  return tooltip.lines[6]
end

Development.logObjectInfo()

C_TooltipInfo.GetUnit(Core.findClosestObjectToCharacter(197008))

C_TooltipInfo.GetWorldCursor()

-- C_TooltipInfo.GetObject

p = Core.retrieveObjectPointer('target')

C_TooltipInfo.GetUnit(p)
