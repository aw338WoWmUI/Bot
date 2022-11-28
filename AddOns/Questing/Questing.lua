local addOnName, AddOn = ...
Questing = Questing or {}

INTERACT_DISTANCE = 5.3

function generateQuestNameList(quests)
  return strjoin(', ', unpack(Array.map(quests, function(quest)
    local questID = quest[1]
    return QuestUtils_GetQuestName(questID)
  end)))
end

function setSpecializationToPreferredOrFirstDamagerSpecialization()
  local specializationNameSetting = nil -- FIXME: Load from some setting
  local numberOfSpecializations = GetNumSpecializations(false, false)
  for index = 1, numberOfSpecializations do
    local name, _, _, role = select(
      2,
      GetSpecializationInfo(index, false, false, nil, UnitSex('player'))
    )
    if (
      (specializationNameSetting and name == specializationNameSetting) or
        (not specializationNameSetting and role == 'DAMAGER')
    ) then
      SetSpecialization(index, false)
      break
    end
  end
end

function moveToWhenNotMoving(x, y, z)
  if not Core.isCharacterMoving() then
    Questing.Coroutine.moveTo(Core.createPosition(x, y, z))
  end
end

function createMoveToAction(x, y, z)
  local stopMoving = nil
  local firstRun = true
  return {
    run = function()
      if firstRun then
        firstRun = false
      end
      moveToWhenNotMoving(x, y, z)
    end,
    isDone = function()
      return Core.isCharacterCloseToPosition(Core.createPosition(x, y, z), 1)
    end
  }
end

function createQuestingMoveToAction(x, y, z, distance)
  return {
    run = function()
      Questing.Coroutine.moveTo(Core.createPosition(x, y, z))
    end,
    isDone = function()
      return Core.isCharacterCloseToPosition(Core.createPosition(x, y, z), distance or 1)
    end
  }
end


-- QuestieDB:GetQuestsByZoneId(zoneId)
-- /dump MapUtil.GetDisplayableMapForPlayer()
-- /dump QuestieDB:GetQuestsByZoneId(MapUtil.GetDisplayableMapForPlayer())
-- /dump WorldMapFrame:GetMapID()
-- /dump C_Map.GetMapInfo(MapUtil.GetDisplayableMapForPlayer())

-- /dump QuestieDB:GetQuestsByZoneId(QuestiePlayer:GetCurrentZoneId())

local function convertObjectToList(object)
  local list = {}
  for key, value in pairs(object) do
    local item = {
      key = key,
      value = value
    }
    table.insert(list, item)
  end
  return list
end

function determineQuestStarter(quest)
  local NPC = quest.Starts.NPC
  if NPC then
    local startNPCID = quest.Starts.NPC[1]
    local npc = QuestieDB:GetNPC(startNPCID)
    return npc
  else
    return nil
  end
end

local function determineTurnInObject(quest)
  local objectID = quest.Finisher.Id
  local object
  if quest.Finisher.Type == 'object' then
    object = QuestieDB:GetObject(objectID)
  else
    object = QuestieDB:GetNPC(objectID)
  end
  return object
end

function determineFirstObjectSpawn(object)
  local spawns = convertObjectToList(object.spawns)
  local spawn = spawns[1]
  if spawn then
    return {
      zoneID = spawn.key,
      x = spawn.value[1][1],
      y = spawn.value[1][2]
    }
  else
    return nil
  end
end

function determineQuestStartPoint(quest)
  local npc = determineQuestStarter(quest)
  return npc and determineFirstObjectSpawn(npc) or nil
end

local function isMapCoordinateInValidRange(coordinate)
  return coordinate >= 0 and coordinate <= 1
end

local function convertQuestiePointToMapPoint(point)
  return {
    x = point.x / 100,
    y = point.y / 100
  }
end

local function isValidMapPoint(point)
  return isMapCoordinateInValidRange(point.x) and isMapCoordinateInValidRange(point.y)
end

function convertMapPositionToWorldPosition(point)
  local mapID = ZoneDB:GetUiMapIdByAreaId(point.zoneID)
  local mapPoint = convertQuestiePointToMapPoint(point)
  if isValidMapPoint(mapPoint) then
    return Core.retrieveWorldPositionFromMapPosition({
      mapID = mapID,
      x = mapPoint.x,
      y = mapPoint.y
    })
  else
    return nil
  end
end

function f()
  local mapID = C_Map.GetBestMapForUnit("player")
  local positionOnMap = C_Map.GetPlayerMapPosition(mapID, 'player')
  local position = Core.retrieveWorldPositionFromMapPosition({
    mapID = mapID,
    x = positionOnMap.x,
    y = positionOnMap.y
  })
  print(position.continentID, position.x, position.y, position.z)
  local playerPosition = Core.retrieveCharacterPosition()
  print(playerPosition.x, playerPosition.y, playerPosition.z)
end

function g()
  local mapID = C_Map.GetBestMapForUnit("player")
  local positionOnMap = { x = 0.37011867761612, y = 0.43634825944901 }
  local position = Core.retrieveWorldPositionFromMapPosition({
    mapID = mapID,
    x = positionOnMap.x,
    y = positionOnMap.y
  })
  print(position.continentID, position.x, position.y, position.z)
  local playerPosition = {
    x = 6427.9458007812,
    y = 517.38958740234,
    z = 8.6709308624268
  }
  print(playerPosition.x, playerPosition.y, playerPosition.z)
end

local dockPosition = {
  x = -8641.3349609375,
  y = 1331.2628173828,
  z = 5.2331943511963
}

function moveToDockInStormwind()
  Questing.Coroutine.moveTo(dockPosition)
end

function waitForPlayerToHaveArrivedAtDockInStormwind()
  Movement.waitForPlayerToBeOnPosition(dockPosition)
end

function waitForShipToHaveArrivedAtStormwind()
  Coroutine.waitFor(function()
    local objectGUID = Core.findClosestObjectToCharacterWithOneOfObjectIDs(25013)
    if objectGUID then
      local position = Core.retrieveObjectPosition(objectGUID)
      return Core.calculateDistanceBetweenPositions(
        Core.createPosition(
          -8647.5673828125,
          1336.5311279297,
          6.0574994087219
        ),
        position
      ) <= 1
    end
  end)
end

function moveOntoShip()
  local object = Core.findClosestObjectToCharacterWithOneOfObjectIDs(25013)
  if object then
    local position = Core.retrieveObjectPosition(object)
    Questing.Coroutine.moveTo(position)
  end
end

function isEasternKingdoms(continentID)
  return continentID == 0
end

function isKalimdor(continentID)
  return continentID == 1
end

function moveToContinent(continentID)
  local currentContinentID = select(8, GetInstanceInfo())
  if isEasternKingdoms(currentContinentID) and isKalimdor(continentID) then
    moveToDockInStormwind()
    waitForPlayerToHaveArrivedAtDockInStormwind()
    waitForShipToHaveArrivedAtStormwind()
    moveOntoShip()
    -- waitForShipToHaveArrivedAtAuberdine()
    -- moveOffShip()
  elseif isKalimdor(currentContinentID) and isEasternKingdoms(continentID) then
    -- moveToDockInAuberdine()
    -- waitForPlayerToHaveArrivedAtDockInAuberdine()
    -- waitForShipToHaveArrivedAtAuberdine()
    moveOntoShip()
    waitForShipToHaveArrivedAtStormwind()
    -- moveOffShip()
  end
end

function seemsToBeQuestObject(object)
  return bit.band(HWT.ObjectDynamicFlags(object), 0x20) == 0x20
end

function addObjectIDToObjective(questObjectiveToObjectIDs, objectID, questObjectiveIndex)
  if not questObjectiveToObjectIDs[questObjectiveIndex] then
    questObjectiveToObjectIDs[questObjectiveIndex] = {}
  end
  questObjectiveToObjectIDs[questObjectiveIndex][objectID] = true
end

function findObjectiveWhichMatchesAndAddItToTheLookup(questObjectiveToObjectIDs, questObjectives, objectIdentifier,
  doesMatch)
  local questObjective, questObjectiveIndex = Array.find(questObjectives, doesMatch)
  if questObjective then
    local objectID = HWT.ObjectId(objectIdentifier)
    if objectID then
      addObjectIDToObjective(questObjectiveToObjectIDs, objectID, questObjectiveIndex)
    end
  end

  return questObjective ~= nil
end

function retrieveQuestLogQuests()
  local quests = {}
  for index = 1, Compatibility.QuestLog.retrieveNumberOfQuestLogEntries() do
    local info = Compatibility.QuestLog.retrieveInfo(index) -- isComplete seems to be a 1 or nil
    if not info.isHeader then
      table.insert(quests, info)
    end
  end
  return quests
end

function retrieveQuestLogQuests2()
  local quests = {}
  for index = 1, Compatibility.QuestLog.retrieveNumberOfQuestLogEntries() do
    local info = Compatibility.QuestLog.retrieveInfo(index) -- isComplete seems to be a 1 or nil
    if not info.isHeader then
      local quest = {
        id = info.questID,
        name = info.title
      }
      table.insert(quests, quest)
    end
  end
  return quests
end

function retrieveQuestLogQuestIDs()
  return Array.map(retrieveQuestLogQuests2(), function(quest)
    return quest.id
  end)
end

function findRelationsToQuests(tooltipBaseName, unitID)
  local quests = retrieveQuestLogQuests2()
  local questIdToObjectives = Object.fromEntries(Array.map(quests, function(quest)
    return {
      key = quest.id,
      value = C_QuestLog.GetQuestObjectives(quest.id)
    }
  end))
  local questNameToId = Object.fromEntries(Array.map(quests, function(quest)
    return {
      key = quest.name,
      value = quest.id
    }
  end))
  local relations = {}
  for lineIndex = 1, 18 do
    local textLeft = _G[tooltipBaseName .. 'TextLeft' .. lineIndex]
    if textLeft then
      local text = textLeft:GetText()
      local questID = questNameToId[text]
      if questID then
        local questObjectives = questIdToObjectives[questID]
        questObjectiveToIsRelatedTo = relations[questID] or {}
        lineIndex = lineIndex + 1
        while lineIndex <= 18 do
          local textLeft = _G[tooltipBaseName .. 'TextLeft' .. lineIndex]
          if textLeft then
            local text = textLeft:GetText()
            local questObjective, questObjectiveIndex = Array.find(questObjectives, function(questObjective)
              return questObjective.text == text
            end)
            if questObjective then
              questObjectiveToIsRelatedTo[questObjectiveIndex] = true
            else
              break
            end
          end
          lineIndex = lineIndex + 1
        end
        if not relations[questID] and next(questObjectiveToIsRelatedTo) then
          relations[questID] = questObjectiveToIsRelatedTo
        end
      end
    end
  end
  return relations
end
