GMR.ExecutePath(true, Movement.convertPathToGMRPath(Movement.path))
GMR.GetPath(savedPosition.x, savedPosition.y, savedPosition.z)
GMR.LoadMeshFiles()

GMR.ExecutePath(true, GMR.GetPath(savedPosition.x, savedPosition.y, savedPosition.z))
local playerPosition = GMR.GetPlayerPosition(); print(GMR.GetDistanceBetweenPositions(playerPosition.x, playerPosition.y, playerPosition.z, Movement.path[5].x, Movement.path[5].y, Movement.path[5].z))
GMR.MoveTo(Movement.path[2].x, Movement.path[2].y, Movement.path[2].z)
Movement.isPositionInTheAir(Movement.path[2])
Movement.moveToSavedPath()
coroutine.wrap(function () DevTools_Dump(retrieveQuestStartPoints()) end)()

GMR.GetPathBetweenPoints(1112.2868652344, -466.92352294922, 20.854103088379, 1069, -494, 0.023681640625)

GMR.MeshTo(GMR.ObjectPosition('target'))

GMR.GetPath(GMR.ObjectPosition('target'))

GMR.ExecutePath(true, GMR.GetPath(GMR.ObjectPosition('target')))

GMR.OffMeshHandler(GMR.ObjectPosition('target'))

GMR.MoveTo(GMR.ObjectPosition('target'))

GMR.GetDistanceBetweenObjects('player', 'target')

GMR.GetDistanceToPosition(Movement.path[8].x, Movement.path[8].y, Movement.path[8].z)

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

local pz = GMR.GetPlayerPosition().z; print(Movement.path[8].z - pz)

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

GMR.ObjectPointer('target')

getmetatable(GMR.GetObject('target'))

GMR.GetObject(GMR.ObjectPointer('target'))

Object.keys(GMR.GetObject('target'))

type(GMR.GetObject('target'))

GMR.ObjectFlags('target')

GMR.ObjectFlags2('target')

GMR.GetObjectWithIndex(1)

GMR.GetObjectWithXYZ()

GMR.ScanObjects()

getmetatable(GMR.GetObject(GMR.ObjectPointer('target')))

GMR.GetObject(GMR.ObjectPointer('target'))

GMR.GetNearbyObjects(250)

coroutine.wrap(function () DevTools_Dump(retrieveQuestStartPoints()) end)()

C_SuperTrack.GetSuperTrackedQuestID()

shouldQuestBeAvailable(Array.find(quests, function (quest) return quest.id == 26391 end))

GMR.IsQuestCompleted(quest.id)

GMR.IsQuestCompleted(26389)

retrieveAvailableQuestLines(GMR.GetMapId())

retrieveAvailableQuestLines(425)

retrieveAvailableQuestLines(37)

C_Map.GetBestMapForUnit('player')

WorldMapFrame:GetMapID()

coroutine.wrap(function () DevTools_Dump(retrieveObjectPoints()) end)()

questID = C_SuperTrack.GetSuperTrackedQuestID()

C_GossipInfo.GetOptions()

-- 38009

C_QuestLog.GetNextWaypoint(C_SuperTrack.GetSuperTrackedQuestID())

GMR.Questing.GetQuestInfo(C_SuperTrack.GetSuperTrackedQuestID())

coroutine.wrap(function () DevTools_Dump(retrieveNavigationPosition()) end)()

GMR_SavedVariablesPerCharacter.SelectedMount = GetSpellInfo(470)

--GMR.RunEncryptedScript(GMR.Encrypt('print("test"); DevTools_Dump({...})'))
GMR.RunEncryptedScript(GMR.Encrypt('_G.__A = ({...})[1]'))

__A.ObjectQuests(GMR.ObjectPointer('target'))

-- __A.ObjectIsQuestObjective()
-- __A.ObjectQuestGiverStatus()
 __A.ObjectQuestGiverStatus('target')
-- __A.GetObjectQuestGiverStatusesTable()

HWT.ObjectQuests(GMR.FindObject(209436))

HWT.GameObjectType(GMR.FindObject(209436))

coroutine.wrap(function () DevTools_Dump(retrieveObjectivePoints()) end)()
coroutine.wrap(function () DevTools_Dump(retrieveQuestStartPoints()) end)()
coroutine.wrap(function () DevTools_Dump(retrieveObjectPoints()) end)()
HWT.ObjectQuests(GMR.FindObject(209463))
HWT.GameObjectType(GMR.FindObject(209463))
HWT.ObjectTypeFlags(GMR.FindObject(209463))
HWT.ObjectIsQuestObjective(GMR.FindObject(209463))
-- 209550
HWT.ObjectIsQuestObjective(GMR.FindObject(209550), false)
seemsToBeQuestObject(GMR.FindObject(209550))

coroutine.wrap(function () DevTools_Dump(retrieveFlightMasterDiscoveryPoints()) end)()

coroutine.wrap(function () DevTools_Dump(retrievePoints()) end)()

GMR.RunString('_G.HWT = ({...})[1]')
GMR.RunString('_G.TEST = {...}')

coroutine.wrap(function () Movement.mountOnFlyingMount() end)()

runAsCoroutine(function () DevTools_Dump(retrieveObjectivePoints()) end)

runAsCoroutine(function () DevTools_Dump(retrieveQuestStartPoints()) end)

runAsCoroutine(function () DevTools_Dump(retrieveQuestStartPoints()) end)

Array.map(Questing.Database.retrieveQuestsThatShouldBeAvailable(GMR.GetMapId()), function (quest) return quest.name end)

runAsCoroutine(function () DevTools_Dump(retrieveObjectPoints()) end)

log(QuestieDB:GetQuest(6).Objectives)

log(QuestieDB:GetQuest(76).Objectives)

Movement.calculateAngleBetweenTwoPoints(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

Movement.canBeMovedFromPointToPointCheckingSubSteps(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

Movement.canBeMovedFromPointToPoint(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

Movement.canBeWalkedOrSwamFromPointToPoint(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

Movement.canBeJumpedFromPointToPoint(Movement.path[#Movement.path - 2], Movement.path[#Movement.path - 1])

GMR.ObjectRawFacing('player')

HWT.ObjectQuests(GMR.FindObject(42940))

Movement.canBeMovedFromPointToPointCheckingSubSteps(position1, position2)

aaaaaaa2394ui2u32uio()

GMR.ObjectRawType(GMR.FindObject(203972))
HWT.ObjectTypeFlags(GMR.FindObject(203972)) -- 257
HWT.ObjectIsQuestObjective(GMR.FindObject(203972), false)
HWT.GameObjectType(GMR.FindObject(203972))

Movement.isJumpSituation(savedPosition)

position2 = createPoint(GMR.GetClosestPointOnMesh(select(8, GetInstanceInfo()), QuestingPointToMove.x, QuestingPointToMove.y, QuestingPointToMove.z))

AStar.canPathBeMoved(Movement.path)

Movement.traceLineCollision(Movement.createPointWithZOffset(MovementPath[10], 1), Movement.createPointWithZOffset(MovementPath[10], -1000))

-- z

Movement.canPlayerStandOnPoint(MovementPath[6])

Movement.canPlayerStandOnPoint(MovementPath[4])

Compatibility.QuestLog.isComplete(C_SuperTrack.GetSuperTrackedQuestID())

position1 = Movement.retrievePlayerPosition()
position2 = Movement.createPointWithZOffset(position1, 3.5)
