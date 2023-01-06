Bot = Bot or {}
local __, AddOn = ...
local _ = {}

local initializableTogglable = InitializableTogglable.InitializableTogglable:new(function()
  return Bot.createTogglableFarming(_.retrieveNextPosition, _.findThings)
end)

function Bot.toggleDragonShardOfKnowledgeFarming()
  initializableTogglable:toggle()
end

local initializableTogglable2 = InitializableTogglable.InitializableTogglable:new(function()
  return Bot.createTogglableAssistedFarming(_.retrieveNextPosition, _.findThings)
end)

function Bot.toggleAssistedDragonShardOfKnowledgeFarming()
  initializableTogglable2:toggle()
end

function _.retrieveNextPosition()
  return Bot.Farming.retrieveNextPosition(_.retrieveAllPositions)
end

___ = _

-- /dump ___.retrieveAllPositions()

function _.retrieveAllPositions()
  local plugin = HandyNotes.plugins['HandyNotes_Dragonflight']
  local mapID = Core.receiveMapIDForWhereTheCharacterIsAt()
  local HBD = LibStub('HereBeDragons-2.0')
  local positions = {}
  for coordinates, mapID2 in plugin:GetNodes2(mapID, false) do
    local mapX, mapY = floor(coordinates / 10000) / 10000, (coordinates % 10000) / 10000
    if mapID2 and mapID2 ~= mapID then
      mapX, mapY = HBD:TranslateZoneCoordinates(mapX, mapY, mapID2, mapID)
    end
    local position = Core.retrieveWorldPositionFromMapPosition(Core.createMapPosition(mapID, mapX, mapY),
      Core.retrieveHighestZCoordinate)
    table.insert(positions, position)
  end
  return positions
end

local CHEST_CLOSED = -65536

local unitClassesWhichSeemToDropDragonShardOfKnowledge = Set.create({
  'worldboss',
  'rareelite',
  'rare'
})

function Bot.findThingsThatDropDragonShardOfKnowledge()
  local objectsWhoDrop = {}

  Draw.Sync(function()
    local characterPosition = Core.retrieveCharacterPosition()
    if characterPosition then
      local closestPositionOnMesh = Core.retrieveClosestPositionOnMesh(characterPosition)
      Array.forEach(objectsWhoDrop, function(object)
        local position = Core.retrieveObjectPosition(object)
        if position then
          Draw.SetColorRaw(0, 1, 0, 1)
          Draw.Circle(position.x, position.y, position.z, 1)
          local hasDrawnPathToObject = false
          if closestPositionOnMesh then
            local path = Core.findPath(closestPositionOnMesh, position)
            if path then
              Core.drawPath(path)
              hasDrawnPathToObject = true
            end
          end
          if not hasDrawnPathToObject then
            Draw.SetColorRaw(0, 1, 0, 1)
            Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
          end
        end
      end)
    end
  end)

  C_Timer.NewTicker(1, function()
    objectsWhoDrop = _.findThings()
    --Array.forEach(objectsWhoDrop, function (object)
    --  print('distance', Core.calculateDistanceFromCharacterToObject(object))
    --end)
  end)
end

function _.findThings()
  local objects = Core.retrieveObjectPointers()
  return Array.filter(objects, function(object)
    local objectID = HWT.ObjectId(object)
    return (
      (
        (
          Set.contains(unitClassesWhichSeemToDropDragonShardOfKnowledge, UnitClassification(object)) or
            Set.contains(AddOn.droppedBy, objectID)
        ) and
          Core.isAlive(object) and
          Core.canCharacterAttackUnit(object)
      ) or
        (Set.contains(AddOn.containedIn1, objectID) or Set.contains(AddOn.containedIn2,
          objectID) or Set.contains(AddOn.containedIn3,
          objectID)) and Core.retrieveObjectDataDynamicFlags(object) == CHEST_CLOSED
    )
  end)
end
