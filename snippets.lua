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
