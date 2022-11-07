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

