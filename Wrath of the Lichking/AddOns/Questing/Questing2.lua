local function retrieveQuestLogQuestIDs()
  local questIDs = {}
  for index = 1, GetNumQuestLogEntries() do
    local isHeader, _, _, _, questID = select(4, GetQuestLogTitle(index)) -- isComplete seems to be a 1 or nil
    if not isHeader then
      table.insert(questIDs, questID)
    end
  end
  return questIDs
end

local function retrieveQuestLogQuests()
  local questIDs = retrieveQuestLogQuestIDs()
  return Array.map(questIDs, function(questID)
    return QuestieDB:GetQuest(questID)
  end)
end

local function retrieveQuestStartPoints()
  local quests = findQuests()
  logToFile('quests:\n' .. tableToString(quests, 3))
  return Array.selectTrue(Array.map(quests, function (quest)
    local point = determineQuestStartPoint(quest)
    if point then
      local point3d = convertMapPositionToWorldPosition(point)
      point3d.type = 'acceptQuest'
      local questStarter = determineQuestStarter(quest)
      point3d.objectID = questStarter.id
      return point3d
    else
      return nil
    end
  end))
end

function retrieveObjectivePoints()
  local quests = retrieveQuestLogQuests()
  logToFile(tableToString(quests, 3))
  return Array.selectTrue(Array.flatMap(quests, function(quest)
    if quest.isComplete then
      local finisher = quest.Finisher
      local finisherID = finisher.Id
      local object
      if finisher.Type == 'object' then
        object = QuestieDB:GetObject(finisherID)
      else
        object = QuestieDB:GetNPC(finisherID)
      end
      local point = determineFirstObjectSpawn(object)
      local point3d = convertMapPositionToWorldPosition(point)
      return point3d
    else
      local objectives = quest.Objectives
      local openObjectives = Array.filter(objectives, function(objective)
        return not objective.Completed
      end)

      local points = {}

      Array.forEach(openObjectives, function(objective)
        Array.forEach(Object.values(objective.spawnList), function(spawnListEntries)
          local spawns = spawnListEntries.Spawns
          for zoneID, spawnPoints in pairs(spawns) do
            Array.forEach(spawnPoints, function(spawnPoint)
              local point = {
                zoneID = zoneID,
                x = spawnPoint[1],
                y = spawnPoint[2]
              }
              local point3d = convertMapPositionToWorldPosition(point)
              table.insert(points, point3d)
            end)
          end
        end)
      end)

      return points
    end
  end))
end

local function retrieveQuestObjectiveObjectIDs()
  local objectIDs = {}
  local quests = retrieveQuestLogQuests()

  Array.forEach(quests, function (quest)
    local objectives = quest.Objectives
    local openObjectives = Array.filter(objectives, function(objective)
      return not objective.Completed
    end)

    Array.forEach(openObjectives, function(objective)
      Array.forEach(Object.keys(objective.spawnList), function(objectID)
        table.insert(objectIDs, objectID)
      end)
    end)
  end)

  return objectIDs
end

local function retrieveObjectPoints()
  local objects = includeGUIDInObject(GMR.GetNearbyObjects(250))
  objects = Array.map(objects, function (object)
    object.type = 'object'
    object.objectID = object.ID
    return object
  end)
  local objectIDs = Set.create(retrieveQuestObjectiveObjectIDs())
  objects = Array.filter(objects, function (object)
    return objectIDs[object.objectID] and not GMR.IsDead(object.GUID)
  end)
  return objects
end

local function retrievePoints()
  return Array.concat(retrieveQuestStartPoints(), retrieveObjectivePoints(), retrieveObjectPoints())
end

local function determineClosestPoint(points)
  local playerPosition = GMR.GetPlayerPosition()
  logToFile(tableToString(points))
  return Array.min(points, function(point)
    if point then
      return GMR.GetDistanceBetweenPositions(
        playerPosition.x,
        playerPosition.y,
        playerPosition.z,
        point.x,
        point.y,
        point.z
      )
    else
      return 99999999999
    end
  end)
end

local function moveToPoint(point)
  if point.type == 'acceptQuest' then
    print('acceptQuest', point.x, point.y, point.z, point.objectID)
    GMR.Questing.InteractWith(point.x, point.y, point.z, point.objectID)
  elseif point.type == 'object' then
    print('object', point.x, point.y, point.z, point.objectID)
    if GMR.UnitCanAttack('player', point.GUID) then
      GMR.Questing.KillEnemy(point.x, point.y, point.z, point.objectID)
    else
      GMR.Questing.InteractWith(point.x, point.y, point.z, point.objectID)
    end
  else
    print('moveToPoint', point.x, point.y, point.z)
    GMR.Questing.MoveTo(point.x, point.y, point.z)
  end
end

visitedPoints = {}
local pointToVisit = nil

C_Timer.NewTicker(0, function ()
  if _G.GMR and GMR.IsFullyLoaded and GMR.IsFullyLoaded() then
    if pointToVisit then
      if GMR.IsPlayerPosition(pointToVisit.x, pointToVisit.y, pointToVisit.z, 3) then
        if not visitedPoints[pointToVisit.x] then
          visitedPoints[pointToVisit.x] = {}
        end
        if not visitedPoints[pointToVisit.x][pointToVisit.y] then
          visitedPoints[pointToVisit.x][pointToVisit.y] = {}
        end
        visitedPoints[pointToVisit.x][pointToVisit.y][pointToVisit.z] = true
        pointToVisit = nil
      end
    end
  end
end)

local function selectOnlyUnvisitedPoints(points)
  return Array.filter(points, function (point)
    return not visitedPoints[point.x] or not visitedPoints[point.x][point.y] or not visitedPoints[point.x][point.y][point.z]
  end)
end

function moveToClosestPoint()
  local points = selectOnlyUnvisitedPoints(retrievePoints())
  local closestPoint = determineClosestPoint(points)
  moveToPoint(closestPoint)
  pointToVisit = closestPoint
end

function efficientlyLevelToMaximumLevel()
  moveToClosestPoint()
end
