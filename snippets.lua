GMR.ExecutePath(true, convertPathToGMRPath(Movement.path))
GMR.GetPath(savedPosition.x, savedPosition.y, savedPosition.z)
GMR.LoadMeshFiles()

GMR.ExecutePath(true, GMR.GetPath(savedPosition.x, savedPosition.y, savedPosition.z))
local playerPosition = GMR.GetPlayerPosition(); print(GMR.GetDistanceBetweenPositions(playerPosition.x, playerPosition.y, playerPosition.z, Movement.path[5].x, Movement.path[5].y, Movement.path[5].z))
GMR.MoveTo(Movement.path[2].x, Movement.path[2].y, Movement.path[2].z)
isPositionInTheAir(Movement.path[2])
moveToSavedPath()
coroutine.wrap(function () DevTools_Dump(retrieveQuestStartPoints()) end)()

GMR.GetPathBetweenPoints(1112.2868652344, -466.92352294922, 20.854103088379, 1069, -494, 0.023681640625)

GMR.MeshTo(GMR.ObjectPosition('target'))

GMR.GetPath(GMR.ObjectPosition('target'))

GMR.ExecutePath(true, GMR.GetPath(GMR.ObjectPosition('target')))

GMR.OffMeshHandler(GMR.ObjectPosition('target'))

GMR.MoveTo(GMR.ObjectPosition('target'))

GMR.GetDistanceBetweenObjects('player', 'target')

GMR.GetDistanceToPosition(Movement.path[8].x, Movement.path[8].y, Movement.path[8].z)

canBeMovedFromAToB(Movement.path[#Movement.path - 1], Movement.path[#Movement.path])

canBeMovedFromPointToPoint(Movement.path[1], Movement.path[2])

canBeWalkedOrSwamFromPointToPoint(Movement.path[1], Movement.path[2])

canBeJumpedFromPointToPoint(Movement.path[1], Movement.path[2])  -- true

canBeFlownFromPointToPoint(Movement.path[1], Movement.path[2])

canBeMovedFromPointToPoint(Movement.path[6], Movement.path[7])

canBeWalkedOrSwamFromPointToPoint(Movement.path[6], Movement.path[7]) -- true

canBeJumpedFromPointToPoint(Movement.path[6], Movement.path[7])

canBeFlownFromPointToPoint(Movement.path[6], Movement.path[7])

canPlayerStandOnPoint(Movement.path[7])

canBeMovedFromPointToPointCheckingSubSteps(Movement.path[6], Movement.path[7])

canBeMovedFromPointToPoint(Movement.path[4], Movement.path[5])

canBeWalkedOrSwamFromPointToPoint(Movement.path[4], Movement.path[5])

canBeJumpedFromPointToPoint(Movement.path[4], Movement.path[5])

canBeMovedFromPointToPoint(Movement.path[5], Movement.path[6])

canBeWalkedOrSwamFromPointToPoint(Movement.path[5], Movement.path[6])

canBeJumpedFromPointToPoint(Movement.path[5], Movement.path[6]) -- true

canBeFlownFromPointToPoint(Movement.path[5], Movement.path[6])

-- CHARACTER_HEIGHT

local pz = GMR.GetPlayerPosition().z; print(Movement.path[8].z - pz)

canBeMovedFromPointToPoint(Movement.path[9], Movement.path[10])

canBeWalkedOrSwamFromPointToPoint(Movement.path[9], Movement.path[10])

canBeJumpedFromPointToPoint(Movement.path[9], Movement.path[10])

canBeFlownFromPointToPoint(Movement.path[9], Movement.path[10])

canBeMovedFromPointToPoint(Movement.path[17], Movement.path[18])

canBeWalkedOrSwamFromPointToPoint(Movement.path[17], Movement.path[18])

canBeJumpedFromPointToPoint(Movement.path[17], Movement.path[18])

canBeFlownFromPointToPoint(Movement.path[17], Movement.path[18])

canBeMovedFromPointToPoint(Movement.path[18], Movement.path[19])

canBeWalkedOrSwamFromPointToPoint(Movement.path[18], Movement.path[19])

canBeJumpedFromPointToPoint(Movement.path[18], Movement.path[19])

canBeFlownFromPointToPoint(Movement.path[18], Movement.path[19])

canPlayerStandOnPoint(Movement.path[19], { withMount = true })

p = PointToValueMap:new()

p:retrieveValue({ x = 0, y = 0, z = 0})

p:setValue({ x = 0, y = 0, z = 0}, 1)

p:setValue({ x = 1, y = 2, z = 3}, 2)

p:retrieveValue({ x = 1, y = 2, z = 3})
