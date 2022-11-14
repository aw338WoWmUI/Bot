doWhenGMRIsFullyLoaded(function()
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end

  local continentID = select(8, GetInstanceInfo())
  local position = Movement.retrievePlayerPosition()
  local polygon = HWT.GetClosestMeshPolygon(continentID, position.x, position.y, position.z, 1000, 1000, 1000)
  DevTools_Dump(HWT.GetMeshPolygonVertices(continentID, polygon))

  hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
    GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
    local continentID = select(8, GetInstanceInfo())
    local position = Movement.retrievePlayerPosition()
    local polygon = HWT.GetClosestMeshPolygon(continentID, position.x, position.y, position.z, 1000, 1000, 1000)

    local polygons = HWT.GetMeshPolygons(continentID, polygon, position.x, position.y, position.z, 50)

    Array.forEach(polygons, function (polygon)
      local vertices = HWT.GetMeshPolygonVertices(continentID, polygon)
      local previousPoint = vertices[1]
      for index = 2, #vertices do
        local point = vertices[index]
        GMR.LibDraw.Line(
          previousPoint[1],
          previousPoint[2],
          previousPoint[3],
          point[1],
          point[2],
          point[3]
        )
        previousPoint = point
      end
      GMR.LibDraw.Line(
        previousPoint[1],
        previousPoint[2],
        previousPoint[3],
        vertices[1][1],
        vertices[1][2],
        vertices[1][3]
      )
    end)
  end)
end)
