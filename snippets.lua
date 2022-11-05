GMR.ExecutePath(true, convertPathToGMRPath(path))
GMR.GetPath(savedPosition.x, savedPosition.y, savedPosition.z)
GMR.LoadMeshFiles()

GMR.ExecutePath(true, GMR.GetPath(savedPosition.x, savedPosition.y, savedPosition.z))
local playerPosition = GMR.GetPlayerPosition(); print(GMR.GetDistanceBetweenPositions(playerPosition.x, playerPosition.y, playerPosition.z, path[5].x, path[5].y, path[5].z))
GMR.MoveTo(path[2].x, path[2].y, path[2].z)
isPositionInTheAir(path[2])
moveToSavedPath()
