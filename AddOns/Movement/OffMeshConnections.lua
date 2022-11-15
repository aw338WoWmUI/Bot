local offMeshConnections = {
  {
    0,
    -8437.087890625,
    376.62121582031,
    135.7060546875,
    -8435.947265625,
    366.25323486328,
    135.45243835449,
    true
  },
  {
    0,
    -8476.66796875,
    989.84027099609,
    78.525085449219,
    -8482.90625,
    984.82489013672,
    72.792686462402,
    true
  }
}

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
  addOffMeshConnections(offMeshConnections)

  if GMR_SavedVariablesPerCharacter.offMeshConnections then
    addOffMeshConnections(GMR_SavedVariablesPerCharacter.offMeshConnections)
  end

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
