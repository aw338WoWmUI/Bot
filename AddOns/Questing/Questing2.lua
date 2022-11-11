local addOnName, AddOn = ...

local frame2 = CreateFrame('Frame')
frame2:SetWidth(1)
frame2:SetHeight(10)
local texture = frame2:CreateTexture(nil, 'OVERLAY')
texture:SetAllPoints()
texture:SetColorTexture(1, 0, 0, 1)

local frame3 = CreateFrame('Frame')
frame3:SetWidth(1)
frame3:SetHeight(10)
local texture2 = frame3:CreateTexture(nil, 'OVERLAY')
texture2:SetAllPoints()
texture2:SetColorTexture(1, 1, 0, 1)

local point = nil
local point2d = nil

-- Requires in-game language: English

-- /dump C_AreaPoiInfo.GetAreaPOIForMap(w)

unavailableQuestIDs = Set.create()

local objectIDsOfObjectsWhichCurrentlySeemAbsent = Set.create()

local questHandlers = {}

function defineQuest(questID, questHandler)
  questHandlers[questID] = questHandler
end

local lastLogMessage = nil

function isLastLogMessage(message)
  return lastLogMessage == message
end

local questGivers = {
  {
    objectID = 128229,
    continentID = 1643,
    x = -1683.21875,
    y = -1351.5798339844,
    z = 32.000263214111,
    questIDs = {
      49178,
      49226,
    }
  },
  {
    objectID = 128228,
    continentID = 1643,
    x = -1678.6076660156,
    y = -1351.6735839844,
    z = 31.664106369019,
    questIDs = {
      49230,
    }
  },
  {
    objectID = 130159,
    continentID = 1643,
    x = -1785.9184570312,
    y = -735.84027099609,
    z = 64.303344726562,
    questIDs = {
      49405,
    }
  }
}

questIDsInDatabase = Set.create(Array.flatMap(questGivers, function(questGiver)
  return questGiver.questIDs
end))

function retrievePlayerClassID()
  return select(3, UnitClass('player'))
end

function retrievePlayerRaceID()
  return select(3, UnitRace('player'))
end

function shouldQuestBeAvailable(quest)
  local playerLevel = UnitLevel('player')
  local faction = GMR.GetFaction('player')
  local playerClassID = retrievePlayerClassID()
  local playerRaceID = retrievePlayerRaceID()
  return (
    not GMR.IsQuestCompleted(quest.id) and
      not GMR.IsQuestActive(quest.id) and
      (not quest.requiresLevel or playerLevel >= quest.requiresLevel) and
      (not quest.classes or Array.any(quest.classes, function(class)
        return playerClassID == class
      end)) and
      (not quest.races or Array.any(quest.races, function(race)
        return playerRaceID == race
      end)) and
      (not quest.sides or Array.includes(quest.sides, faction)) and
      Array.all(quest.preQuestIDs, function(preQuestID)
        return GMR.IsQuestCompleted(preQuestID)
      end) and
      Array.all(quest.storylinePreQuestIDs, function(preQuestID)
        return GMR.IsQuestCompleted(preQuestID)
      end)
  )
end

function isValidMapCoordinate(coordinate)
  return coordinate >= 0 and coordinate <= 100
end

function retrieveNPCPosition(npc)
  local npcMapPosition = npc.coordinates[1]
  if (
    npcMapPosition and
      npcMapPosition[1] ~= nil and
      isValidMapCoordinate(npcMapPosition[2]) and
      isValidMapCoordinate(npcMapPosition[3])
  ) then
    local point = {
      zoneID = npcMapPosition[1],
      x = npcMapPosition[2],
      y = npcMapPosition[3]
    }
    local continentID = C_Map.GetWorldPosFromMapPos(npcMapPosition[1], point)
    local x, y, z = GMR.GetWorldPositionFromMap(
      npcMapPosition[1],
      npcMapPosition[2],
      npcMapPosition[3]
    )
    return continentID, x, y, z
  else
    return nil
  end
end

function retrieveQuestStartPoints()
  local quests2 = Questing.Database.retrieveQuestsThatShouldBeAvailable()

  local points1 = Array.selectTrue(Array.map(quests2, function(quest)
    if not unavailableQuestIDs[quest.id] then
      if quest.starterIDs and next(quest.starterIDs) then
        Array.forEach(quest.starterIDs, function(starterID)
          local npc = Questing.Database.retrieveNPC(starterID)
          if npc then
            local continentID, x, y, z = retrieveNPCPosition(npc)
            local npcPointer = GMR.FindObject(npc.id)
            if npcPointer then
              x, y, z = GMR.ObjectPosition(npcPointer)
            end
            if continentID and x and y and z then
              if GMR.GetDistanceToPosition(x, y, z) <= GMR.GetScanRadius() and not npcPointer then
                return nil
              else
                return {
                  objectID = npc.id,
                  continentID = continentID,
                  x = x,
                  y = y,
                  z = z,
                  type = 'acceptQuest',
                  questIDs = {
                    quest.id
                  },
                  questName = QuestUtils_GetQuestName(quest.id)
                }
              end
            else
              -- print('Missing NPC coordinates for NPC with ID "' .. npc.id .. '".')
            end
          else
            -- print('Missing NPC for ID "' .. starterID .. '" for quest "' .. quest.id .. '".')
          end
        end)
      else
        -- print('Missing quest starter IDs for quest "' .. quest.id .. '".')
      end
    end
  end))

  local points2 = Array.map(
    Array.filter(questGivers, function(questGiver)
      return Array.any(questGiver.questIDs, function(questID)
        return not GMR.IsQuestCompleted(questID) and not GMR.IsQuestActive(questID)
      end)
    end),
    function(questGiver)
      local point = Object.copy(questGiver)
      point.type = 'acceptQuest'
    end
  )

  local points = Array.concat(points1, points2)

  if Compatibility.isRetail() then
    local questIDs = Set.create(Array.flatMap(points, function(point)
      return point.questIDs
    end))

    print('questIDs')
    DevTools_Dump(questIDs)

    local continentID = select(8, GetInstanceInfo())
    local mapID = GMR.GetMapId()
    local questLines = retrieveAvailableQuestLines(mapID) -- FIXME: It seems that it might be required to request the quest line data from the server before this API returns it.
    while #questLines == 0 and C_Map.GetMapInfo(mapID).parentMapID ~= 0 do
      mapID = C_Map.GetMapInfo(mapID).parentMapID
      questLines = retrieveAvailableQuestLines(mapID)
    end

    local points3 = Array.selectTrue(Array.map(questLines, function(questLine)
      if (
        Set.contains(questIDs, questLine.questID) or
          GMR.IsQuestActive(questLine.questID) or
          questIDsInDatabase[questLine.questID]
      ) then
        return nil
      else
        local x, y, z = GMR.GetWorldPositionFromMap(mapID, questLine.x, questLine.y)
        return {
          objectID = nil,
          continentID = continentID,
          x = x,
          y = y,
          z = z,
          type = 'acceptQuest',
          questIDs = {
            questLine.questID
          },
          questName = questLine.questName
        }
      end
    end))

    Array.append(points, points3)
  end

  return points
end

function retrieveQuestsOnMap()
  local mapID = GMR.GetMapId()
  local quests = C_QuestLog.GetQuestsOnMap(mapID)
  while #quests == 0 and C_Map.GetMapInfo(mapID).parentMapID ~= 0 do
    mapID = C_Map.GetMapInfo(mapID).parentMapID
    quests = C_QuestLog.GetQuestsOnMap(mapID)
  end
  return quests, mapID
end

function retrieveWorldPositionFromMapPosition(mapID, mapX, mapY)
  local point = {
    zoneID = mapID,
    x = mapX / 100,
    y = mapY / 100
  }
  local continentID = C_Map.GetWorldPosFromMapPos(mapID, point)
  local x, y, z = GMR.GetWorldPositionFromMap(mapID, mapX, mapY)
  if not Movement.canPlayerStandOnPoint(createPoint(x, y, z)) or not GMR.IsOnMeshPoint(x, y, z) then
    local x2, y2, z2 = GMR.TraceLine(x, y, z, x, y, z + 1000, Movement.TraceLineHitFlags.COLLISION)
    if x2 then
      x, y, z = x2, y2, z2
      if GMR.IsOnMeshPoint(x, y, z) then
        local x3, y3, z3 = GMR.GetClosestPointOnMesh(continentID, x, y, z)
        if x3 and y3 and z3 then
          x, y, z = x3, y3, z3
        end
      end
    end
  end
  return continentID, createPoint(x, y, z)
end

function determineFirstOpenObjectiveIndex(questID)
  local objectives = GMR.Questing.GetQuestInfo(questID)
  local index = Array.findIndex(objectives, function(objective)
    return not objective.finished
  end)
  if index == -1 then
    return nil
  else
    return index
  end
end

function canQuestBeTurnedIn(questID)
  return GMR.IsQuestCompletable(questID)
end

function retrieveObjectivePoints()
  local quests, mapID = retrieveQuestsOnMap()
  return Array.selectTrue(
    Array.map(quests, function(quest)
      local questID = quest.questID

      local continentID, position = retrieveWorldPositionFromMapPosition(mapID, quest.x, quest.y)
      local x, y, z = position.x, position.y, position.z

      local firstOpenObjectiveIndex = determineFirstOpenObjectiveIndex(questID)
      local objectIDs
      if canQuestBeTurnedIn(questID) then
        local quest2 = Questing.Database.retrieveQuest(questID)
        objectIDs = quest2.enderIDs
      else
        objectIDs = retrieveQuestObjectiveInfo(questID, firstOpenObjectiveIndex)
      end
      local objectID
      if objectIDs then
        objectID = objectIDs[1]
        if objectID then
          local objectPointer = GMR.FindObject(objectID) -- FIXME: Object with objectID which is the closest to position
          if objectPointer then
            x, y, z = GMR.ObjectPosition(objectPointer)
          elseif objectIDsOfObjectsWhichCurrentlySeemAbsent[objectID] then
            return nil
          end
        end
      else
        objectID = nil
      end

      return {
        continentID = continentID,
        x = x,
        y = y,
        z = z,
        objectID = objectID,
        type = 'objective',
        questID = questID
      }
    end)
  )
end

--C_AreaPoiInfo.GetAreaPOIForMap(GMR.GetMapId())
--C_QuestLine.GetAvailableQuestLines(GMR.GetMapId())
--C_QuestLine.GetQuestLineInfo(48421, GMR.GetMapId())
--C_QuestLine.GetQuestLineQuests(586)
--C_QuestLine.GetQuestLineInfo(49178, GMR.GetMapId())

function retrieveAvailableQuestLines(mapID)
  C_QuestLine.RequestQuestLinesForMap(mapID)
  return C_QuestLine.GetAvailableQuestLines(mapID)
end

local isObjectRelatedToActiveQuestLookup = {}

function isObjectRelatedToAnyActiveQuest(object)
  local objectID = GMR.ObjectId(object)
  if isObjectRelatedToActiveQuestLookup[objectID] then
    return toBoolean(isObjectRelatedToActiveQuestLookup[objectID])
  else
    local relations
    if (
      GMR.ObjectPointer(object) == GMR.ObjectPointer('softinteract') and
        UnitName('softinteract') == GameTooltipTextLeft1:GetText()
    ) then
      relations = findRelationsToQuests('GameTooltip', 'softinteract')
      -- TODO: Merge new quest relationship information into explored object. Also consider the case when the explored object doesn't exist (regarding exploring other info for the object).
      if exploredObjects[GMR.ObjectId(object)] and not exploredObjects[GMR.ObjectId(object)].questRelationships then
        exploredObjects[GMR.ObjectId(object)].questRelationships = relations
      end
    elseif exploredObjects[GMR.ObjectId(object)] then
      relations = exploredObjects[GMR.ObjectId(object)].questRelationships
    end

    if relations then
      return Array.any(Object.entries(relations), function(entry)
        local questID = entry.key
        local objectiveIndexesThatObjectIsRelatedTo = entry.value
        return (
          GMR.IsQuestActive(questID) and
            not GMR.IsQuestCompletable(questID) and
            Set.containsWhichFulfillsCondition(objectiveIndexesThatObjectIsRelatedTo, function(objectiveIndex)
              return not GMR.Questing.IsObjectiveCompleted(questID, objectiveIndex)
            end)
        )
      end)
    end
  end

  return false
end

function updateIsObjectRelatedToActiveQuestLookup()
  local unitTokens = {
    'target',
    'softenemy',
    'softfriend',
    'softinteract'
  }
  for i = 1, 40 do
    local unitToken = 'nameplate' .. i
    table.insert(unitTokens, unitToken)
  end
  Array.forEach(unitTokens, function(unitToken)
    local objectID = GMR.ObjectId(unitToken)
    if objectID then
      if C_QuestLog.UnitIsRelatedToActiveQuest(unitToken) then
        isObjectRelatedToActiveQuestLookup[objectID] = true
      else
        isObjectRelatedToActiveQuestLookup[objectID] = nil
      end
    end
  end)
  if GMR.IsQuestActive(48505) then
    isObjectRelatedToActiveQuestLookup[126158] = true
    isObjectRelatedToActiveQuestLookup[126490] = true
  end
end

function convertObjectPointersToObjectPoints(objectPointers, type, adjustPoint)
  return Array.selectTrue(
    Array.map(objectPointers, function(pointer)
      return convertObjectPointerToObjectPoint(pointer, type, adjustPoint)
    end)
  )
end

function convertObjectPointerToObjectPoint(pointer, type, adjustPoint)
  local x, y, z = GMR.ObjectPosition(pointer)
  local point = {
    name = GMR.ObjectName(pointer),
    x = x,
    y = y,
    z = z,
    type = type,
    pointer = pointer,
    objectID = GMR.ObjectId(pointer)
  }
  if adjustPoint then
    point = adjustPoint(point)
  end
  return point
end

function convertObjectsToPointers(objects)
  return Array.map(objects, function(object)
    return object.GUID
  end)
end

function retrieveItemDescription(itemID)
  return Tooltips.retrieveItemTooltipText(itemID)
end

function isUnitAlive(objectPointer)
  return not GMR.UnitIsDead(objectPointer)
end

-- /script local x, y, z = GMR.ObjectPosition(GMR.FindObject(277427)); print(not not GMR.PathExists(x + 2, y + 2, z))
-- /script local playerPosition = GMR.GetPlayerPosition(); print(not not GMR.PathExists(playerPosition.x, playerPosition.y, playerPosition.z))
-- /dump GMR.PathExists(savedPosition.x, savedPosition.y, savedPosition.z)
-- /dump GMR.GetPath(savedPosition.x, savedPosition.y, savedPosition.z)
-- /dump GMR.PathExists(savedPosition)

function doesPassObjectFilter(object)
  return (
    (
      (isObjectRelatedToAnyActiveQuest(object.GUID) or seemsToBeQuestObject(object.GUID)) and isAlive(object.GUID)
    )
  )
end

function retrieveObjectPoints()
  local objects = includeGUIDInObject(GMR.GetNearbyObjects(250))
  local filteredObjects = Array.filter(objects, doesPassObjectFilter)
  local objectPointers = convertObjectsToPointers(filteredObjects)

  local objectPoints = convertObjectPointersToObjectPoints(objectPointers, 'object')

  local questIDs = retrieveQuestLogQuestIDs()
  for _, questID in ipairs(questIDs) do
    if GMR.IsQuestCompletable(questID) then
      local quest = Questing.Database.retrieveQuest(questID)
      if quest and quest.enderIDs then
        local objectPointer = GMR.FindObject(quest.enderIDs)
        if objectPointer then
          local point = convertObjectPointerToObjectPoint(objectPointer, 'endQuest')
          table.insert(objectPoints, point)
        end
      end
    else
      if questID == 26209 and not GMR.IsQuestCompletable(questID) then
        local objectIDs = Set.create({
          42383,
          42386,
          42391
        })
        local matchingObjects = Array.filter(objects, function(object)
          return Set.contains(objectIDs, object.ID) and GMR.IsAlive(object.GUID)
        end)
        Array.append(
          objectPoints,
          convertObjectPointersToObjectPoints(
            convertObjectsToPointers(matchingObjects),
            'gossipWith',
            function(point)
              point.optionToSelect = 38009
              return point
            end
          )
        )
      else
        local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
        if logIndex then
          local itemLink = GetQuestLogSpecialItemInfo(logIndex)
          if itemLink then
            local itemID = GetItemInfoInstant(itemLink)

            if questID == 26391 and not GMR.IsQuestCompletable(questID) then
              local matchingObjects = Array.filter(objects, function(object)
                return object.ID == 42940
              end)
              Array.append(
                objectPoints,
                convertObjectPointersToObjectPoints(
                  convertObjectsToPointers(matchingObjects),
                  'objectToUseItemAtPosition',
                  function(point)
                    point.itemID = itemID
                    point.questLogIndex = logIndex
                    return point
                  end
                )
              )
            else
              local startTime, _, enable = GetItemCooldown(itemID)
              if startTime == 0 and enable == 1 then
                local itemDescription = retrieveItemDescription(itemID)
                local name = string.match(itemDescription, 'of a ([%a %d]+)')
                if name then
                  local nameLower = string.lower(name)
                  local matchingObjects = Array.filter(objects, function(object)
                    return isUnitAlive(object.GUID) and string.lower(object.Name) == nameLower
                  end)
                  Array.append(
                    objectPoints,
                    convertObjectPointersToObjectPoints(
                      convertObjectsToPointers(matchingObjects),
                      'objectToUseItemOn',
                      function(point)
                        point.itemID = itemID
                        point.questLogIndex = logIndex
                        return point
                      end
                    )
                  )
                end
              end
            end
          end
        end
      end
    end
  end

  return objectPoints
end

function isAlive(objectPointer)
  return not GMR.IsDead(objectPointer)
end

local explorationObjectBlacklist = Set.create({
  89715, -- Franklin Martin
})

local explorationObjectNameBlacklist = Set.create({
  'Chair',
  'Bench',
  'Stool',
  'Fire',
  'Stove',
  'Kul Tiran Goods'
})

function findClosestQuestGiver(point)
  local objects = includeGUIDInObject(GMR.GetNearbyObjects(250))
  local object = Array.min(Array.filter(objects, function(object)
    return Questing.Database.isQuestGiver(object.ID)
  end), function(object)
    return GMR.GetDistanceBetweenPositions(point.x, point.y, point.z, object.x, object.y,
      object.z)
  end)
  if object and GMR.GetDistanceBetweenPositions(point.x, point.y, point.z, object.x, object.y,
    object.z) <= 5 then
    return object
  end

  return nil
end

function retrieveQuestObjectivesInfo(questID)
  local questInfo = Questing.Database.retrieveQuest(questID)
  local objectives = questInfo.objectives
  return objectives
end

function retrieveQuestObjectiveInfo(questID, objectiveIndex)
  local objectives = retrieveQuestObjectivesInfo(questID)
  return objectives[objectiveIndex]
end

function retrieveExplorationPoints()
  local objects = includeGUIDInObject(GMR.GetNearbyObjects(250))
  objects = Array.filter(objects, function(object)
    return (
      Questing.Database.isQuestGiver(object.ID) and
        isAlive(object.GUID) and
        -- (isInteractable(object.GUID) or GMR.ObjectHasGossip(object.GUID) or isFriendly(object.GUID)) and
        not Set.contains(explorationObjectBlacklist, object.ID) and
        not Set.contains(explorationObjectNameBlacklist, GMR.ObjectName(object.GUID))
    )
  end)
  local objectPointers = Array.map(objects, function(object)
    return object.GUID
  end)

  local points = convertObjectPointersToObjectPoints(objectPointers, 'exploration')

  local quests, mapID = retrieveQuestsOnMap()
  Array.forEach(quests, function(quest)
    local questID = quest.questID
    local objectives = retrieveQuestObjectivesInfo(questID)
    if objectives then
      for index, objective in ipairs(objectives) do
        if not GMR.Questing.IsObjectiveCompleted(questID, index) then
          local objectIDs = objective
          Array.forEach(objectIDs, function(objectID)
            local object = Questing.Database.retrieveNPC(objectID)
            if object then
              local coordinates = object.coordinates
              if coordinates then
                Array.forEach(coordinates, function(coordinates)
                  local continentID, position = retrieveWorldPositionFromMapPosition(
                    coordinates[1],
                    coordinates[2],
                    coordinates[3]
                  )
                  local point = {
                    continentID = continentID,
                    x = position.x,
                    y = position.y,
                    z = position.z,
                    type = 'exploration',
                    objectID = objectID
                  }
                  table.insert(points, point)
                end)
              end
            end
          end)
        end
      end
    end
  end)

  return points
end

local function retrievePoints()
  local yielder = createYielderWithTimeTracking(1 / 60)
  local questStartPoints = retrieveQuestStartPoints()
  if yielder.hasRanOutOfTime() then
    yielder.yield()
  end
  local objectivePoints = retrieveObjectivePoints()
  if yielder.hasRanOutOfTime() then
    yielder.yield()
  end
  local objectPoints = retrieveObjectPoints()
  if yielder.hasRanOutOfTime() then
    yielder.yield()
  end
  -- local explorationPoints = {} -- retrieveExplorationPoints()
  --if yielder.hasRanOutOfTime() then
  --  yielder.yield()
  --end
  return {
    questStartPoints = questStartPoints,
    objectivePoints = objectivePoints,
    objectPoints = objectPoints,
    explorationPoints = {} -- explorationPoints
  }
end

function calculatePathLength(path)
  local previousPoint = path[1]
  return Array.reduce(Array.slice(path, 2), function(length, point)
    length = length + GMR.GetDistanceBetweenPositions(
      previousPoint[1],
      previousPoint[2],
      previousPoint[3],
      point[1],
      point[2],
      point[3]
    )
    previousPoint = point
    return length
  end, 0)
end

function determineMeshDistance(point)
  local path = GMR.GetPath(point.x, point.y, point.z)
  if path then
    return calculatePathLength(path)
  else
    return nil
  end
end

local function determineClosestPoint(points)
  local playerPosition = GMR.GetPlayerPosition()
  return Array.min(points, function(point)
    if point then
      local distance = GMR.GetDistanceBetweenPositions(
        playerPosition.x,
        playerPosition.y,
        playerPosition.z,
        point.x,
        point.y,
        point.z
      )

      return distance
    else
      return 99999999999
    end
  end)
end

local function determinePointToGo(points)
  local closeQuestStartPoints = Array.filter(points.questStartPoints, function(point)
    return GMR.GetDistanceToPosition(point.x, point.y, point.z) <= 50
  end)
  if next(closeQuestStartPoints) then
    return determineClosestPoint(closeQuestStartPoints)
  elseif next(points.objectPoints) then
    return determineClosestPoint(points.objectPoints)
  else
    if next(points.explorationPoints) then
      return determineClosestPoint(points.explorationPoints)
    else
      local points2 = Array.concat(points.questStartPoints, points.objectivePoints)
      if next(points2) then
        return determineClosestPoint(points2)
      else
        return nil
      end
    end
  end
end

function isSpecialItemUsable(point)
  return IsQuestLogSpecialItemInRange(point.questLogIndex) == 1 and GMR.IsPositionInLoS(point.x, point.y, point.z)
end

function waitForSpecialItemUsable(point)
  return waitFor(function()
    GMR.TargetObject(point.pointer)
    return isSpecialItemUsable(point)
  end, 10)
end

local pathMover = nil

local function stopPathMover()
  if pathMover then
    pathMover.stop()
    pathMover = nil
  end
end

local function isPlayerOnMeshPoint()
  local playerPosition = GMR.GetPlayerPosition()
  return GMR.IsOnMeshPoint(playerPosition.x, playerPosition.y, playerPosition.z)
end

local function moveToPoint2(point)
  Questing.Coroutine.moveTo(point)
end

function retrieveNavigationPosition()
  local yielder = createYielderWithTimeTracking(1 / 60)

  local lastDistance = nil
  local lastPosition = nil

  local pitch = GMR.GetPitch('player')
  local yaw = GMR.ObjectRawFacing('player')

  while true do
    local playerPosition = Movement.retrievePlayerPosition()
    local navigationPointDistance = C_Navigation.GetDistance()
    local navigationX, navigationY = C_Navigation.GetFrame():GetCenter()
    local scale = UIParent:GetEffectiveScale()
    navigationX = navigationX * scale
    navigationY = navigationY * scale

    frame3:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', navigationX, navigationY)

    local vector = Vector:new(
      navigationPointDistance * math.cos(yaw) * math.cos(pitch),
      navigationPointDistance * math.sin(yaw) * math.cos(pitch),
      navigationPointDistance * math.sin(pitch)
    )
    local position = createPoint(
      playerPosition.x + vector.x,
      playerPosition.y + vector.y,
      playerPosition.z + vector.z
    )
    point = position

    local x, y = GMR.WorldToScreen(position.x, position.y, position.z)
    point2d = { x = x, y = y }
    frame2:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', x, y)

    local deltaX = navigationX - x
    local deltaY = navigationY - y

    local distance = euclideanDistance2D(
      { x = navigationX, y = navigationY },
      { x = x, y = y }
    )

    if lastDistance and lastDistance <= distance then
      point = lastPosition
      return lastPosition
    end

    local oneDegree = 2 * PI / 360
    if deltaX < 0 then
      yaw = yaw + oneDegree
    elseif deltaX > 0 then
      yaw = yaw - oneDegree
    end

    if deltaY < 0 then
      pitch = pitch - oneDegree
    elseif deltaY > 0 then
      pitch = pitch + oneDegree
    end

    if yielder.hasRanOutOfTime() then
      yielder.yield()
    end

    lastDistance = distance
    lastPosition = position
  end
end

function waitForPlayerHasArrivedAt(position)
  Movement.waitForPlayerToBeOnPosition(position, INTERACT_DISTANCE)
end

local function doSomethingWithObject(point)
  local objectID = point.objectID
  local pointer = point.pointer
  if not pointer and objectID then
    pointer = GMR.FindObject(objectID) -- FIXME: Object closest to point position which matches objectID
  end

  if not pointer and objectID and GMR.GetDistanceToPosition(point.x, point.y, point.z) <= GMR.GetScanRadius() then
    objectIDsOfObjectsWhichCurrentlySeemAbsent[point.objectID] = true
  else
    if pointer and GMR.UnitCanAttack('player', pointer) then
      Questing.Coroutine.doMob(point.x, point.y, point.z, point.objectID)
    elseif pointer and (GMR.ObjectHasGossip(pointer) or next(C_GossipInfo.GetOptions())) then
      gossipWithAt(point.x, point.y, point.z, point.objectID)
      waitForPlayerHasArrivedAt(point) -- FIXME
    elseif objectID then
      Questing.Coroutine.interactWithAt(point.x, point.y, point.z, objectID)
    else
      moveToPoint2(point)
    end
  end
end

local function moveToPoint(point)
  print('point')
  DevTools_Dump(point)
  -- print(tableToString(point, 1))
  if point.type == 'acceptQuest' then
    print('acceptQuest', point.x, point.y, point.z, point.objectID, point.questName)
    local questGiverPoint
    if point.objectID then
      questGiverPoint = point
    else
      local object = findClosestQuestGiver(point)
      print('object')
      DevTools_Dump(object)
      if object then
        questGiverPoint = {
          objectID = object.ID,
          x = object.x,
          y = object.y,
          z = object.z
        }
      end
    end
    if questGiverPoint then
      GMR.Questing.InteractWith(questGiverPoint.x, questGiverPoint.y, questGiverPoint.z, questGiverPoint.objectID)
      waitForPlayerHasArrivedAt(questGiverPoint)
    else
      moveToPoint2(point)
    end
  elseif point.type == 'object' then
    doSomethingWithObject(point)
  elseif point.type == 'endQuest' then
    print('end quest')
    Questing.Coroutine.interactWithAt(point.x, point.y, point.z, point.objectID)
  elseif point.type == 'exploration' then
    local name = GMR.ObjectName(point.pointer)
    print('explore object', name)
    exploreObject(point.pointer)
    waitForPlayerHasArrivedAt(point)
  elseif point.type == 'objectToUseItemOn' then
    print('quest log special item')
    GMR.TargetObject(point.pointer)
    if isSpecialItemUsable(point) then
      print('use')
      local distance = GMR.GetDistanceBetweenObjects('player', point.pointer)
      GMR.Questing.UseItemOnNpc(point.x, point.y, point.z, point.objectID, point.itemID, distance)
      waitForPlayerHasArrivedAt(point)
    else
      print('move to')
      GMR.Questing.UseItemOnNpc(point.x, point.y, point.z, point.objectID, point.itemID)
      waitForSpecialItemUsable(point)
      print('use after wait')
      local name = GetItemInfo(point.itemID)
      GMR.CastSpellByName(name)
    end
  elseif point.type == 'objectToUseItemAtPosition' then
    print('quest log special item at position')
    GMR.Questing.UseItemOnGround(point.x, point.y, point.z, point.itemID, 3)
    waitForPlayerHasArrivedAt(point)
  elseif point.type == 'gossipWith' then
    print('gossip with')
    gossipWithAt(point.x, point.y, point.z, point.objectID, point.optionToSelect)
    waitForPlayerHasArrivedAt(point)
  elseif point.type == 'objective' then
    local questHandler = questHandlers[point.questID]
    if questHandler then
      questHandler()
    else
      doSomethingWithObject(point)
    end
  else
    print('moveToPoint', point.x, point.y, point.z)
    moveToPoint2(point)
  end
end

local pointToMove = nil

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and GMR.LibDraw and GMR.LibDraw.clearCanvas then
    ticker:Cancel()
    hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
      if pointToMove then
        GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
        GMR.LibDraw.Circle(pointToMove.x, pointToMove.y, pointToMove.z, 3)
      end

      if point then
        GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
        local playerPosition = Movement.retrievePlayerPosition()
        GMR.LibDraw.Line(playerPosition.x, playerPosition.y, playerPosition.z, point.x, point.y, point.z)
        GMR.LibDraw.Circle(point.x, point.y, point.z, 0.75)
      end
    end)
  end
end)

local previousPointsToGo = { nil, nil }

function seemToBeSamePoints(a, b)
  if a.pointer and b.pointer then
    return a.pointer == b.pointer
  else
    return a.x == b.x and a.y == b.y and a.z == b.z
  end
end

function moveToClosestPoint()
  local points = retrievePoints()
  if previousPointsToGo[2] then
    -- A B A
    for key, value in pairs(points) do
      points[key] = Array.filter(value, function(point)
        return not seemToBeSamePoints(point, previousPointsToGo[2])
      end)
    end
  end
  local pointToGo = determinePointToGo(points)
  print('pointToGo')
  DevTools_Dump(pointToGo)
  if pointToGo then
    if previousPointsToGo[1] == nil or not seemToBeSamePoints(pointToGo, previousPointsToGo[1]) then
      previousPointsToGo[2] = previousPointsToGo[1]
      previousPointsToGo[1] = pointToGo
    end

    pointToMove = pointToGo
    moveToPoint(pointToGo)
  else
    if not isPlayerOnMeshPoint() then
      local continentID = select(8, GetInstanceInfo())
      local playerPosition = Movement.retrievePlayerPosition()
      local x, y, z = GMR.GetClosestPointOnMesh(continentID, playerPosition.x, playerPosition.y, playerPosition.z)
      local to = createPoint(x, y, z)
      local pathFinder = Movement.createPathFinder()
      local path = pathFinder.start(playerPosition, to)
      if path then
        pointToMove = path[#path]
        print('m1')
        Movement.movePath(path)
        print('m2')
      end
    end
  end
end

function canInteractWithQuestGiver()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      local texture = icon:GetTexture()
      if texture == 'Cursor Quest' then
        return true
      end
    end
  end

  return false
end

local lastQuestGiverObjectPointerInteractedWith = nil

function interactWithQuestGiver()
  local unitToken = 'softinteract'
  GMR.Interact(unitToken)
  exploredObjects[GMR.ObjectId(unitToken)] = {}
  lastQuestGiverObjectPointerInteractedWith = GMR.ObjectPointer(unitToken)
end

function canInteractWithObject()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      local texture = icon:GetTexture()
      if texture == 4675650 then
        return true
      end
    end
  end

  return false
end

function interactWithObject()
  local unitToken = 'softinteract'
  GMR.Interact(unitToken)
end

function canGossipWithObject()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      local texture = icon:GetTexture()
      if texture == 'Cursor Speak' then
        return true
      end
    end
  end

  return false
end

local lastGossipedWithObjectPointer = nil

function gossipWithObject()
  local unitToken = 'softinteract'
  GMR.Interact(unitToken)
  lastGossipedWithObjectPointer = GMR.ObjectPointer(unitToken)
end

function canTurnInQuest()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      local texture = icon:GetTexture()
      if texture == 'Cursor QuestTurnIn' then
        return true
      end
    end
  end

  return false
end

function turnInQuest()
  local unitToken = 'softinteract'
  GMR.Interact(unitToken)
end

function canExploreSoftInteractObject()
  local objectID = GMR.ObjectId('softinteract')
  if objectID then
    return not exploredObjects[objectID]
  else
    return false
  end
end

function waitForGossipDialog()
  Events.waitForEvent('GOSSIP_SHOW', 2)
end

function waitForPlayerFacingObject(object)
  return waitFor(function()
    return GMR.ObjectIsFacing('player', object)
  end, 5)
end

function waitForSoftInteract()
  return waitFor(function()
    return GMR.ObjectPointer('softinteract')
  end, 2)
end

function waitForSoftInteractNamePlate()
  return waitFor(function()
    return C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  end, 2)
end

function isFriendly(object)
  local reaction = GMR.UnitReaction(object, 'player')
  return reaction and reaction >= 4 and not GMR.UnitCanAttack('player', object)
end

function isEnemy(object)
  local reaction = GMR.UnitReaction(object, 'player')
  return reaction and reaction <= 3
end

function exploreObject(object)
  local maxDistance
  if isFriendly(object) then
    maxDistance = math.min(
      tonumber(GetCVar('SoftTargetFriendRange'), 10),
      45
    )
  else
    maxDistance = math.min(
      tonumber(GetCVar('SoftTargetInteractRange'), 10),
      15.5
    )
  end
  local pointer = GMR.ObjectPointer(object)
  local x, y, z = GMR.ObjectPosition(pointer)
  local distanceToObject = GMR.GetDistanceBetweenObjects('player', object)
  if distanceToObject and distanceToObject <= maxDistance then
    GMR.ClearTarget()
    print('D1')
    Movement.faceDirection(createPoint(x, y, z))
    print('D2')
    if pointer ~= GMR.ObjectPointer('softinteract') then
      GMR.TargetObject(pointer)
    end
    local skipSaving = false
    local wasFacingSuccessful = waitForPlayerFacingObject(pointer)
    if wasFacingSuccessful then
      waitForSoftInteract()
      local softInteractPointer = GMR.ObjectPointer('softinteract')
      local objectID = GMR.ObjectId(pointer)
      local softInteractObjectID = GMR.ObjectId(softInteractPointer)
      if softInteractPointer and objectID == softInteractObjectID then
        local softInteractX, softInteractY, softInteractZ = GMR.ObjectPosition(softInteractPointer)
        local exploredObject = {
          positions = {
            {
              x = softInteractX,
              y = softInteractY,
              z = softInteractZ
            }
          }
        }

        print(3)
        waitForSoftInteractNamePlate()
        print(4)
        local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
        if namePlate then
          local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
          if icon:IsShown() then
            local texture = icon:GetTexture()
            if texture == 'Cursor UnableInnkeeper' then
              moveToPoint2({ x = x, y = y, z = z })
              skipSaving = true
            elseif texture == 'Cursor Quest' or texture == 'Cursor UnableQuest' then
              exploredObject.isQuestGiver = true
              moveToPoint2({ x = x, y = y, z = z })
              skipSaving = true
            elseif texture == 4675702 or -- Inactive hand
              texture == 4675650 then
              -- Active hand
              exploredObject.isInteractable = true
            elseif texture == 'Cursor Innkeeper' then
              exploredObject.isInnkeeper = true
              local objectID = GMR.ObjectId(pointer)
              GMR.Interact(softInteractPointer)
              print(5)
              waitForGossipDialog()
              print(6)
              local options = C_GossipInfo.GetOptions()
              local canVendor = Array.any(options, function(option)
                return option.icon == 132060
              end)
              if canVendor then
                exploredObject.isGoodsVendor = true
                GMR.DefineGoodsVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
                exploredObject.isSellVendor = true
                GMR.DefineSellVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
              end
            elseif texture == 'Cursor RepairNPC' or texture == 'Cursor UnableRepairNPC' then
              exploredObject.isSellVendor = true
              GMR.DefineSellVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
              exploredObject.isRepairVendor = true
              GMR.DefineRepairVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
            elseif texture == 'Cursor Mail' or texture == 'Cursor UnableMail' then
              exploredObject.isMailbox = true
              GMR.DefineProfileMailbox(softInteractX, softInteractY, softInteractZ)
            elseif texture == 'Cursor Pickup' or texture == 'Cursor UnablePickup' then
              exploredObject.isSellVendor = true
              GMR.DefineSellVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
            elseif texture == 'Cursor Taxi' or texture == 'Cursor UnableTaxi' then
              exploredObject.isTaxi = true
              if texture == 'Cursor Taxi' then
                GMR.Interact(softInteractPointer)
              end
            elseif texture == 'Cursor QuestTurnIn' or texture == 'Cursor UnableQuestTurnIn' then
              if texture == 'Cursor QuestTurnIn' then
                GMR.Interact(softInteractPointer)
              elseif texture == 'Cursor UnableQuestTurnIn' then
                local x, y, z = GMR.ObjectPosition(softInteractPointer)
                local objectID = GMR.ObjectId(softInteractPointer)
                GMR.Questing.InteractWith(x, y, z, objectID)
              end
              skipSaving = true
            end

            if UnitName(softInteractPointer) == GameTooltipTextLeft1:GetText() then
              exploredObject.questRelationships = findRelationsToQuests('GameTooltip', 'softinteract')
            else
              skipSaving = true
            end

            if texture == 'Cursor UnableTaxi' then
              Questing.Coroutine.interactWithAt(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
            end
          end
        end

        if not skipSaving then
          exploredObjects[softInteractObjectID] = exploredObject
        end
      elseif (not softInteractPointer and distanceToObject <= maxDistance) or distanceToObject <= 5 then
        print('storing explored object just with position.')
        local exploredObject = {
          positions = {
            {
              x = x,
              y = y,
              z = z
            }
          }
        }
        exploredObjects[objectID] = exploredObject
      else
        moveToPoint2({ x = x, y = y, z = z })
      end
    end
  else
    moveToPoint2({ x = x, y = y, z = z })
  end

  print('-- explore object')
end

function exploreSoftInteractObject()
  exploreObject('softinteract')
end

local isRunning = false

function isIdle()
  local questID = GMR.GetQuestId()
  return (
    not GMR.InCombat() and
      not (questID and GMR.IsQuestActive(questID) and not GMR.IsQuestCompletable(questID)) and
      not GMR.IsQuesting() and
      not GMR.IsCasting() and
      not GMR.IsSelling() and
      not GMR.IsAttacking() and
      (not GMR.IsClassTrainerNeeded or not GMR.IsClassTrainerNeeded()) and
      not GMR.IsDead() and
      not GMR.IsDrinking() and
      not GMR.IsEating() and
      not GMR.IsFishing() and
      not GMR.IsLooting() and
      not GMR.IsMailing() and
      not seemsThatIsGoingToCreateHealthstone() and
      not GMR.IsUnstuckEnabled() and
      not GMR.IsPreparing() and
      not GMR.IsGhost('player') and
      not GMR.IsRepairing() and
      not isPathFinding()
  )
end

function seemsThatIsGoingToRepair()
  return GMR_SavedVariablesPerCharacter.Repair and GMR.GetRepairStatus() <= GMR.GetRepairValue()
end

function determineNumberOfFreeInventorySlots()
  local numberOfFreeSlots = 0
  for containerIndex = 0, NUM_BAG_SLOTS do
    numberOfFreeSlots = numberOfFreeSlots + GetContainerNumFreeSlots(containerIndex)
  end
  return numberOfFreeSlots
end

function hasEnoughFreeSlotsToCompleteQuest()
  local numberOfItemsAddedToBag = GetNumQuestRewards()
  if GetNumQuestChoices() >= 1 then
    numberOfItemsAddedToBag = numberOfItemsAddedToBag + 1
  end
  local numberOfFreeInventorySlots = determineNumberOfFreeInventorySlots()
  return numberOfItemsAddedToBag <= numberOfFreeInventorySlots
end

function run (once)
  hooksecurefunc(GMR, 'Log', function(message)
    lastLogMessage = message
  end)

  local yielder = createYielder()

  while true do
    log('1')
    if GMR.IsExecuting() and GMR.InCombat() and not GMR.IsAttacking() then
      local pointer = GMR.GetAttackingEnemy()
      if pointer then
        local x, y, z = GMR.ObjectPosition(pointer)
        local objectID = GMR.ObjectId(pointer)
        Questing.Coroutine.doMob(x, y, z, objectID)
      end
    end
    if GMR.IsExecuting() and isIdle() then
      pointToMove = nil

      local quests = retrieveQuestLogQuests()
      local quest = Array.find(quests, function(quest)
        return quest.isAutoComplete and GMR.IsQuestCompletable(quest.questID)
      end)
      if quest then
        ShowQuestComplete(quest.questID)
      end

      if Compatibility.isRetail() then
        for index = 1, GetNumAutoQuestPopUps() do
          local questID, popUpType = GetAutoQuestPopUp(index)

          if popUpType == 'OFFER' then
            ShowQuestOffer(questID)
            print(1)
            local wasSuccessful = waitFor(function()
              return QuestFrame:IsShown()
            end, 1)
            print(2)
            if wasSuccessful then
              print(3)
              AcceptQuest()
            end
            print(4)
          end
        end
      end

      local npcID = GMR.ObjectId('npc')
      if npcID then
        local questsThatShouldBeAvailableFromNPC = Questing.Database.retrieveQuestsThatShouldBeAvailableFromNPC(npcID)
        local availableQuests = C_GossipInfo.GetAvailableQuests()
        local availableQuestIDs = Set.create(Array.map(availableQuests, function(quest)
          return quest.questID
        end))
        Array.forEach(questsThatShouldBeAvailableFromNPC, function(quest)
          if not availableQuestIDs[quest.id] then
            unavailableQuestIDs[quest.id] = true
          end
        end)
      end

      if QuestFrameProgressPanel:IsShown() and IsQuestCompletable() then
        CompleteQuest()
      elseif QuestFrameRewardPanel:IsShown() and hasEnoughFreeSlotsToCompleteQuest() then
        GetQuestReward(1)
      elseif QuestFrameDetailPanel:IsShown() then
        print('AcceptQuest')
        AcceptQuest()
      elseif GossipFrame:IsShown() and C_GossipInfo.GetNumActiveQuests() >= 1 then
        local activeQuests = C_GossipInfo.GetActiveQuests()
        local activeQuest = activeQuests[1]
        C_GossipInfo.SelectActiveQuest(activeQuest.questID)
      elseif QuestFrame:IsShown() and GetNumActiveQuests() >= 1 then
        for index = 1, GetNumActiveQuests() do
          local questID = GetActiveQuestID(index)
          if GMR.IsQuestCompletable(questID) then
            SelectActiveQuest(index)
            break
          end
        end
      elseif GossipFrame:IsShown() and C_GossipInfo.GetNumAvailableQuests() >= 1 then
        local availableQuests = C_GossipInfo.GetAvailableQuests()
        local availableQuest = availableQuests[1]
        C_GossipInfo.SelectAvailableQuest(availableQuest.questID)
      elseif QuestFrame:IsShown() and GetNumAvailableQuests() >= 1 then
        SelectAvailableQuest(1)
        --elseif GossipFrame:IsShown() and #C_GossipInfo.GetOptions() >= 1 then
        --  local options = C_GossipInfo.GetOptions()
        --  local option = options[1]
        --  C_GossipInfo.SelectOption(option.gossipOptionID)
      elseif canInteractWithQuestGiver() and lastQuestGiverObjectPointerInteractedWith ~= GMR.ObjectPointer('softinteract') then
        interactWithQuestGiver()
        --elseif canInteractWithObject() then
        --  interactWithObject()
        --elseif canGossipWithObject() and lastGossipedWithObjectPointer ~= GMR.ObjectPointer('softinteract') then
        --  gossipWithObject()
      elseif canTurnInQuest() then
        turnInQuest()
        --elseif canExploreSoftInteractObject() then
        --  exploreSoftInteractObject()
      else
        local questIDs = retrieveQuestLogQuestIDs()
        Array.forEach(questIDs, function(questID)
          if C_QuestLog.IsFailed(questID) then
            GMR.AbandonQuest(questID)
          end
        end)

        updateIsObjectRelatedToActiveQuestLookup()
        moveToClosestPoint()
      end
    end

    if once then
      return
    end

    yielder.yield()
  end
end

function efficientlyLevelToMaximumLevel()
  if not isRunning then
    isRunning = true

    local thread = coroutine.create(function()
      for objectID, object in pairs(exploredObjects) do
        if object.isGoodsVendor then
          GMR.DefineGoodsVendor(object.x, object.y, object.z, objectID)
        end
        if object.isSellVendor then
          GMR.DefineSellVendor(object.x, object.y, object.z, objectID)
        end
        if object.isRepairVendor then
          GMR.DefineRepairVendor(object.x, object.y, object.z, objectID)
        end
        if object.isMailbox then
          GMR.DefineProfileMailbox(object.x, object.y, object.z)
        end
      end

      run()
    end)
    resumeWithShowingError(thread)
  end
end

-- Cursor Quest
-- Cursor UnableQuest
-- 5, friendly
function aaaaaaa()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      logToFile('icon: ' .. icon:GetTexture())
    end
  end
end

--GMR.ObjectDynamicFlags('target')
--GMR.ObjectRawType('target')

-- C_QuestItemUse.CanUseQuestItemOnObject(ItemLocation:CreateFromBagAndSlot(0, 1), 'target', false)
-- C_QuestItemUse.CanUseQuestItemOnObject(ItemLocation:CreateFromBagAndSlot(0, 1), 'target', true)
-- C_Item.GetItemName(ItemLocation:CreateFromBagAndSlot(0, 1))

local function initializeSavedVariables()
  if exploredObjects == nil then
    -- objectID to flags
    exploredObjects = {}
  end
end

local function onAddonLoaded(name)
  if name == 'Questing' then
    initializeSavedVariables()
  end
end

local function onQuestlineUpdate(requestRequired)
  if requestRequired then
    C_QuestLine.RequestQuestLinesForMap(GMR.GetMapId())
  end
end

local function onQuestTurnedIn()
  objectIDsOfObjectsWhichCurrentlySeemAbsent = Set.create()
end

local function onEvent(self, event, ...)
  if event == 'ADDON_LOADED' then
    onAddonLoaded(...)
  elseif event == 'QUESTLINE_UPDATE' then
    onQuestlineUpdate(...)
  elseif event == 'QUEST_TURNED_IN' then
    onQuestTurnedIn(...)
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('ADDON_LOADED')
if Compatibility.isRetail() then
  frame:RegisterEvent('QUESTLINE_UPDATE')
end
frame:RegisterEvent('QUEST_TURNED_IN')
frame:SetScript('OnEvent', onEvent)
