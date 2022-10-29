-- QuestieDB:GetQuestsByZoneId(zoneId)
-- /dump MapUtil.GetDisplayableMapForPlayer()
-- /dump QuestieDB:GetQuestsByZoneId(MapUtil.GetDisplayableMapForPlayer())
-- /dump WorldMapFrame:GetMapID()
-- /dump C_Map.GetMapInfo(MapUtil.GetDisplayableMapForPlayer())

-- /dump QuestieDB:GetQuestsByZoneId(QuestiePlayer:GetCurrentZoneId())

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule('QuestieDB')
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule('QuestieLib')
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule('QuestieCorrections')
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule('QuestieEvent')
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule('QuestiePlayer')

local function filterQuests(quests)
  local level = UnitLevel('player')
  return Array.filter(quests, function(quest)
    return quest.requiredLevel <= level
  end)
end

function findQuests()
  local result = {}

  local zoneId = 12
  local quests = QuestieJourney.zoneMap[zoneId]--QuestieDB:GetQuestsByZoneId(zoneId)

  if (not quests) then
    return nil
  end

  local sortedQuestByLevel = QuestieLib:SortQuestIDsByLevel(quests)

  for _, levelAndQuest in pairs(sortedQuestByLevel) do
    ---@type number
    local questID = levelAndQuest[2]
    -- Only show quests which are not hidden
    if QuestieCorrections.hiddenQuests and ((not QuestieCorrections.hiddenQuests[questID]) or QuestieEvent:IsEventQuest(questID)) and QuestieDB.QuestPointers[questID] then
      -- Completed quests
      if Questie.db.char.complete[questID] then
      else
        local queryResult = QuestieDB.QueryQuest(
          questID,
          "exclusiveTo",
          "nextQuestInChain",
          "parentQuest",
          "preQuestSingle",
          "preQuestGroup",
          "requiredMinRep",
          "requiredMaxRep"
        ) or {}
        local exclusiveTo = queryResult[1]
        local nextQuestInChain = queryResult[2]
        local parentQuest = queryResult[3]
        local preQuestSingle = queryResult[4]
        local preQuestGroup = queryResult[5]
        local requiredMinRep = queryResult[6]
        local requiredMaxRep = queryResult[7]

        -- Exclusive quests will never be available since another quests permanently blocks them.
        -- Marking them as complete should be the most satisfying solution for user
        if (nextQuestInChain and Questie.db.char.complete[nextQuestInChain]) or (exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)) then
          -- The parent quest has been completed
        elseif parentQuest and Questie.db.char.complete[parentQuest] then
          -- Unoptainable reputation quests
        elseif not QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep) then
          -- A single pre Quest is missing
        elseif not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle) then
          -- Multiple pre Quests are missing
        elseif not QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup) then
          -- Repeatable quests
        elseif QuestieDB.IsRepeatable(questID) then
          -- Available quests
        else
          tinsert(result, questID)
        end
      end
      temp = {}
    end
  end

  return filterQuests(Array.map(result, function(questID)
    return QuestieDB:GetQuest(questID)
  end))
end

--function selectCloseQuests(quests)
--  local playerPosition = GMR.GetPlayerPosition()
--  local MAXIMUM_DISTANCE = 100
--  return Array.filter(quests, function (quest)
--    local questGiverID = quest.
--    local questGiver = QuestieDB:GetNPC(questGiverID)
--    return distance(playerPosition, questGiver) <= MAXIMUM_DISTANCE
--  end)
--end
--
--local quests = selectCloseQuests(findQuests())

function findQuest()
  local quests = findQuests()
  local quest = Array.find(quests, function(quest)
    return quest.Id == 87
  end)
  logToFile(tableToString(quest, 3))
  return quest
end

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

local function determineQuestStarter(quest)
  local startNPCID = quest.Starts.NPC[1]
  local npc = QuestieDB:GetNPC(startNPCID)
  return npc
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

local function determineFirstObjectSpawn(object)
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

local function determineQuestStartPoint(quest)
  local npc = determineQuestStarter(quest)
  return determineFirstObjectSpawn(npc)
end

function a()
  -- Gather all quest points (quest pick up points, quest objective points, quest turn in points)
  local quests = findQuests()
  local questPoints = Array.flatMap(quests, function(quest)
    -- TODO: Quest pick up point
    -- TODO: Quest turn in point
    -- TODO: Point dependencies (what is required to be done before others)
    --       Quest pick up before other quest points
    --       Quest turn in after quest pick up and all quest objective points have been done.
    --       Quest objective points after quest pick up.
    return Array.concat(
      {
        determineQuestStartPoint(quest)
      },
      quest.Objectives
    )
  end)
  -- Determine an efficient route through the quest points
  questPoints = Array.map(questPoints, function(point)
    local mapID = ZoneDB:GetUiMapIdByAreaId(point.zoneID)
    local x, y, z = GMR.GetWorldPositionFromMap(mapID, point.x, point.y)
    return {
      x = x,
      y = y,
      z = z
    }
  end)
  -- Do the route

  if GMR.IsExecuting() then

  end
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

local function convertMapPositionToWorldPosition(point)
  local mapID = ZoneDB:GetUiMapIdByAreaId(point.zoneID)
  local mapPoint = convertQuestiePointToMapPoint(point)
  if isValidMapPoint(mapPoint) then
    local x, y, z = GMR.GetWorldPositionFromMap(mapID, mapPoint.x, mapPoint.y)
    return {
      x = x,
      y = y,
      z = z
    }
  else
    return nil
  end
end

function c()
  -- Guidelime.private.CG.currentGuide
  -- /dump Guidelime.private.CG.currentGuide.firstActiveIndex
  -- Guidelime.private.CG.currentGuide.steps[Guidelime.private.CG.currentGuide.firstActiveIndex]
  -- /dump Object.keys(Guidelime.private.CG.currentGuide.steps[Guidelime.private.CG.currentGuide.firstActiveIndex])
  -- /dump Guidelime.private.CG.currentGuide.steps[Guidelime.private.CG.currentGuide.firstActiveIndex].text
  -- /dump Guidelime.private.CG.currentGuide.steps[Guidelime.private.CG.currentGuide.firstActiveIndex].startPos

  local currentGuide = Guidelime.private.CG.currentGuide
  local step = currentGuide.steps[currentGuide.firstActiveIndex]
  local stepText = step.text
  print('step text', stepText)
  local questID = string.match(stepText, '%[QA(%d+)%]')
  if questID then
    questID = tonumber(questID, 10)
    local quest = QuestieDB:GetQuest(questID)
    local questStarter = determineQuestStarter(quest)
    local object = GMR.FindObject(questStarter.id)
    local x, y, z
    if object then
      x, y, z = GMR.ObjectPosition(object)
    else
      local questStartPoint = determineQuestStartPoint(quest)
      local position = convertMapPositionToWorldPosition(questStartPoint)
      x = position.x
      y = position.y
      z = position.z or 5000
    end
    print('x', x)
    print('y', y)
    print('z', z)
    print('GMR.Questing.InteractWith', x, y, z)
    GMR.Questing.InteractWith(x, y, z, questStarter.id, nil, 4)
  else
    local questIDs = {}
    for questID in string.gmatch(stepText, '%[QC(%d+)') do
      questID = tonumber(questID, 10)
      table.insert(questIDs, questID)
    end

    if #questIDs >= 1 then
      local questerName = 'Quest: ' .. strjoin(', ', unpack(questIDs))
      print('define quester')
      GMR.DefineQuester(questerName, function()
        Array.forEach(questIDs, function(questID)
          GMR.DefineQuest(
            'Alliance', -- TODO: From quest info
            nil,
            questID,
            QuestUtils_GetQuestName(questID),
            'Custom',
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            nil,
            { function()
              print('quest info')

              local quest = QuestieDB:GetQuest(questID)
              local objectives = quest.Objectives
              local openObjectives = Array.filter(objectives, function(objective)
                return not objective.Completed
              end)

              if #openObjectives >= 1 then
                local objective = openObjectives[1]

                local objectID, spawnListEntries = next(objective.spawnList)

                local object = GMR.FindObject(objectID)
                print('object', object)
                local mapID
                local x, y, z
                if object then
                  mapID = GMR.GetMapId()
                  x, y, z = GMR.ObjectPosition(object)
                else
                  local spawns = spawnListEntries.Spawns

                  local zoneID, spawnPoints = next(spawns)

                  local spawnPoint = spawnPoints[1]

                  local point = {
                    zoneID = zoneID,
                    x = spawnPoint[1],
                    y = spawnPoint[2]
                  }
                  mapID = ZoneDB:GetUiMapIdByAreaId(zoneID)
                  local continentID = C_Map.GetWorldPosFromMapPos(mapID, point)
                  local position = convertMapPositionToWorldPosition(point)

                  print('z', position.z)

                  x = position.x
                  y = position.y
                  z = position.z
                end

                print(objectID)

                local sourceItemId = objective.QuestData.sourceItemId

                --if sourceItemId then
                --  print('GMR.Questing.UseItemOnNpc', x, y, z)
                --  GMR.Questing.UseItemOnNpc(x, y, z, objectID, sourceItemId, 4)
                --else
                --  print('GMR.Questing.InteractWith', x, y, z)
                --  GMR.Questing.InteractWith(x, y, z, objectID, nil, 4)
                --end
                print('GMR.MapMove', mapID, x, y, z)
                GMR.MapMove(mapID, x, y, z)
              end
            end },
            function()
              print('profile data')
              GMR.SkipTurnIn()

              for type, list in pairs(Questie.db.char.vendorList) do
                Array.forEach(list, function(npcID)
                  local npc = QuestieDB:GetNPC(npcID)
                  local point = determineFirstObjectSpawn(npc)
                  if point then
                    local position = convertMapPositionToWorldPosition(point)
                    if position then
                      local x = position.x
                      local y = position.y
                      local z = position.z
                      if type == 'Drink' or type == 'Food' then
                        GMR.DefineGoodsVendor(x, y, z, npcID)
                      end
                      print('GMR.DefineSellVendor', x, y, z, npcID)
                      GMR.DefineSellVendor(x, y, z, npcID)
                    end
                  end
                end)
              end

              for type, list in pairs(Questie.db.char.townsfolk) do
                Array.forEach(list, function(npcID)
                  local npc = QuestieDB:GetNPC(npcID)
                  if npc then
                    local point = determineFirstObjectSpawn(npc)
                    if point then
                      local position = convertMapPositionToWorldPosition(point)
                      if position then
                        local x = position.x
                        local y = position.y
                        local z = position.z
                        if type == 'Mailbox' then
                          GMR.DefineProfileMailbox(x, y, z)
                        elseif type == 'Reagents' then
                          print('GMR.DefineSellVendor', x, y, z, npcID)
                          GMR.DefineSellVendor(x, y, z, npcID)
                        end
                      end
                    end
                  end
                end)
              end

              local quest = QuestieDB:GetQuest(questID)
              local objectives = quest.Objectives
              local openObjectives = Array.filter(objectives, function(objective)
                return not objective.Completed
              end)

              logToFile(tableToString(openObjectives, 3))

              Array.forEach(openObjectives, function(objective)
                Array.forEach(Object.keys(objective.spawnList), function(objectID)
                  GMR.DefineQuestEnemyId(objectID)
                  GMR.DefineCustomObjectId(objectID)
                end)

                Array.forEach(Object.values(objective.spawnList), function(spawnListEntries)
                  local spawns = spawnListEntries.Spawns
                  for zoneID, spawnPoints in pairs(spawns) do
                    Array.forEach(spawnPoints, function(spawnPoint)
                      local point = {
                        zoneID = zoneID,
                        x = spawnPoint[1],
                        y = spawnPoint[2]
                      }
                      local position = convertMapPositionToWorldPosition(point)
                      if position.z then
                        print('GMR.DefineProfileCenter')
                        GMR.DefineProfileCenter(position.x, position.y, position.z, 150)
                      end
                    end)
                  end
                end)
              end)
            end
          )
        end)
      end)
      GMR.LoadQuester(questerName)
    else
      local questID = string.match(stepText, '^%[QT(%d+)%]')
      if questID then
        questID = tonumber(questID, 10)
        local quest = QuestieDB:GetQuest(questID)
        local turnInObject = determineTurnInObject(quest)
        local object = GMR.FindObject(turnInObject.id)
        local x, y, z
        if object then
          x, y, z = GMR.ObjectPosition(object)
        else
          local point = determineFirstObjectSpawn(turnInObject)
          local position = convertMapPositionToWorldPosition(point)
          x = position.x
          y = position.y
          z = position.z
        end
        print('x', x)
        print('y', y)
        print('z', z)
        print('GMR.Questing.InteractWith', x, y, z)
        GMR.Questing.InteractWith(x, y, z, turnInObject.id, nil, 4)
      end
    end
  end
end

local function seemsThatIsGoingToCreateHealthstone()
  local SOUL_SHARD = 6265
  return (
    not GMR.HealthstoneExists() and
      GMR.GetClass() == 'WARLOCK' and
      GMR.GetInventorySpace() >= 1 and
      GMR.ItemExists(SOUL_SHARD)
  )
end

function d()
  local run = function()
    --local MAXIMUM_AGGRO_RADIUS = 45
    --local SAME_LEVEL_AGGRO_RADIUS = 20
    --local AGGRO_RADIUS_INCREASE_PER_LEVEL_HIGHER = 1
    --local DELTA = 10
    --
    --local objects = includeGUIDInObject(GMR.GetNearbyObjects(MAXIMUM_AGGRO_RADIUS + DELTA))
    --objects = Array.filter(objects, function(object)
    --  local playerLevel = GMR.UnitLevel('player')
    --  local objectLevel = GMR.UnitLevel(object.GUID)
    --  return GMR.UnitCanAttack(object.GUID, 'player') and objectLevel > playerLevel
    --end)
    --for _, object in ipairs(objects) do
    --  -- GMR.AvoidUnit(object.GUID)
    --  local x, y, z = GMR.ObjectPosition(object.GUID)
    --  local playerLevel = GMR.UnitLevel('player')
    --  local objectLevel = GMR.UnitLevel(object.GUID)
    --  GMR.DefineMeshAreaBlacklist(x, y, z, SAME_LEVEL_AGGRO_RADIUS + (objectLevel - playerLevel))
    --end

    local questID = GMR.GetQuestId()
    if (
      GMR.IsExecuting() and
        not GMR.InCombat() and
        not (questID and GMR.IsQuestActive(questID) and not GMR.IsQuestCompletable(questID)) and
        not GMR.IsQuesting() and
        not GMR.IsCasting() and
        not GMR.IsSelling() and
        not GMR.IsAttacking() and
        not GMR.IsClassTrainerNeeded() and
        not GMR.IsDead() and
        not GMR.IsDrinking() and
        not GMR.IsEating() and
        not GMR.IsFishing() and
        not GMR.IsLooting() and
        not GMR.IsMailing() and
        not seemsThatIsGoingToCreateHealthstone() and
        not GMR.IsUnstuckEnabled() and
        not GMR.IsPreparing()
    ) then
      -- GMR.StopMoving = function () end
      c()
    else
      -- GMR.StopMoving = stopMoving
    end
  end

  -- run()
  C_Timer.NewTicker(0, run)
end

function e()
  GMR.DefineQuester('Questing', function()
    GMR.DefineQuest(
      'Alliance',
      nil,
      983,
      QuestUtils_GetQuestName(983),
      'Custom',
      nil,
      nil,
      nil,
      nil,
      nil,
      nil,
      nil,
      nil,
      { function()
        print('quest info')
      end },
      function()
        print('profile data')
      end
    )
  end)
  GMR.LoadQuester('Questing')
end

function f()
  local mapID = C_Map.GetBestMapForUnit("player")
  local positionOnMap = C_Map.GetPlayerMapPosition(mapID, 'player')
  local x, y, z = GMR.GetWorldPositionFromMap(mapID, positionOnMap.x, positionOnMap.y)
  print(x, y, z)
  local playerPosition = GMR.GetPlayerPosition()
  print(playerPosition.x, playerPosition.y, playerPosition.z)
end

function g()
  local mapID = C_Map.GetBestMapForUnit("player")
  local positionOnMap = { x = 0.37011867761612, y = 0.43634825944901 }
  local x, y, z = GMR.GetWorldPositionFromMap(mapID, positionOnMap.x, positionOnMap.y)
  print(x, y, z)
  local playerPosition = {
    x = 6427.9458007812,
    y = 517.38958740234,
    z = 8.6709308624268
  }
  print(playerPosition.x, playerPosition.y, playerPosition.z)
end

function waitFor(predicate)
  local thread = coroutine.running()
  local ticker
  ticker = C_Timer.NewTicker(0, function()
    if predicate() then
      ticker:Cancel()
      coroutine.resume(thread)
    end
  end)
  coroutine.yield()
end

local dockPosition = {
  x = -8641.3349609375,
  y = 1331.2628173828,
  z = 5.2331943511963
}

function moveToDockInStormwind()
  GMR.MeshTo(
    dockPosition.x,
    dockPosition.y,
    dockPosition.z
  )
end

function waitForPlayerToHaveArrivedAtDockInStormwind()
  waitForPlayerToBeOnPosition(dockPosition)
end

function waitForPlayerToBeOnPosition(position)
  waitFor(function()
    return GMR.IsPlayerPosition(position.x, position.y, position.z, 3)
  end)
end

function waitForShipToHaveArrivedAtStormwind()
  waitFor(function()
    local objectGUID = GMR.FindObject(25013)
    if objectGUID then
      local x, y, z = GMR.ObjectPosition(objectGUID)
      return GMR.GetDistanceBetweenPositions(
        -8647.5673828125,
        1336.5311279297,
        6.0574994087219,
        x,
        y,
        z
      ) <= 1
    end
  end)
end

function moveOntoShip()
  local x, y, z = GMR.ObjectPosition(25013)
  GMR.MoveTo(x, y, z)
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
    waitForShipToHaveArrivedAtAuberdine()
    moveOffShip()
  elseif isKalimdor(currentContinentID) and isEasternKingdoms(continentID) then
    moveToDockInAuberdine()
    waitForPlayerToHaveArrivedAtDockInAuberdine()
    waitForShipToHaveArrivedAtAuberdine()
    moveOntoShip()
    waitForShipToHaveArrivedAtStormwind()
    moveOffShip()
  end
end
