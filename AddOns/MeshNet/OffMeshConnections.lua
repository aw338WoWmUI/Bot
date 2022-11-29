local addOnName, AddOn = ...
MeshNet = MeshNet or {}

local _ = {}

local firstOffMeshConnectionPoint = nil
local secondOffMeshConnectionPoint = nil

local firstOffMeshConnectionPolygonSetHook = Hook.Hook:new()

MeshNet.firstOffMeshConnectionPolygon = nil
MeshNet.secondOffMeshConnectionPolygon = nil

local RANGE = 5
local CIRCLE_RADIUS = 0.5

function MeshNet.setFirstOffMeshConnectionPolygon()
  MeshNet.firstOffMeshConnectionPolygon = _.retrieveClosestPolygon()
  firstOffMeshConnectionPolygonSetHook:runCallbacks()
end

function MeshNet.setSecondOffMeshConnectionPolygon()
  MeshNet.secondOffMeshConnectionPolygon = _.retrieveClosestPolygon()
end

function MeshNet.connectPolygons(isBidirectional, polygonFlags)
  if MeshNet.firstOffMeshConnectionPolygon and MeshNet.secondOffMeshConnectionPolygon then
    local continentID = Core.retrieveCurrentContinentID()
    local vertices1 = Array.map(HWT.GetMeshPolygonVertices(continentID, MeshNet.firstOffMeshConnectionPolygon),
      function(point)
        return Core.createPosition(unpack(point))
      end)
    if vertices1 then
      local vertices2 = Array.map(HWT.GetMeshPolygonVertices(continentID, MeshNet.secondOffMeshConnectionPolygon),
        function(point)
          return Core.createPosition(unpack(point))
        end)
      if vertices2 then
        local combinations = _.generateCombinations(vertices1, vertices2)
        local shortestConnection = Array.min(combinations, function(combination)
          return Math.euclideanDistance(combination[1], combination[2])
        end)
        firstOffMeshConnectionPoint = shortestConnection[1]
        secondOffMeshConnectionPoint = shortestConnection[2]
        MeshNet.saveOffMeshConnection(isBidirectional, polygonFlags)
      end
    end
  end
end

function MeshNet.setFirstOffMeshConnectionPoint()
  firstOffMeshConnectionPoint = Core.retrieveCharacterPosition()
end

function MeshNet.setSecondOffMeshConnectionPoint()
  secondOffMeshConnectionPoint = Core.retrieveCharacterPosition()
end

function MeshNet.saveOffMeshConnection(isBidirectional, polygonFlags)
  if isBidirectional == nil then
    isBidirectional = true
  end

  local continentID = select(8, GetInstanceInfo())
  local offMeshConnection = {
    continentID,
    firstOffMeshConnectionPoint.x,
    firstOffMeshConnectionPoint.y,
    firstOffMeshConnectionPoint.z,
    secondOffMeshConnectionPoint.x,
    secondOffMeshConnectionPoint.y,
    secondOffMeshConnectionPoint.z,
    isBidirectional,
    polygonFlags
  }
  table.insert(AddOn.offMeshConnections, offMeshConnection)
  _.addOffMeshConnection(offMeshConnection)
  _.writeOffMeshConnectionsToFile()
  firstOffMeshConnectionPoint = nil
  secondOffMeshConnectionPoint = nil
end

function MeshNet.removeClosestOffMeshConnection()
  local closestOffMeshConnection = AddOn.findClosestOffMeshConnection()
  if closestOffMeshConnection then
    return _.removeOffMeshConnection(closestOffMeshConnection)
  else
    return false
  end
end

function MeshNet.onFirstOffMeshConnectionPolygonSet(callback)
  firstOffMeshConnectionPolygonSetHook:registerCallback(callback)
end

function _.addOffMeshConnection(offMeshConnection)
  HWT.AddOffmeshConnection(unpack(offMeshConnection))
end

function _.addOffMeshConnections(offMeshConnections)
  Array.forEach(offMeshConnections, _.addOffMeshConnection)
end

HWT.doWhenHWTIsLoaded(function()
  Core.loadMapForCurrentContinentIfNotLoaded()

  Conditionals.doOnceWhen(
    Core.isMapLoadedForCurrentContinent,
    function()
      local continentID = Core.retrieveCurrentContinentID()
      local offMeshConnectionsForContinent = Array.filter(AddOn.offMeshConnections, function(offMeshConnection)
        local offMeshConnectionContinentID = offMeshConnection[1]
        return offMeshConnectionContinentID == continentID
      end)
      if #HWT.GetOffmeshConnections(continentID) < #offMeshConnectionsForContinent then
        _.addOffMeshConnections(offMeshConnectionsForContinent)
      end
    end
  )

  Draw.Sync(function()
    if firstOffMeshConnectionPoint or secondOffMeshConnectionPoint then
      Draw.SetColorRaw(0, 0, 1, 1)
      if firstOffMeshConnectionPoint and secondOffMeshConnectionPoint then
        Draw.Line(
          firstOffMeshConnectionPoint.x, firstOffMeshConnectionPoint.y, firstOffMeshConnectionPoint.z,
          secondOffMeshConnectionPoint.x, secondOffMeshConnectionPoint.y, secondOffMeshConnectionPoint.z
        )
      end
      if firstOffMeshConnectionPoint then
        Draw.Circle(firstOffMeshConnectionPoint.x, firstOffMeshConnectionPoint.y, firstOffMeshConnectionPoint.z,
          CIRCLE_RADIUS)
      end
      if secondOffMeshConnectionPoint then
        Draw.Circle(secondOffMeshConnectionPoint.x, secondOffMeshConnectionPoint.y,
          secondOffMeshConnectionPoint.z, CIRCLE_RADIUS)
      end
    end

    if MeshNet.firstOffMeshConnectionPolygon then
      local options = {
        color = { 0, 0, 1, 1 },
        fillColor = { 0, 0, 1, 0.2 }
      }
      MeshNet.visualizePolygon(MeshNet.firstOffMeshConnectionPolygon, options)
    end

    if MeshNet.secondOffMeshConnectionPolygon then
      local options = {
        color = { 0, 0, 1, 1 },
        fillColor = { 0, 0, 1, 0.2 }
      }
      MeshNet.visualizePolygon(MeshNet.secondOffMeshConnectionPolygon, options)
    end
  end)
end)

function _.writeOffMeshConnectionsToFile()
  local filePath = HWT.GetWoWDirectory() .. '/Interface/AddOns/MeshNet/OffMeshConnectionsDatabase.lua'
  HWT.WriteFile(filePath,
    'local addOnName, AddOn = ...\n\nAddOn.offMeshConnections = ' .. Serialization.valueToString(AddOn.offMeshConnections) .. '\n')
end

function AddOn.findClosestOffMeshConnection()
  local continentID = select(8, GetInstanceInfo())
  local connections = HWT.GetOffmeshConnections(continentID)

  -- HWT.GetOffmeshConnectionDetails(HWT.GetOffmeshConnections(select(8, GetInstanceInfo()))[1])

  if connections and Array.hasElements(connections) then
    return Array.min(connections, function(connection)
      local x1, y1, z1, x2, y2, z2 = select(4, HWT.GetOffmeshConnectionDetails(connection))
      return math.min(
        Core.calculateDistanceFromCharacterToPosition(Core.createPosition(x1, y1, z1)),
        Core.calculateDistanceFromCharacterToPosition(Core.createPosition(x2, y2, z2))
      )
    end)
  else
    return nil
  end
end

local function doConnectionDetailsMatch(a, b)
  return Array.equals(a, b)
end

local function findConnection(connections, connection)
  local continentID, _, _, x1, y1, z1, x2, y2, z2, isBidirectional = HWT.GetOffmeshConnectionDetails(connection)
  local connectionDetails = { continentID, x1, y1, z1, x2, y2, z2, isBidirectional }
  return Array.find(connections, Function.partial(doConnectionDetailsMatch, connectionDetails))
end

function _.removeOffMeshConnection(connection)
  local index = select(2,
    findConnection(AddOn.offMeshConnections, connection))
  if index ~= -1 then
    table.remove(AddOn.offMeshConnections, index)
    _.writeOffMeshConnectionsToFile()
  end

  return HWT.RemoveOffmeshConnection(connection)
end

function _.generateCombinations(a, b)
  local combinations = {}
  Array.forEach(a, function(elementA)
    Array.forEach(b, function(elementB)
      local combination = { elementA, elementB }
      table.insert(combinations, combination)
    end)
  end)
  return combinations
end

function _.retrieveClosestPolygon()
  local position = Core.retrieveCharacterPosition()
  return Core.retrieveClosestMeshPolygon(position, RANGE, RANGE, RANGE)
end
