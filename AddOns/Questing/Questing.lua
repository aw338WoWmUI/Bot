Questing = Questing or {}

local ALLIANCE = 'Alliance'
INTERACT_DISTANCE = 5.3

function defineQuest(questID, questName, pickUpX, pickUpY, pickUpZ, pickUpObjectID, turnInX,
  turnInY, turnInZ, turnInObjectID, questInfo, profileInfo, ...)
  GMR.DefineQuest(
    ALLIANCE,
    nil,
    questID,
    questName,
    'Custom',
    pickUpX,
    pickUpY,
    pickUpZ,
    pickUpObjectID,
    turnInX,
    turnInY,
    turnInZ,
    turnInObjectID,
    { questInfo },
    profileInfo,
    ...
  )
end

function generateQuestNameList(quests)
  return strjoin(', ', unpack(Array.map(quests, function(quest)
    local questID = quest[1]
    return QuestUtils_GetQuestName(questID)
  end)))
end

function defineQuestsMassPickUp(quests, profileInfo)
  GMR.DefineQuest(
    ALLIANCE,
    nil,
    nil,
    'Pick up: ' .. generateQuestNameList(quests),
    'MassPickUp',
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    quests,
    profileInfo or nil
  )
end

function defineQuestsMassTurnIn(quests)
  GMR.DefineQuest(
    ALLIANCE,
    nil,
    nil,
    'Turn in: ' .. generateQuestNameList(quests),
    'MassTurnIn',
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    quests
  )
end

function gossipWithAt(x, y, z, objectID, optionToSelect)
  GMR.Questing.GossipWith(
    x,
    y,
    z,
    objectID,
    nil,
    INTERACT_DISTANCE,
    optionToSelect or 1
  )
end

function gossipWith(objectID, optionToSelect)
  local objectGUID = GMR.FindObject(objectID)
  if objectGUID then
    local x, y, z = GMR.ObjectPosition(objectGUID)
    gossipWithAt(x, y, z, objectID, optionToSelect)
  end
end

function followNPC(objectID, distance)
  GMR.Questing.FollowNpc(objectID, distance or 5)
end

function interactWithAt(x, y, z, objectID, distance, delay)
  GMR.Questing.InteractWith(
    x,
    y,
    z,
    objectID,
    delay or nil,
    distance or INTERACT_DISTANCE
  )
end

function interactWith(objectID, distance, dynamicFlag)
  local objectGUID = GMR.GetObjectWithInfo({
    id = objectID,
    dynamicFlag = dynamicFlag
  })
  if objectGUID then
    local x, y, z = GMR.ObjectPosition(objectGUID)
    interactWithAt(x, y, z, objectID, distance)
  end
end

function areSameGossipOptions(optionsA, optionsB)
  return Array.equals(optionsA, optionsB, function(option)
    return option.name
  end)
end

function createGossiper(x, y, z, objectID, optionsToSelect)
  local previousOptions = nil
  local optionsIndex = 1

  local function hasFinishedGossiping()
    return optionsIndex > #optionsToSelect
  end

  return {
    gossip = function()
      local numberOfOptions = C_GossipInfo.GetNumOptions()
      if numberOfOptions == 0 then
        GMR.Questing.GossipWith(
          x,
          y,
          z,
          objectID,
          nil,
          INTERACT_DISTANCE
        )
      elseif not hasFinishedGossiping() then
        local options = C_GossipInfo.GetOptions()
        if previousOptions and not areSameGossipOptions(options, previousOptions) then
          optionsIndex = optionsIndex + 1
        end

        GMR.Questing.GossipWith(
          x,
          y,
          z,
          objectID,
          nil,
          INTERACT_DISTANCE,
          optionsToSelect[optionsIndex]
        )

        previousOptions = options
      end
    end,

    hasFinishedGossiping = hasFinishedGossiping
  }
end

function setSpecializationToPreferredOrFirstDamagerSpecialization()
  local specializationNameSetting = GMR.GetSelectedSpecializationValue()
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
  if not GMR.IsMoving() then
    GMR.MoveTo(x, y, z)
  end
end

function createMoveToAction(x, y, z)
  local stopMoving = nil
  local firstRun = true
  return {
    run = function()
      if firstRun then
        stopMoving = GMR.StopMoving
        GMR.StopMoving = function()
        end
        firstRun = false
      end
      moveToWhenNotMoving(x, y, z)
    end,
    isDone = function()
      return GMR.IsPlayerPosition(x, y, z, 1)
    end,
    whenIsDone = function()
      if stopMoving then
        GMR.StopMoving = stopMoving
      end
    end
  }
end

function createQuestingMoveToAction(x, y, z, distance)
  return {
    run = function()
      GMR.Questing.MoveTo(x, y, z)
    end,
    isDone = function()
      return GMR.IsPlayerPosition(x, y, z, distance or 1)
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
    if questStarter then
      local object = GMR.FindObject(questStarter.id)
      local x, y, z
      if object then
        x, y, z = GMR.ObjectPosition(object)
      else
        local questStartPoint = determineQuestStartPoint(quest)
        if questStartPoint then
          local position = convertMapPositionToWorldPosition(questStartPoint)
          x = position.x
          y = position.y
          z = position.z or 5000
        end
      end
      if x and y and z then
        print('x', x)
        print('y', y)
        print('z', z)
        print('GMR.Questing.InteractWith', x, y, z)
        GMR.Questing.InteractWith(x, y, z, questStarter.id, nil, 4)
      end
    end
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

function seemsThatIsGoingToCreateHealthstone()
  local SOUL_SHARD = 6265
  return (
    not GMR.HealthstoneExists() and
      GMR.GetClass() == 'WARLOCK' and
      GMR.GetInventorySpace() >= 1 and
      GMR.ItemExists(SOUL_SHARD)
  )
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
  Movement.waitForPlayerToBeOnPosition(dockPosition)
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
  return bit.band(GMR.ObjectDynamicFlags(object), 0x20) == 0x20
end

function isInteractableFlagSet(object)
  local dynamicFlags = GMR.ObjectDynamicFlags(object)
  return bit.band(dynamicFlags, 0x4) == 0x04
end

function isInteractable(object)
  return GMR.IsObjectInteractable(object) or isInteractableFlagSet(object)
end


function addObjectIDToObjective(questObjectiveToObjectIDs, objectID, questObjectiveIndex)
  if not questObjectiveToObjectIDs[questObjectiveIndex] then
    questObjectiveToObjectIDs[questObjectiveIndex] = {}
  end
  questObjectiveToObjectIDs[questObjectiveIndex][objectID] = true
end

function findObjectiveWhichMatchesAndAddItToTheLookup(questObjectiveToObjectIDs, questObjectives, objectIdentifier, doesMatch)
  local questObjective, questObjectiveIndex = Array.find(questObjectives, doesMatch)
  if questObjective then
    local objectID = GMR.ObjectId(objectIdentifier)
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
  return Array.map(retrieveQuestLogQuests2(), function (quest)
    return quest.id
  end)
end

function findRelationsToQuests(tooltipBaseName, unitID)
  local quests = retrieveQuestLogQuests2()
  local questIdToObjectives = Object.fromEntries(Array.map(quests, function (quest)
    return {
      key = quest.id,
      value = GMR.Questing.GetQuestInfo(quest.id)
    }
  end))
  local questNameToId = Object.fromEntries(Array.map(quests, function (quest)
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
        local questObjectiveToIsRelatedTo = relations[questID] or {}
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

function findRelationsToQuest(questID, questObjectiveToObjectIDs, tooltipBaseName, unitID)
  local questInfo = GMR.Questing.GetQuestInfo(questID)
  for lineIndex = 1, 18 do
    local textLeft = _G[tooltipBaseName .. 'TextLeft' .. lineIndex]
    if textLeft then
      local text = textLeft:GetText()
      if text == questName then
        for lineIndex2 = lineIndex + 1, 18 do
          local textLeft = _G[tooltipBaseName .. 'TextLeft' .. lineIndex2]
          if textLeft then
            local text = textLeft:GetText()
            local hasFoundQuestObjective = findObjectiveWhichMatchesAndAddItToTheLookup(questObjectiveToObjectIDs, questInfo, unitID,
              function(questObjective)
                return questObjective.text == text
              end)
            if not hasFoundQuestObjective then
              break
            end
          end
        end
      end
    end
  end
end

--GMR.ObjectDynamicFlags(GMR.FindObject(278313))
--GMR.IsObjectInteractable(GMR.FindObject(278313))

function Questing.useExtraActionButton1()
  local playerPosition = GMR.GetPlayerPosition()
  if GMR.IsFlyingMount(GMR.GetMount()) then
    local z = GMR.GetZCoordinate(playerPosition.x, playerPosition.y)
    local destination = {
      x = playerPosition.x,
      y = playerPosition.y,
      z = z
    }

    if GMR.IsPlayerPosition(destination.x, destination.y, destination.z, 3) then
      GMR.Dismount()
    end

    GMR.Questing.ExtraActionButton1(destination.x, destination.y, destination.z)
  else
    GMR.Questing.ExtraActionButton1(playerPosition.x, playerPosition.y, playerPosition.z)
  end
end
