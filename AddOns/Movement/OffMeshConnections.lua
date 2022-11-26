local addOnName, AddOn = ...

local _ = {}

local firstOffMeshConnectionPoint = nil
local secondOffMeshConnectionPoint = nil

local CIRCLE_RADIUS = 0.5

local function addOffMeshConnection(offMeshConnection)
  HWT.AddOffmeshConnection(unpack(offMeshConnection))
end

local function addOffMeshConnections(offMeshConnections)
  Array.forEach(offMeshConnections, addOffMeshConnection)
end

doWhenHWTIsLoaded(function()
  Core.loadMapForCurrentContinentIfNotLoaded()

  local appSessionToken = HWT.GetAppSessionToken()
  if appSessionToken ~= MovementLastOffMeshConnectionAddingAppSessionToken then
    Conditionals.doOnceWhen(
      function()
        return Core.isMapLoadedForCurrentCotinent()
      end,
      function()
        MovementLastOffMeshConnectionAddingAppSessionToken = appSessionToken
        addOffMeshConnections(AddOn.offMeshConnections)
      end
    )
  end

  LibDraw.Sync(function()
    if firstOffMeshConnectionPoint or secondOffMeshConnectionPoint then
      LibDraw.SetColorRaw(0, 0, 1, 1)
      if firstOffMeshConnectionPoint and secondOffMeshConnectionPoint then
        LibDraw.Line(
          firstOffMeshConnectionPoint.x, firstOffMeshConnectionPoint.y, firstOffMeshConnectionPoint.z,
          secondOffMeshConnectionPoint.x, secondOffMeshConnectionPoint.y, secondOffMeshConnectionPoint.z
        )
      end
      if firstOffMeshConnectionPoint then
        LibDraw.Circle(firstOffMeshConnectionPoint.x, firstOffMeshConnectionPoint.y, firstOffMeshConnectionPoint.z,
          CIRCLE_RADIUS)
      end
      if secondOffMeshConnectionPoint then
        LibDraw.Circle(secondOffMeshConnectionPoint.x, secondOffMeshConnectionPoint.y,
          secondOffMeshConnectionPoint.z, CIRCLE_RADIUS)
      end
    end
  end)
end)

function setFirstOffMeshConnectionPoint()
  firstOffMeshConnectionPoint = Core.retrieveCharacterPosition()
end

function setSecondOffMeshConnectionPoint()
  secondOffMeshConnectionPoint = Core.retrieveCharacterPosition()
end

local function writeOffMeshConnectionsToFile()
  local filePath = HWT.GetWoWDirectory() .. '/Interface/AddOns/Movement/OffMeshConnectionsDatabase.lua'
  HWT.WriteFile(filePath,
    'local addOnName, AddOn = ...\n\nAddOn.offMeshConnections = ' .. Serialization.valueToString(AddOn.offMeshConnections) .. '\n')
end

function saveOffMeshConnection(isBidirectional, polygonFlags)
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
  addOffMeshConnection(offMeshConnection)
  writeOffMeshConnectionsToFile()
  firstOffMeshConnectionPoint = nil
  secondOffMeshConnectionPoint = nil
end

function removeClosestOffMeshConnection()
  local closestOffMeshConnection = AddOn.findClosestOffMeshConnection()
  if closestOffMeshConnection then
    return _.removeOffMeshConnection(closestOffMeshConnection)
  else
    return false
  end
end

function AddOn.findClosestOffMeshConnection()
  local continentID = select(8, GetInstanceInfo())
  local connections = HWT.GetOffmeshConnections(continentID)

  -- HWT.GetOffmeshConnectionDetails(HWT.GetOffmeshConnections(select(8, GetInstanceInfo()))[1])

  if connections and Array.hasElements(connections) then
    return Array.min(connections, function(connection)
      local x1, y1, z1, x2, y2, z2 = select(4, HWT.GetOffmeshConnectionDetails(connection))
      return math.min(
        Core.calculateDistanceFromCharacterToPosition(createPoint(x1, y1, z1)),
        Core.calculateDistanceFromCharacterToPosition(createPoint(x2, y2, z2))
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
    writeOffMeshConnectionsToFile()
  end

  return HWT.RemoveOffmeshConnection(connection)
end
