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

doWhenGMRIsFullyLoaded(function()
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end

  Conditionals.doOnceWhen(
    function()
      return GMR.IsMeshLoaded()
    end,
    function()
      addOffMeshConnections(AddOn.offMeshConnections)

      if GMR_SavedVariablesPerCharacter.offMeshConnections then
        addOffMeshConnections(GMR_SavedVariablesPerCharacter.offMeshConnections)
      end
    end
  )

  hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
    if firstOffMeshConnectionPoint or secondOffMeshConnectionPoint then
      GMR.LibDraw.SetColorRaw(0, 0, 1, 1)
      if firstOffMeshConnectionPoint and secondOffMeshConnectionPoint then
        GMR.LibDraw.Line(
          firstOffMeshConnectionPoint.x, firstOffMeshConnectionPoint.y, firstOffMeshConnectionPoint.z,
          secondOffMeshConnectionPoint.x, secondOffMeshConnectionPoint.y, secondOffMeshConnectionPoint.z
        )
      end
      if firstOffMeshConnectionPoint then
        GMR.LibDraw.Circle(firstOffMeshConnectionPoint.x, firstOffMeshConnectionPoint.y, firstOffMeshConnectionPoint.z,
          CIRCLE_RADIUS)
      end
      if secondOffMeshConnectionPoint then
        GMR.LibDraw.Circle(secondOffMeshConnectionPoint.x, secondOffMeshConnectionPoint.y,
          secondOffMeshConnectionPoint.z, CIRCLE_RADIUS)
      end
    end
  end)
end)

function setFirstOffMeshConnectionPoint()
  firstOffMeshConnectionPoint = GMR.GetPlayerPosition()
end

function setSecondOffMeshConnectionPoint()
  secondOffMeshConnectionPoint = GMR.GetPlayerPosition()
end

function saveOffMeshConnection(isBidirectional, polygonFlags)
  if not GMR_SavedVariablesPerCharacter.offMeshConnections then
    GMR_SavedVariablesPerCharacter.offMeshConnections = {}
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
  table.insert(GMR_SavedVariablesPerCharacter.offMeshConnections, offMeshConnection)
  addOffMeshConnection(offMeshConnection)
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
        GMR.GetDistanceToPosition(x1, y1, z1),
        GMR.GetDistanceToPosition(x2, y2, z2)
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
  local connectionInSavedVariablesIndex = select(2,
    findConnection(GMR_SavedVariablesPerCharacter.offMeshConnections, connection))
  print('connectionInSavedVariablesIndex', connectionInSavedVariablesIndex)
  if connectionInSavedVariablesIndex ~= -1 then
    table.remove(GMR_SavedVariablesPerCharacter.offMeshConnections, connectionInSavedVariablesIndex)
  end

  local connectionInFileIndex = select(2, findConnection(AddOn.offMeshConnections, connection))
  if connectionInFileIndex ~= -1 then
    print('The connection seems to also be in the file "AddOns/Movement/OffMeshConnections.lua" in the table "offMeshConnections". You can remove it from there manually. It has the index ' .. connectionInFileIndex .. ' (starting with index 1)')
  end

  -- HWT.GetWoWDirectory() .. '/Interface/AddOns/Movement/OffMeshConnectionsDatabase.lua'

  return HWT.RemoveOffmeshConnection(connection)
end
