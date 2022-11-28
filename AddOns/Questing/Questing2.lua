local addOnName, AddOn = ...
--- @class Questing
Questing = Questing or {}

local _ = {}

-- Questing_ = _

local INFINITY = 1 / 0

lootedObjects = Set.create()
local recentlyVisitedObjectivePoints = {}

local EXPLORE_QUESTS = true

local questsThatWorked = Set.create()
local questsThatFailedToWork = Set.create()
local questBlacklist = Set.create({
  31308, -- pet battle quest
})

local function isQuestThatWorked(questID)
  return (
    Set.contains(questsThatWorked, questID) or
      Set.contains(GMR_SavedVariablesPerCharacter.questsThatWorked or Set.create(), questID)
  )
end

local function isQuestThatFailedToWork(questID)
  return (
    Set.contains(questsThatFailedToWork, questID) or
      Set.contains(GMR_SavedVariablesPerCharacter.questsThatFailedToWork or Set.create(), questID)
  )
end

local function isQuestToBeDone(questID)
  if Set.contains(questBlacklist, questID) then
    return false
  end

  if EXPLORE_QUESTS then
    return not isQuestThatFailedToWork(questID)
  else
    return isQuestThatWorked(questID)
  end
end

function addQuestToQuestsThatWorked()
  local questID = C_SuperTrack.GetSuperTrackedQuestID()
  if not GMR_SavedVariablesPerCharacter.questsThatWorked then
    GMR_SavedVariablesPerCharacter.questsThatWorked = Set.create()
  end
  Set.add(GMR_SavedVariablesPerCharacter.questsThatWorked, questID)
end

function addQuestToQuestsThatFailedToWork()
  local questID = C_SuperTrack.GetSuperTrackedQuestID()
  if not GMR_SavedVariablesPerCharacter.questsThatFailedToWork then
    GMR_SavedVariablesPerCharacter.questsThatFailedToWork = Set.create()
  end
  Set.add(GMR_SavedVariablesPerCharacter.questsThatFailedToWork, questID)
end

local questIDs = Set.create({

})

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

function defineQuest3(questID, handler)
  questHandlers[questID] = {
    questID = questID,
    handler = handler
  }
end

local function waitForGossipOptionToBeAvailable(gossipOptionID, timeout)
  Coroutine.waitFor(function()
    local options = C_GossipInfo.GetOptions()
    local option = Array.find(options, function(option)
      return option.gossipOptionID == gossipOptionID
    end)
    return Boolean.toBoolean(option)
  end, timeout)
end

local function waitForGossipClosed(timeout)
  Events.waitForEvent('GOSSIP_CLOSED', timeout)
end

defineQuest3(
  30082,
  function(self)
    local targetLocation = Movement.createPoint(
      -354.69952392578,
      -632.87860107422,
      118.35806274414
    )

    if self:isObjectiveOpen(1) then
      if not Core.findClosestObjectToCharacterWithOneOfObjectIDs(57310) then
        if Questing.isRunning() then
          Questing.Coroutine.gossipWith(58376, 40644)
        end
        local gossipOptionID = 40648
        if Questing.isRunning() then
          waitForGossipOptionToBeAvailable(gossipOptionID, 2)
        end
        if Questing.isRunning() then
          C_GossipInfo.SelectOption(gossipOptionID)
        end
        if Questing.isRunning() then
          waitForGossipClosed(2)
        end
      end
      while Questing.isRunning() and self:isObjectiveOpen(1) do
        local npcID = 57310
        local pointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(npcID)
        if pointer then
          local npcPosition = Core.retrieveObjectPosition(pointer)
          local yaw = Core.calculateAnglesBetweenTwoPoints(targetLocation, npcPosition)
          local distance = 2
          local pushFromPosition = Movement.generatePoint(npcPosition, distance, yaw)
          Questing.Coroutine.moveTo(pushFromPosition, {
            distance = distance
          })
          Questing.Coroutine.interactWithObjectWithObjectID(npcID)
        end
        Yielder.yieldAndResume()
      end
    end
  end
)

do
  local objectIDs = Set.create({
    42383,
    42386,
    42391
  })
  defineQuest3(
    26209,
    function(self)
      local objects = Core.retrieveObjects()
      local object = Array.find(objects, function(object)
        return Set.contains(objectIDs, object.objectID) and Core.hasGossip(object.pointer)
      end)
      if object then
        Questing.Coroutine.gossipWithObject(object.pointer, 38008)
        StaticPopup1Button1:Click()
      end
    end
  )
end

do
  local questID = 26228
  defineQuest3(
    questID,
    function(self)
      Questing.Coroutine.useItemOnPosition(
        Movement.createPoint(
          -9849.0380859375,
          1398.9611816406,
          52.249256134033
        ),
        57761,
        1
      )
      Coroutine.waitFor(function()
        return Compatibility.QuestLog.isComplete(questID)
      end)
      if Core.isCharacterInVehicle() then
        Core.runMacroText('/leavevehicle')
      end
    end
  )
end

do
  local questID = 26232
  defineQuest3(
    questID,
    function(self)
      if self:isObjectiveOpen(1) then
        print(1)
        Questing.Coroutine.moveTo(Movement.createPoint(
          -9861.0556640625,
          1333.9146728516,
          41.904102325439
        ))
        Coroutine.waitFor(function()
          local object = Core.findClosestObjectToCharacterWithOneOfObjectIDs(42387)
          return object and Core.canUnitAttackOtherUnit('player', object)
        end)
        while not Compatibility.QuestLog.isComplete(questID) do
          local object = Core.findClosestObjectToCharacterWithOneOfObjectIDs(42387)
          if object then
            Questing.Coroutine.doMob(object)
          else
            Yielder.yieldAndResume()
          end
        end
      end
    end
  )
end

do
  local objectIDs = Set.create({
    42386,
    42384
  })
  local itemID = 57991
  defineQuest3(
    26271,
    function(self)
      local fedNPCs = Set.create()
      local filter = function(object)
        return Set.contains(objectIDs, HWT.ObjectId(object)) and not Set.contains(fedNPCs, object)
      end
      while Questing.isRunning() and not self:isComplete() do
        local object = Core.findClosestObjectToCharacter(filter)
        if object then
          local position = Core.retrieveObjectPosition(object)
          Questing.Coroutine.waitForItemReady(itemID)
          Questing.Coroutine.useItemOnPosition(position, itemID)
          Set.add(fedNPCs, object)
        end
        Yielder.yieldAndResume()
      end
    end
  )
end

do
  local ROCKET_BOOST_SPELL_ID = 79430
  local filter = function(object)
    return HWT.ObjectId(object) == 42342 and Core.isAlive(object)
  end
  defineQuest3(
    26257,
    function(self)
      while not self:isComplete() and Questing.isRunning() do
        if self:isObjectiveOpen(1) or not UnitInVehicle('player') then
          Questing.Coroutine.useItemOnNPC(
            Core.createWorldPosition(
              0,
              -10164.614257812,
              1282.4930419922,
              37.704322814941
            ),
            42381,
            57954
          )
        elseif self:isObjectiveOpen(2) then
          while UnitInVehicle('player') and Questing.isRunning() and not self:isComplete() do
            if GetSpellCooldown(ROCKET_BOOST_SPELL_ID) == 0 then
              Core.castSpellByID(ROCKET_BOOST_SPELL_ID)
            end
            local object = Core.findClosestObjectToCharacter(filter)
            if object then
              Questing.Coroutine.moveToObject(object, {
                distance = 2,
                stop = function()
                  return Core.isDead(object)
                end
              })
            else
              Questing.Coroutine.moveTo(
                Core.createWorldPosition(
                  0,
                  -10194.499023438,
                  1380.3041992188,
                  37.803089141846
                )
              )
            end
            Yielder.yieldAndResume()
          end
        end
      end
    end
  )
end

defineQuest3(
  26290,
  function(self)
    if not self:isComplete() then
      Questing.Coroutine.moveTo(
        Core.createWorldPosition(
          0,
          -11109.7578125,
          588.560546875,
          35.322311401367
        )
      )
      Coroutine.waitForDuration(2)
      Coroutine.waitUntil(function()
        return not Core.isCharacterInCombat()
      end)

      Questing.Coroutine.moveTo(
        Core.createWorldPosition(
          0,
          -11126.299804688,
          570.71563720703,
          35.891700744629
        )
      )
      Coroutine.waitForDuration(2)
      Coroutine.waitUntil(function()
        return not Core.isCharacterInCombat()
      end)

      Questing.Coroutine.moveTo(
        Core.createWorldPosition(
          0,
          -11134.517578125,
          557.58966064453,
          35.960052490234
        )
      )

      Questing.Coroutine.useItem(58112)

      Questing.Coroutine.moveTo(
        Core.createWorldPosition(
          0,
          -11135.608398438,
          555.91906738281,
          70.352745056152
        )
      )

      Coroutine.waitUntil(function()
        return self:isComplete()
      end)
    end
  end
)

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
  local faction = Core.retrieveCharacterFaction()
  local playerClassID = retrievePlayerClassID()
  local playerRaceID = retrievePlayerRaceID()
  return (
    not Compatibility.QuestLog.isQuestFlaggedCompleted(quest.id) and
      not Compatibility.QuestLog.isOnQuest(quest.id) and
      (not quest.requiredLevel or playerLevel >= quest.requiredLevel) and
      (not quest.classes or Array.any(quest.classes, function(class)
        return playerClassID == class
      end)) and
      (not quest.races or Array.any(quest.races, function(race)
        return playerRaceID == race
      end)) and
      (not quest.sides or Array.includes(quest.sides, 'Both') or Array.includes(quest.sides, faction)) and
      Array.all(quest.preQuestIDs, function(preQuestID)
        return Compatibility.QuestLog.isQuestFlaggedCompleted(preQuestID)
      end) and
      Array.all(quest.storylinePreQuestIDs, function(preQuestID)
        return Compatibility.QuestLog.isQuestFlaggedCompleted(preQuestID)
      end)
  )
end

function isValidMapCoordinate(coordinate)
  return coordinate >= 0 and coordinate <= 1
end

local Position = {}

function Position:new(continentID, point)
  local position = {
    continentID = continentID,
    x = point.x,
    y = point.y,
    z = point.z
  }
  return position
end

local function convertMapPositionToWorldPosition(mapPosition)
  if (
    mapPosition and
      mapPosition[1] ~= nil and
      isValidMapCoordinate(mapPosition[2]) and
      isValidMapCoordinate(mapPosition[3])
  ) then
    return Core.retrieveWorldPositionFromMapPosition({
      mapID = mapPosition[1],
      x = mapPosition[2],
      y = mapPosition[3]
    })
  else
    return nil
  end
end

function retrieveNPCPosition(npc)
  local npcMapPosition = npc.coordinates[1]
  return convertMapPositionToWorldPosition(npcMapPosition)
end

function isQuestLogFull()
  local currentNumberOfQuests = select(2, Compatibility.QuestLog.retrieveNumberOfQuestLogEntries())
  local maximumNumberOfQuests = C_QuestLog.GetMaxNumQuestsCanAccept()
  return currentNumberOfQuests >= maximumNumberOfQuests
end

function canPickUpQuest()
  return not isQuestLogFull()
end

local questGiverStatuses = Set.create({
  Unlocker.QuestGiverStatuses.DailyQuest,
  Unlocker.QuestGiverStatuses.Quest
})

local function generateQuestStartPointsFromStarters(quest)
  if quest.starters then
    local yielder = Yielder.createYielderWithTimeTracking(1 / 60)

    return Array.selectTrue(Array.map(quest.starters, function(starter)
      -- TODO: Seems to make sense to also include other types.
      if starter.type == 'npc' then
        local npc = Questing.Database.retrieveNPC(starter.id)
        if npc then
          local npcPointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(npc.id)
          if npcPointer and not Set.contains(questGiverStatuses, Unlocker.retrieveQuestGiverStatus(npcPointer)) then
            return nil
          end

          local position = retrieveNPCPosition(npc)
          if position then
            local continentID = position.continentID
            local x, y, z
            if npcPointer then
              local position = Core.retrieveObjectPosition(npcPointer)
              x, y, z = position.x, position.y, position.z
            else
              x, y, z = position.x, position.y, position.z
            end

            if not npcPointer and Core.calculateDistanceFromCharacterToPosition(Core.createPosition(x, y,
              z)) <= Core.RANGE_IN_WHICH_OBJECTS_SEEM_TO_BE_SHOWN then
              return nil
            else
              local point = {
                objectID = npc.id,
                continentID = continentID,
                x = x,
                y = y,
                z = z,
                type = 'acceptQuests',
                questIDs = {
                  quest.id
                },
                questName = QuestUtils_GetQuestName(quest.id)
              }
              return point
            end
          else
            -- print('Missing NPC coordinates for NPC with ID "' .. npc.id .. '".')
          end
        else
          -- print('Missing NPC for ID "' .. starterID .. '" for quest "' .. quest.id .. '".')
        end

        if yielder.hasRanOutOfTime() then
          yielder.yield()
        end
      end
    end))
  else
    -- print('Missing quest starter IDs for quest "' .. quest.id .. '".')
    return {}
  end
end

local function retrieveAttackerPoints()
  local attackers = Array.filter(Core.retrieveObjectPointers(), Core.isUnitAttackingTheCharacter)
  return convertObjectPointersToObjectPoints(attackers, 'attacker')
end

function retrieveQuestStartPoints()
  local points
  if isQuestLogFull() then
    points = {}
  else
    points = Array.concat(
      _.retrieveQuestStartPointsFromObjects(),
      _.retrieveQuestStartPointsFromAddOnDatabase(),
      _.retrieveQuestStartPointsFromMap()
    )

    Array.append(points, _.retrieveQuestStartPointsFromQuestLinesWhichArentAlreadyCoveredByOtherPoints(points))
  end

  return points
end

function _.retrieveQuestStartPointsFromObjects()
  local points = {}
  local objects = Core.retrieveObjects()
  local continentID = select(8, GetInstanceInfo())
  Array.forEach(objects, function(object)
    if Set.contains(questGiverStatuses, Unlocker.retrieveQuestGiverStatus(object.pointer)) then
      local point = {
        objectID = object.objectID,
        continentID = continentID,
        x = object.x,
        y = object.y,
        z = object.z,
        type = 'acceptQuests',
        questIDs = nil,
        questName = nil,
        fromObject = true,
        pointer = object.pointer
      }
      table.insert(points, point)
    end
  end)
  return points
end

function _.retrieveQuestStartPointsFromMap()
  local quests = retrieveQuestsOnMapThatCanBeAccepted()

  local points = Array.selectTrue(Array.flatMap(quests, function(quest)
    if not unavailableQuestIDs[quest.id] then
      return generateQuestStartPointsFromStarters(quest)
    end
  end))

  return points
end

function _.retrieveQuestStartPointsFromAddOnDatabase()
  return Array.map(
    Array.filter(questGivers, function(questGiver)
      return Array.any(questGiver.questIDs, function(questID)
        return not Compatibility.QuestLog.isQuestFlaggedCompleted(questID) and not Compatibility.QuestLog.isOnQuest(questID)
      end)
    end),
    function(questGiver)
      local point = Object.copy(questGiver)
      point.type = 'acceptQuests'
    end
  )
end

function _.retrieveQuestStartPointsFromQuestLinesWhichArentAlreadyCoveredByOtherPoints(otherPoints)
  local coveredQuestIDs = Set.create(Array.flatMap(otherPoints, function(point)
    return point.questIDs
  end))

  return _.retrieveQuestStartPointsFromQuestLinesWhichArentAlreadyCovered(coveredQuestIDs)
end

function _.retrieveQuestStartPointsFromQuestLinesWhichArentAlreadyCovered(coveredQuestIDs)
  return _.selectPointsWithQuestsThatArentAlreadyCovered(
    _.retrieveQuestStartPointsFromQuestLines(),
    coveredQuestIDs
  )
end

function _.retrieveQuestStartPointsFromQuestLines()
  if Compatibility.isRetail() then
    local mapID = Core.receiveMapIDForWhereTheCharacterIsAt()
    local questLines = retrieveAvailableQuestLines(mapID) -- FIXME: It seems that it might be required to request the quest line data from the server before this API returns it.
    while Array.isEmpty(questLines) and C_Map.GetMapInfo(mapID).parentMapID ~= 0 do
      mapID = C_Map.GetMapInfo(mapID).parentMapID
      questLines = retrieveAvailableQuestLines(mapID)
    end

    local points = Array.selectTrue(Array.flatMap(questLines, function(questLine)
      if Compatibility.QuestLog.isOnQuest(questLine.questID) then
        return nil
      else
        local quest = Questing.Database.retrieveQuest(questLine.questID)
        if quest then
          return generateQuestStartPointsFromStarters(quest)
        else
          local position = Core.retrieveWorldPositionFromMapPosition({
            mapID = mapID,
            x = questLine.x,
            y = questLine.y
          })
          return {
            objectID = nil,
            continentID = position.continentID,
            x = position.x,
            y = position.y,
            z = position.z,
            type = 'acceptQuests',
            questIDs = {
              questLine.questID
            },
            questName = questLine.questName
          }
        end
      end
    end))

    return points
  else
    return {}
  end
end

function _.selectPointsWithQuestsThatArentAlreadyCovered(points, coveredQuestIDs)
  return Array.filter(points, function(point)
    return _.areSomeQuestsOfPointNotInSet(point, coveredQuestIDs)
  end)
end

function _.areSomeQuestsOfPointNotInSet(point, questIDs)
  return Array.any(point.questIDs, function(questID)
    return not Set.contains(questIDs, questID)
  end)
end

function _.areAllQuestsOfPointInSet(point, questIDs)
  return Array.all(point.questIDs, function(questID)
    return Set.contains(questIDs, questID)
  end)
end

function retrieveQuestsOnMapThatTheCharacterIsOn()
  local retrieveQuestsOnMap
  if Compatibility.isRetail() then
    retrieveQuestsOnMap = function(mapID)
      local quests = C_QuestLog.GetQuestsOnMap(mapID)
      return Array.map(quests, function(quest)
        quest.mapID = mapID
        return quest
      end)
    end
  else
    retrieveQuestsOnMap = Questing.Database.retrieveQuestsOnMapThatTheCharacterIsOn
  end

  return _.retrieveQuestsOnMapCheckingUpwards(retrieveQuestsOnMap)
end

local MapIDs = {
  Stormwind = 84,
  ElwynnForest = 37,
  --Ogrimmar = ,
}

local customParentMapIDs = {
  [MapIDs.Stormwind] = MapIDs.ElwynnForest
  --[MapI]
  -- TODO: Mapping for other cities to their zone that they are in.
}

function _.retrieveQuestsOnMapCheckingUpwards(retrieveQuestsOnMap)
  local mapID = Core.receiveMapIDForWhereTheCharacterIsAt()
  if mapID then
    while true do
      local mapInfo = C_Map.GetMapInfo(mapID)
      if mapInfo.mapType >= 3 then
        local quests = retrieveQuestsOnMap(mapID)
        if Array.hasElements(quests) then
          return quests, mapID
        else
          local customParentMapID = customParentMapIDs[mapID]
          if customParentMapID then
            mapID = customParentMapID
          else
            mapID = mapInfo.parentMapID
          end
        end
      else
        return {}, nil
      end
    end
  else
    return {}, nil
  end
end

function retrieveQuestsOnMapThatCanBeAccepted()
  local retrieveQuestsOnMap
  if Compatibility.isRetail() then
    -- FIXME: Might be off.
    retrieveQuestsOnMap = function(mapID)
      local quests = C_QuestLog.GetQuestsOnMap(mapID)
      return Array.filter(
        Array.map(quests, function(quest)
          quest.mapID = mapID
          return quest
        end),
        function(quest)
          return AddOn.isNotOnQuest(quest.questID)
        end
      )
    end
  else
    retrieveQuestsOnMap = Questing.Database.receiveQuestsOnMapThatCanBeAccepted
  end

  return _.retrieveQuestsOnMapCheckingUpwards(retrieveQuestsOnMap)
end

function AddOn.isNotOnQuest(questID)
  return not Compatibility.QuestLog.isOnQuest(questID)
end

function retrieveWorldPositionFromMapPosition(mapID, mapX, mapY)
  if mapID and mapX and mapY then
    local position = Core.retrieveWorldPositionFromMapPosition({
      mapID = mapID,
      x = mapX,
      y = mapY
    })
    return position.continentID, Movement.createPoint(position.x, position.y, position.z)
  else
    return nil, nil
  end
end

function determineFirstOpenObjectiveIndex(questID)
  local objectives = C_QuestLog.GetQuestObjectives(questID)
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
  return Compatibility.QuestLog.isComplete(questID)
end

function retrieveObjectivePoints()
  local quests, mapID = retrieveQuestsOnMapThatTheCharacterIsOn()
  local points = Array.selectTrue(
    Array.map(quests, function(quest)
      local questID = quest.questID
      local pointer = nil

      local continentID, position = retrieveWorldPositionFromMapPosition(mapID, quest.x, quest.y)
      if continentID and position then
        local x, y, z = position.x, position.y, position.z

        local objectIDs
        if canQuestBeTurnedIn(questID) then
          local quest2 = Questing.Database.retrieveQuest(questID)
          objectIDs = Array.map(quest2.enders, function(ender)
            return ender.id
          end)
        else
          local firstOpenObjectiveIndex = determineFirstOpenObjectiveIndex(questID)
          local questObjectiveInfo = Array.create(retrieveQuestObjectiveInfo(questID, firstOpenObjectiveIndex))
          objectIDs = questObjectiveInfo
            :filter(
            function(object)
              return object.type == 'npc' or object.type == 'object'
            end
          )
            :map(
            function(object)
              return object.id
            end
          )
        end
        local objectID
        if objectIDs then
          objectID = objectIDs[1]
          if objectID then
            local position = Core.createWorldPosition(continentID, x, y, z)
            local objectPointer = Core.findClosestObjectWithOneOfObjectIDsTo(objectID, position)
            if objectPointer then
              local position = Core.retrieveObjectPosition(objectPointer)
              x, y, z = position.x, position.y, position.z
            elseif objectIDsOfObjectsWhichCurrentlySeemAbsent[objectID] then
              return nil
            end
          end
        else
          objectID = nil
        end

        if not objectID then
          local position = Core.createWorldPosition(continentID, x, y, z)
          local object = Core.findClosestQuestRelatedObjectTo(questID, position)
          if object then
            objectID = HWT.ObjectId(object)
            pointer = object
          end
        end

        return {
          pointer = pointer,
          continentID = continentID,
          x = x,
          y = y,
          z = z,
          objectID = objectID,
          type = 'objective',
          questIDs = {
            questID
          }
        }
      else
        return nil
      end
    end)
  )

  points = Array.filter(points, function(point)
    return (
      not recentlyVisitedObjectivePoints[Movement.createPoint(point.x, point.y, point.z)]
        and Array.any(point.questIDs, _.hasEnoughFreeSlotsToCompleteQuest)
    )
  end)

  return points
end

--C_AreaPoiInfo.GetAreaPOIForMap(Core.receiveMapIDForWhereTheCharacterIsAt())
--C_QuestLine.GetAvailableQuestLines(Core.receiveMapIDForWhereTheCharacterIsAt())
--C_QuestLine.GetQuestLineInfo(48421, Core.receiveMapIDForWhereTheCharacterIsAt())
--C_QuestLine.GetQuestLineQuests(586)
--C_QuestLine.GetQuestLineInfo(49178, Core.receiveMapIDForWhereTheCharacterIsAt())

function retrieveAvailableQuestLines(mapID)
  C_QuestLine.RequestQuestLinesForMap(mapID)
  Events.waitForEvent('QUESTLINE_UPDATE', 0.2)
  return C_QuestLine.GetAvailableQuestLines(mapID)
end

local isObjectRelatedToActiveQuestLookup = {}

local function retrieveQuestIDsOfActiveQuestsToWhichObjectSeemsRelated(object)
  if Compatibility.isRetail() then
    return ObjectQuests.ObjectQuests(object)
    --local questIDs = Set.create()
    --local objectID = HWT.ObjectId(object)
    --
    --local relations
    --if (
    --  Core.retrieveObjectPointer(object) == Core.retrieveObjectPointer('softinteract') and
    --    UnitName('softinteract') == GameTooltipTextLeft1:GetText()
    --) then
    --  relations = findRelationsToQuests('GameTooltip', 'softinteract')
    --  -- TODO: Merge new quest relationship information into explored object. Also consider the case when the explored object doesn't exist (regarding exploring other info for the object).
    --  if exploredObjects[HWT.ObjectId(object)] and not exploredObjects[HWT.ObjectId(object)].questRelationships then
    --    exploredObjects[HWT.ObjectId(object)].questRelationships = relations
    --  end
    --elseif exploredObjects[HWT.ObjectId(object)] then
    --  relations = exploredObjects[HWT.ObjectId(object)].questRelationships
    --end
    --
    --if relations then
    --  Array.forEach(Object.entries(relations), function(entry)
    --    local questID = entry.key
    --    local objectiveIndexesThatObjectIsRelatedTo = entry.value
    --    if (
    --      Compatibility.QuestLog.isOnQuest(questID) and
    --        not Compatibility.QuestLog.isComplete(questID) and
    --        Set.containsWhichFulfillsCondition(objectiveIndexesThatObjectIsRelatedTo, function(objectiveIndex)
    --          return not Core.isObjectiveComplete(questID, objectiveIndex)
    --        end)
    --    ) then
    --      questIDs:add(questID)
    --    end
    --  end)
    --end
    --
    --local npc = Questing.Database.retrieveNPC(objectID)
    --if npc then
    --  local objectiveOf = npc.objectiveOf
    --  if objectiveOf then
    --    for questID, objectiveIndexes in pairs(objectiveOf) do
    --      if (
    --        Compatibility.QuestLog.isOnQuest(questID) and
    --          not Compatibility.QuestLog.isComplete(questID) and
    --          Set.containsWhichFulfillsCondition(objectiveIndexes, function(objectiveIndex)
    --            return not Core.isObjectiveComplete(questID, objectiveIndex)
    --          end)
    --      ) then
    --        questIDs:add(questID)
    --      end
    --    end
    --  end
    --end
    --
    --return questIDs:toList()
  else
    local questieTooltip = AddOn.retrieveQuestieTooltip(object)
    if questieTooltip then
      return Array.map(
        Array.filter(
          Array.map(
            Object.entries(questieTooltip),
            function(keyAndValue)
              return keyAndValue.value
            end
          ),
          function(value)
            return not value.objective.Completed and (value.objective.Type ~= 'monster' or Core.isAlive(object))
          end),
        function(value)
          return value.questId
        end
      )
    else
      return {}
    end
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
  local position = Core.retrieveObjectPosition(pointer)
  local objectID = HWT.ObjectId(pointer)
  local point = {
    name = Core.retrieveObjectName(pointer),
    continentID = position.continentID,
    x = position.x,
    y = position.y,
    z = position.z,
    type = type,
    pointer = pointer,
    objectID = objectID,
    questIDs = retrieveQuestIDsOfActiveQuestsToWhichObjectSeemsRelated(pointer)
  }
  if adjustPoint then
    point = adjustPoint(point)
  end
  return point
end

function convertObjectsToPointers(objects)
  return Array.map(objects, function(object)
    return object.pointer
  end)
end

function retrieveItemDescription(itemID)
  return Tooltips.retrieveItemTooltipText(itemID)
end

local turnInQuestGiverStatuses = Set.create({
  11,
  12
})

function _.seemsToBeQuestObjective(object)
  local canQuestBeTurnedIn = Set.contains(turnInQuestGiverStatuses, Unlocker.retrieveQuestGiverStatus(object))
  if Compatibility.isRetail() then
    -- FIXME: Make work for quests with quest objectives which are not alive.
    return (canQuestBeTurnedIn or ObjectQuests.ObjectIsQuestObjective(object)) and Core.isAlive(object)
  else
    return canQuestBeTurnedIn or Array.hasElements(retrieveQuestIDsOfActiveQuestsToWhichObjectSeemsRelated(object))
  end
end

function doesPassObjectFilter(object)
  return _.seemsToBeQuestObjective(object.pointer) or seemsToBeQuestObject(object.pointer)
end

function retrieveObjectPoints()
  local objects = Core.retrieveObjects()
  local filteredObjects = Array.filter(objects, doesPassObjectFilter)
  local objectPointers = convertObjectsToPointers(filteredObjects)
  local objectPoints = convertObjectPointersToObjectPoints(objectPointers, 'object')

  return objectPoints
end

function retrieveLootPoints()
  local objects = Core.retrieveObjects()
  local filteredObjects = Array.filter(objects, function(object)
    return not Set.contains(lootedObjects, object.pointer) and Core.isLootable(object.pointer)
  end)
  local objectPointers = convertObjectsToPointers(filteredObjects)
  local objectPoints = convertObjectPointersToObjectPoints(objectPointers, 'loot')

  return objectPoints
end

function retrieveFlightMasterDiscoveryPoints()
  local objects = Core.retrieveObjects()
  local filteredObjects = Array.filter(objects, function(object)
    return Core.isDiscoverableFlightMaster(object.pointer)
  end)
  local objectPointers = convertObjectsToPointers(filteredObjects)
  local objectPoints = convertObjectPointersToObjectPoints(objectPointers, 'discoverFlightMaster')

  return objectPoints
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
  local objects = Core.retrieveObjects()
  local object = Array.min(Array.filter(objects, function(object)
    return Questing.Database.isQuestGiver(object.objectID)
  end), function(object)
    return Core.calculateDistanceBetweenPositions(point, object)
  end)
  if object and Core.calculateDistanceBetweenPositions(point, object) <= 5 then
    return object
  end

  return nil
end

function retrieveQuestObjectivesInfo(questID)
  local quest = Questing.Database.retrieveQuest(questID)
  if quest then
    local objectives = quest.objectives
    return objectives
  else
    return nil
  end
end

function retrieveQuestObjectiveInfo(questID, objectiveIndex)
  local objectives = retrieveQuestObjectivesInfo(questID)
  return objectives[objectiveIndex]
end

local function determineClosestPoint(points)
  local playerPosition = Core.retrieveCharacterPosition()
  return Array.min(points, function(point)
    if point then
      local distance
      if point.z then
        distance = Core.calculateDistanceBetweenPositions(playerPosition, point)
      else
        distance = Core.calculate2DDistanceBetweenPositions(playerPosition, point)
      end

      return distance
    else
      return INFINITY
    end
  end)
end

local function retrieveDynamicPoints()
  return Array.concat(
    retrieveAttackerPoints(),
    retrieveObjectPoints(),
    retrieveLootPoints()
  )
end

local function determinePointToGo(points)
  if Array.hasElements(points.attackerPoints) then
    return determineClosestPoint(points.attackerPoints)
  end

  local maxCloseDistance = 50

  local function isPointClose(point)
    return Core.calculateDistanceFromCharacterToPosition(point) <= maxCloseDistance
  end

  local closeQuestStartPoints = Array.filter(points.questStartPoints, isPointClose)
  local closeDiscoverFlightMasterPoints = Array.filter(points.discoverFlightMasterPoints, isPointClose)
  local closeLootPoints = Array.filter(points.lootPoints, isPointClose)
  local doFirstPoints = Array.concat(closeQuestStartPoints, closeDiscoverFlightMasterPoints, closeLootPoints)
  if next(doFirstPoints) then
    return determineClosestPoint(doFirstPoints)
  elseif next(points.objectPoints) then
    return determineClosestPoint(points.objectPoints)
  else
    if next(points.explorationPoints) then
      return determineClosestPoint(points.explorationPoints)
    else
      local points2 = Array.concat(points.questStartPoints, points.objectivePoints, points.discoverFlightMasterPoints,
        points.lootPoints)
      if next(points2) then
        return determineClosestPoint(points2)
      else
        return nil
      end
    end
  end
end

function isSpecialItemUsable(point)
  -- TODO: Can spell target the target
  return IsQuestLogSpecialItemInRange(point.questLogIndex) == 1
end

function waitForSpecialItemUsable(point)
  return Coroutine.waitFor(function()
    Core.targetUnit(point.pointer)
    return isSpecialItemUsable(point)
  end, 10)
end

local function isPlayerOnMeshPoint()
  local playerPosition = Core.retrieveCharacterPosition()
  return Core.isOnMeshPoint(playerPosition)
end

function retrieveNavigationPosition()
  local frame = C_Navigation.GetFrame()

  if frame and C_Navigation.HasValidScreenPosition() and not C_Navigation.WasClampedToScreen() then
    frame2:Show()
    frame3:Show()

    local yielder = Yielder.createYielderWithTimeTracking(1 / 60)

    local lastDistance = nil
    local lastPosition = nil

    local pitch = HWT.UnitPitch('player')
    local yaw = HWT.ObjectFacing('player')

    while true do
      local playerPosition = Movement.retrieveCharacterPosition()
      local navigationPointDistance = C_Navigation.GetDistance()
      local navigationX, navigationY = frame:GetCenter()
      local scale = UIParent:GetEffectiveScale()
      navigationX = navigationX * scale
      navigationY = navigationY * scale

      frame3:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', navigationX, navigationY)

      local vector = Vector:new(
        navigationPointDistance * math.cos(yaw) * math.cos(pitch),
        navigationPointDistance * math.sin(yaw) * math.cos(pitch),
        navigationPointDistance * math.sin(pitch)
      )
      local position = Movement.createPoint(
        playerPosition.x + vector.x,
        playerPosition.y + vector.y,
        playerPosition.z + vector.z
      )
      point = position

      point2d = Core.convertWorldPositionToScreenPosition(position)
      local x, y = point2d.x, point2d.y
      frame2:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', x, y)

      local deltaX = navigationX - x
      local deltaY = navigationY - y

      local distance = Math.euclideanDistance2D(
        { x = navigationX, y = navigationY },
        { x = x, y = y }
      )

      if lastDistance and lastDistance <= distance then
        point = lastPosition
        frame2:Hide()
        frame3:Hide()
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
  else
    return nil
  end
end

function waitForPlayerHasArrivedAt(position)
  Movement.waitForPlayerToBeOnPosition(position, INTERACT_DISTANCE)
end

local function retrieveQuestSpecialItem(questID)
  local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
  if logIndex then
    local itemLink = GetQuestLogSpecialItemInfo(logIndex)
    if itemLink then
      local itemID = GetItemInfoInstant(itemLink)
      return itemID
    end
  end

  return nil
end

local function hasQuestSpecialItem(questID)
  return Boolean.toBoolean(retrieveQuestSpecialItem(questID))
end

local function hasSomeQuestASpecialItem(questIDs)
  return Array.any(questIDs, hasQuestSpecialItem)
end

local function retrieveFirstSpecialItem(questIDs)
  for _, questID in ipairs(questIDs) do
    local specialItem = retrieveQuestSpecialItem(questID)
    if specialItem then
      return specialItem
    end
  end
  return nil
end

local function doSomethingWithObject(point)
  local objectID = point.objectID
  local pointer = point.pointer
  if not pointer and objectID then
    pointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID) -- FIXME: Object closest to point position which matches objectID
  end

  if not pointer and objectID and Core.calculateDistanceFromCharacterToPosition(point) <= Core.RANGE_IN_WHICH_OBJECTS_SEEM_TO_BE_SHOWN then
    objectIDsOfObjectsWhichCurrentlySeemAbsent[point.objectID] = true
  else
    if pointer and Core.canUnitAttackOtherUnit('player', pointer) then
      print('doMob')
      _.doMob(pointer)
    elseif pointer and Core.hasGossip(pointer) then
      print('gossipWith')
      Questing.Coroutine.gossipWithObject(pointer)

      _.completeQuests()
      if GossipFrame:IsShown() and isAnyActiveQuestCompletable2() then
        local activeQuests = Compatibility.GossipInfo.retrieveActiveQuests()
        local quest = Array.find(activeQuests, function(quest)
          return Compatibility.QuestLog.isComplete(quest.questID)
        end)
        print('quest', quest)
        if quest then
          C_GossipInfo.SelectActiveQuest(quest.questID)
        end
      elseif QuestFrame:IsShown() and isAnyActiveQuestCompletable() then
        print('aa')
        local questIdentifier = _.findFirstCompleteActiveQuest()
        print('questIdentifier', questIdentifier)
        SelectActiveQuest(questIdentifier)
      end

      local options = Compatibility.GossipInfo.retrieveOptions()
      local option = options[1]
      if option then
        Compatibility.GossipInfo.selectOption(option.gossipOptionID)
      end
    elseif pointer and hasSomeQuestASpecialItem(point.questIDs) then
      local specialItem = retrieveFirstSpecialItem(point.questIDs)
      Questing.Coroutine.useItemOnPosition(point, specialItem)
    elseif pointer then
      print('interactWithObject')
      Questing.Coroutine.interactWithObject(pointer)
      _.completeQuests()
    elseif objectID then
      print('interactWithAt')
      Questing.Coroutine.interactWithAt(point, objectID)
    else
      print('moveToPoint2')
      Questing.Coroutine.moveTo(point)
    end
  end
end

function _.completeQuests()
  -- TODO: Support for completing multiple quests
  local activeQuests = Compatibility.Quests.retrieveActiveQuests()
  local activeQuest = Array.find(activeQuests, function(quest)
    return quest.isComplete
  end)
  if activeQuest then
    local questIdentifier
    if GossipFrame:IsShown() then
      questIdentifier = activeQuest.questID
    elseif QuestFrame:IsShown() then
      questIdentifier = activeQuest.index
    end
    Compatibility.Quests.selectActiveQuest(questIdentifier)
  end
  _.completeQuest()
  _.waitForNPCUpdate()
end

function _.completeQuest()
  if QuestFrameProgressPanel:IsShown() and IsQuestCompletable() then
    CompleteQuest()
  end
  if QuestFrameRewardPanel:IsShown() then
    --if not hasEnoughFreeSlotsToCompleteQuestGiverQuest() then
    --  local itemsToPickUp = _.retrieveItemsToPickUp()
    --
    --  local itemsToDestroy = retrieveItemsToDestroy(itemsToPickUp)
    --  if itemsToDestroy then
    --    destroyItems(itemsToDestroy)
    --  end
    --end
    if hasEnoughFreeSlotsToCompleteQuestGiverQuest() then
      GetQuestReward(1)
    end
  end
end

--function _.retrieveItemsToPickUp()
--  local questReward =
--  local sellPrice = receiveSellPrice(questReward)
--end

--function retrieveItemsToDestroy(itemsToPickUp)
--  local itemsThatQualifyForDestruction = findGrayItemsInBags()
--  sortItemsThatQualifyForDestruction(itemsThatQualifyForDestruction)
--
--  local itemsToDestroy = {}
--  for index = 1, #itemsToPickUp do
--    local itemToPickUp = itemsToPickUp[index]
--    local itemThatQualifiesForDestruction = itemsThatQualifyForDestruction[index]
--    if itemsToPickup.sellPrice >= itemThatQualifiesForDestruction.sellPrice then
--      table.insert(itemsToDestroy, itemThatQualifiesForDestruction)
--    else
--      return nil
--    end
--  end
--
--  return itemsToDestroy
--end

function _.waitForNPCUpdate()
  return Coroutine.waitForDuration(1)
end

function _.doMob(pointer)
  return Questing.Coroutine.doMob(pointer, {
    additionalStopConditions = function()
      return Core.isCharacterInCombat() and not Core.isUnitAttackingTheCharacter(pointer)
    end
  })
end

function acceptQuests(point)
  local stoppable = Stoppable:new()

  print(1)
  local questGiverPoint
  if point.objectID then
    questGiverPoint = point
  else
    local object = findClosestQuestGiver(point)
    if object then
      questGiverPoint = {
        objectID = object.objectID,
        x = object.x,
        y = object.y,
        z = object.z
      }
    end
  end
  if questGiverPoint then
    if questGiverPoint.pointer then
      Questing.Coroutine.gossipWithObject(questGiverPoint.pointer)
    else
      Questing.Coroutine.gossipWithAt(questGiverPoint, questGiverPoint.objectID)
    end
    local npcID = HWT.ObjectId('npc')
    if npcID == questGiverPoint.objectID then
      local availableQuests = Compatibility.Quests.retrieveAvailableQuests()
      local quests
      if point.questIDs then
        local questIDs = Set.create(point.questIDs)
        quests = Array.filter(availableQuests, function(quest)
          return questIDs:contains(quest.questID)
        end)
      else
        quests = availableQuests
      end
      local numberOfQuests = #quests
      if numberOfQuests >= 1 then
        Array.forEach(quests, function(quest, index)
          if isQuestToBeDone(quest.questID) then
            local questIdentifier
            if Compatibility.isRetail() and GossipFrame:IsShown() then
              questIdentifier = quest.questID
            else
              questIdentifier = quest.index
            end
            Compatibility.Quests.selectAvailableQuest(questIdentifier)
            local wasSuccessful = Events.waitForEvent('QUEST_DETAIL')
            if wasSuccessful then
              AcceptQuest()
              waitForQuestHasBeenAccepted()

              if numberOfQuests >= 3 and index <= numberOfQuests - 2 then
                if GossipFrame:IsShown() then
                  Events.waitForEvent('GOSSIP_SHOW')
                else
                  -- the other frame type

                end
              elseif numberOfQuests >= 2 then
                Events.waitForEvent('QUEST_DETAIL')
              end
            end
          end
        end)
      elseif QuestFrameDetailPanel:IsShown() then
        AcceptQuest()
        waitForQuestHasBeenAccepted()
      end
      _.waitForNPCUpdate()
    else
      registerUnavailableQuests(questGiverPoint.objectID)
    end
  else
    -- Core.calculateDistanceToPosition(savedPosition)
    savedPosition = point
    if Core.calculateDistanceFromCharacterToPosition(point) > Core.RANGE_IN_WHICH_OBJECTS_SEEM_TO_BE_SHOWN then
      Questing.Coroutine.moveTo(point)
      acceptQuests(point)
    end
  end

  return stoppable
end

local function retrieveQuestHandler(questID)
  return questHandlers[questID]
end

local function retrieveQuestHandlerForOneOfQuests(questIDs)
  local questID = Array.find(questIDs, function(questID)
    return questHandlers[questID]
  end)
  if questID then
    return questHandlers[questID]
  else
    return nil
  end
end

local function runQuestHandler(questHandler)
  local object
  object = {
    questID = questHandler.questID,
    isComplete = function(self)
      return Compatibility.QuestLog.isComplete(self.questID)
    end,
    isObjectiveOpen = function(self, objectiveIndex)
      return not Core.isObjectiveComplete(self.questID, objectiveIndex)
    end,
    isObjectiveCompleted = function(self, objectiveIndex)
      return Core.isObjectiveComplete(self.questID, objectiveIndex)
    end
  }
  questHandler.handler(object)
end

local function retrieveQuestName(questID)
  return QuestUtils_GetQuestName(questID)
end

local function retrieveQuestNames(questIDs)
  return Array.map(questIDs, retrieveQuestName)
end

local function convertQuestIDsToQuestNamesString(questIDs)
  local questNames = retrieveQuestNames(questIDs)
  return strjoin(', ', unpack(questNames))
end

local function convertQuestIDsToString(questIDs)
  return strjoin(', ', unpack(questIDs))
end

local activity = nil

local function doPoint(point)
  activity = {
    point = point,
    Cancel = function()
      -- TODO
    end
  }

  AddOn.savedVariables.perCharacter.QuestingPointToShow = nil

  if point.type == 'acceptQuests' then
    local questNamesString
    local questIDsString
    if point.questIDs then
      questNamesString = convertQuestIDsToQuestNamesString(point.questIDs)
      questIDsString = convertQuestIDsToString(point.questIDs)
    else
      questNamesString = ''
      questIDsString = ''
    end
    print('acceptQuests', point.x, point.y, point.z, point.objectID, questIDsString, questNamesString)
    AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
    acceptQuests(point)
  elseif point.type == 'object' then
    local questHandler = retrieveQuestHandlerForOneOfQuests(point.questIDs)
    print('questHandler', questHandler)
    if questHandler then
      runQuestHandler(questHandler)
    else
      AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
      doSomethingWithObject(point)
    end
  elseif point.type == 'endQuest' then
    print('end quest')
    AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
    Questing.Coroutine.interactWithAt(point, point.objectID)
  elseif point.type == 'objectToUseItemOn' then
    print('quest log special item')
    Core.targetUnit(point.pointer)
    if isSpecialItemUsable(point) then
      print('use')
      local distance = Core.retrieveDistanceBetweenObjects('player', point.pointer)
      AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
      Questing.Coroutine.useItemOnNPC(point, point.objectID, point.itemID, distance)
    else
      print('move to')
      AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
      Questing.Coroutine.useItemOnNPC(point, point.objectID, point.itemID)
      waitForSpecialItemUsable(point)
      print('use after wait')
      local name = GetItemInfo(point.itemID)
      Core.castSpellByName(name)
    end
  elseif point.type == 'objectToUseItemOnWhenDead' then
    print('objectToUseItemOnWhenDead')
    if Core.isAlive(point.pointer) then
      AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
      _.doMob(point.pointer)
    end
    Core.targetUnit(point.pointer)
    if isSpecialItemUsable(point) then
      local distance = Core.retrieveDistanceBetweenObjects('player', point.pointer)
      Questing.Coroutine.useItemOnNPC(point, point.objectID, point.itemID, distance)
    else
      Questing.Coroutine.useItemOnNPC(point, point.objectID, point.itemID)
    end
  elseif point.type == 'objectToUseItemAtPosition' then
    print('quest log special item at position')
    AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
    Questing.Coroutine.useItemOnGround(point, point.itemID, 3)
  elseif point.type == 'gossipWith' then
    print('gossip with')
    AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
    Questing.Coroutine.gossipWithAt(point, point.objectID, point.optionToSelect)
  elseif point.type == 'objective' then
    print('objective')
    local firstQuestID = point.questIDs[1]
    local isQuestComplete = Compatibility.QuestLog.isComplete(firstQuestID)
    if isQuestComplete then
      Questing.handleObjective(point)
    else
      local questHandler = retrieveQuestHandlerForOneOfQuests(point.questIDs)
      if questHandler then
        runQuestHandler(questHandler)
      else
        Questing.handleObjective(point)
      end
    end
  elseif point.type == 'loot' then
    AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
    if Questing.Coroutine.lootObject(point.pointer) then
      Set.add(lootedObjects, point.pointer)
    end
  elseif point.type == 'discoverFlightMaster' then
    AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
    Questing.Coroutine.interactWithObject(point.pointer)
  elseif point.type == 'attacker' then
    Questing.Coroutine.doMob(point.pointer)
  else
    print('moveToPoint', point.x, point.y, point.z)
    AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove
    Questing.Coroutine.moveTo(point)
  end
end

function Questing.handleObjective(point)
  local objectID = point.objectID
  local position
  if objectID then
    position = _.retrievePositionFromObjectID(objectID)
  end

  if not position then
    local firstQuestID = point.questIDs[1]
    if firstQuestID then
      C_SuperTrack.SetSuperTrackedQuestID(firstQuestID)
      local frame = C_Navigation.GetFrame()
      if frame and C_Navigation.HasValidScreenPosition() then
        if C_Navigation.WasClampedToScreen() then
          Movement.facePoint(point)
        end

        if C_Navigation.WasClampedToScreen() then
          local lastAngle = nil
          Coroutine.waitFor(function()
            local angle = HWT.ObjectFacing('player')
            local result = lastAngle and angle == lastAngle
            lastAngle = angle
            return result
          end)
          Yielder.yieldAndResume()
          local navigationY = select(2, frame:GetCenter())
          local scale = UIParent:GetEffectiveScale()
          local navigationY = navigationY * scale
          if navigationY >= 0.5 * 768 then
            MoveViewDownStart()
            Coroutine.waitUntil(function()
              return not C_Navigation.WasClampedToScreen()
            end, 2)
            MoveViewDownStop()
          else
            MoveViewUpStart()
            Coroutine.waitUntil(function()
              return not C_Navigation.WasClampedToScreen()
            end, 2)
            MoveViewUpStop()
          end
        end
        position = retrieveNavigationPosition()
      end
    end

    if not position then
      position = Movement.createPoint(point.x, point.y, point.z)
    end

    local continentID = Core.retrieveCurrentContinentID()
    local position2 = Movement.createPositionFromPoint(continentID, position)
    local closesPointOnMeshWithPathTo = _.findClosestPointOnMeshWithPathTo(position2)
    if closesPointOnMeshWithPathTo then
      position = closesPointOnMeshWithPathTo
    end
  end

  Object.assign(point, position)

  AddOn.savedVariables.perCharacter.QuestingPointToMove = point
  AddOn.savedVariables.perCharacter.QuestingPointToShow = AddOn.savedVariables.perCharacter.QuestingPointToMove

  Questing.Coroutine.moveTo(point, {
    additionalStopConditions = function()
      if objectID then
        local object = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)
        if object and Core.calculateDistanceFromCharacterToObject(object) <= INTERACT_DISTANCE then
          return true
        end
      end

      return false
    end
  })

  local pointer = point.pointer
  if not pointer and objectID then
    pointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)
  end
  if pointer then
    Questing.Coroutine.interactWithObject(pointer)

    if MerchantFrame:IsShown() then
      local questID = point.questIDs[1]
      local objectiveName = _.retrieveObjectiveNameForQuestAndQuestObject(pointer, questID)
      if objectiveName then
        local index = _.findMerchantItemWithName(objectiveName)
        if index then
          local price = select(3, GetMerchantItemInfo(index))
          if price <= GetMoney() then
            BuyMerchantItem(index, 1)
          end
        end
      end
      CloseMerchant()
    end
  end

  if Core.isCharacterCloseToPosition(point, INTERACT_DISTANCE) then
    recentlyVisitedObjectivePoints[Movement.createPoint(point.x, point.y, point.z)] = {
      time = GetTime()
    }
  end
end

function _.findMerchantItemWithName(name)
  for index = 1, GetMerchantNumItems() do
    local itemName = GetMerchantItemInfo(index)
    if itemName == name then
      return index
    end
  end
  return nil
end

function _.retrieveObjectiveNameForQuestAndQuestObject(object, questID)
  local questObjectiveName
  local tooltip = C_TooltipInfo.GetUnit(object)
  if tooltip then
    questObjectiveName = _.extractQuestObjectiveNameForQuestFromTooltip(tooltip, questID)
  else
    questObjectiveName = nil
  end
  return questObjectiveName
end

function _.extractQuestObjectiveNameForQuestFromTooltip(tooltip, questID)
  local lines = tooltip.lines
  local questTitleLineIndex = Array.findIndex(lines, function(line)
    TooltipUtil.SurfaceArgs(line)
    return line.type == 17 and line.id == questID
  end)
  print('questTitleLineIndex', questTitleLineIndex)
  if questTitleLineIndex ~= -1 then
    local questObjectiveLineIndex = questTitleLineIndex + 1
    if questObjectiveLineIndex <= #lines then
      local questObjectiveLine = lines[questObjectiveLineIndex]
      TooltipUtil.SurfaceArgs(questObjectiveLine)
      if questObjectiveLine.type == 8 then
        local text = questObjectiveLine.leftText
        local objectiveName = string.match(text, '%d+/%d+ (.+)')
        return objectiveName
      end
    end
  end

  return nil
end

function _.findClosestPointOnMeshWithPathTo(position)
  local continentID = select(8, GetInstanceInfo())
  local previousClosesPointOnMesh = nil
  local closestPointOnMesh = Movement.retrieveClosestPointOnMesh(position)
  while closestPointOnMesh and not (previousClosesPointOnMesh and closestPointOnMesh == previousClosesPointOnMesh) do
    if Core.doesPathExistFromCharacterTo(closestPointOnMesh) then
      return closestPointOnMesh
    else
      local point = Core.traceLineCollision(
        Movement.createPointWithZOffset(closestPointOnMesh, 0.1),
        Movement.createPointWithZOffset(closestPointOnMesh, Movement.MAXIMUM_AIR_HEIGHT)
      )
      previousClosesPointOnMesh = closestPointOnMesh
      if point then
        local point2 = Core.traceLineCollision(
          Movement.createPointWithZOffset(point, 0.1),
          Movement.createPointWithZOffset(point, -0.1)
        )
        closestPointOnMesh = Movement.retrieveClosestPointOnMesh(Movement.createPositionFromPoint(continentID,
          point2))
      else
        closestPointOnMesh = nil
      end
    end
  end

  return closestPointOnMesh
end

function _.retrievePositionFromObjectID(objectID)
  local object = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)
  if object then
    return Core.retrieveObjectPosition(object)
  else
    return nil
  end
end

HWT.doWhenHWTIsLoaded(function()
  AddOn.savedVariables = SavedVariables.loadSavedVariablesOfAddOn(addOnName)
  Questing.savedVariables = AddOn.savedVariables

  SavedVariables.registerSavedVariablesPerCharacter(
    addOnName,
    AddOn.savedVariables.perCharacter
  )

  _.initializeSavedVariables()

  Draw.Sync(function()
    if AddOn.savedVariables.perCharacter.QuestingPointToShow then
      Draw.SetColorRaw(0, 1, 0, 1)
      Draw.Circle(AddOn.savedVariables.perCharacter.QuestingPointToShow.x,
        AddOn.savedVariables.perCharacter.QuestingPointToShow.y,
        AddOn.savedVariables.perCharacter.QuestingPointToShow.z, INTERACT_DISTANCE)
    end

    if point then
      Draw.SetColorRaw(0, 1, 0, 1)
      local playerPosition = Movement.retrieveCharacterPosition()
      Draw.Line(playerPosition.x, playerPosition.y, playerPosition.z, point.x, point.y, point.z)
      Draw.Circle(point.x, point.y, point.z, 0.75)
    end
  end)
end)

local previousPointsToGo = { nil, nil }

function seemToBeSamePoints(a, b)
  if a.pointer and b.pointer then
    return a.pointer == b.pointer
  else
    return a.x == b.x and a.y == b.y and a.z == b.z
  end
end

function retrievePoints()
  local yielder = Yielder.createYielderWithTimeTracking(1 / 60)

  local attackerPoints = retrieveAttackerPoints()
  if yielder.hasRanOutOfTime() then
    yielder.yield()
  end
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
  local lootPoints
  if Core.isCharacterInCombat() then
    lootPoints = {}
  else
    lootPoints = retrieveLootPoints()
    if yielder.hasRanOutOfTime() then
      yielder.yield()
    end
  end
  local points = {
    attackerPoints = attackerPoints,
    questStartPoints = questStartPoints,
    objectivePoints = objectivePoints,
    objectPoints = objectPoints,
    explorationPoints = {}, -- explorationPoints
    lootPoints = lootPoints,
    discoverFlightMasterPoints = retrieveFlightMasterDiscoveryPoints()
  }

  local continentID = select(8, GetInstanceInfo())
  for key, value in pairs(points) do
    points[key] = Array.filter(value, function(point)
      return (
        point.continentID == continentID and
          -- A B A
          (not previousPointsToGo[2] or not seemToBeSamePoints(point, previousPointsToGo[2])) and
          (not point.questIDs or Array.isEmpty(point.questIDs) or Array.any(point.questIDs, isQuestToBeDone))
      )
    end)
  end

  return points
end

function moveToClosestPoint()
  local points = retrievePoints()
  local pointToGo = determinePointToGo(points)
  if pointToGo then
    if previousPointsToGo[1] == nil or not seemToBeSamePoints(pointToGo, previousPointsToGo[1]) then
      previousPointsToGo[2] = previousPointsToGo[1]
      previousPointsToGo[1] = pointToGo
    end

    AddOn.savedVariables.perCharacter.QuestingPointToMove = pointToGo
    if activity then
      activity:Cancel()
    end
    activity = doPoint(pointToGo)
  else
    if not isPlayerOnMeshPoint() then
      local continentID = select(8, GetInstanceInfo())
      local playerPosition = Core.retrieveCharacterPosition()
      local to = Core.retrieveClosestPositionOnMesh(playerPosition)
      pathFinder = Movement.createPathFinder()
      local path = pathFinder.start(playerPosition, to)
      if path then
        AddOn.savedVariables.perCharacter.QuestingPointToMove = path[#path]
        print('m1')
        if activity then
          activity:Cancel()
        end
        activity = Movement.movePath(path)
        print('m2')
      end
    end
  end
end

function waitForGossipDialog()
  Events.waitForEvent('GOSSIP_SHOW', 2)
end

function waitForPlayerFacingObject(object)
  return Coroutine.waitFor(function()
    return Movement.isCharacterFacingObject(object)
  end, 5)
end

function waitForSoftInteract()
  return Coroutine.waitFor(function()
    return Core.retrieveObjectPointer('softinteract')
  end, 2)
end

function waitForSoftInteractNamePlate()
  return Coroutine.waitFor(function()
    return C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  end, 2)
end

function isFriendly(object)
  local reaction = Core.unitReaction(object, 'player')
  return reaction and reaction >= 4 and not Core.canUnitAttackOtherUnit('player', object)
end

function isEnemy(object)
  local reaction = Core.unitReaction(object, 'player')
  return reaction and reaction <= 3
end

local isRunning = false

function Questing.isRunning()
  return isRunning
end

function Questing.start()
  if not Questing.isRunning() then
    print('Starting questing...')
    isRunning = true

    Coroutine.runAsCoroutine(_.run)
  end
end

function Questing.stop()
  if Questing.isRunning() then
    print('Stopping questing...')
    isRunning = false
  end
end

function Questing.toggle()
  if isRunning then
    Questing.stop()
  else
    Questing.start()
  end
end

function isIdle()
  return (
    not Core.isCharacterDrinking() and
      not Core.isCharacterEating() and
      (not _G.isPathFinding or not isPathFinding())
  )
end

function determineNumberOfFreeInventorySlots()
  local numberOfFreeSlots = 0
  for containerIndex = 0, NUM_BAG_SLOTS do
    numberOfFreeSlots = numberOfFreeSlots + Compatibility.Container.receiveNumberOfFreeSlotsInContainer(containerIndex)
  end
  return numberOfFreeSlots
end

function hasEnoughFreeSlotsToCompleteQuestGiverQuest()
  return _.hasEnoughFreSlotsForRewards(GetNumQuestRewards(), GetNumQuestChoices())
end

function _.hasEnoughFreeSlotsToCompleteQuest(questID)
  return _.hasEnoughFreSlotsForRewards(GetNumQuestLogRewards(questID), GetNumQuestLogChoices(questID))
end

function _.hasEnoughFreSlotsForRewards(numberOfRewards, numberOfChoices)
  local numberOfItemsAddedToBag = numberOfRewards
  if numberOfChoices >= 1 then
    numberOfItemsAddedToBag = numberOfItemsAddedToBag + 1
  end
  local numberOfFreeInventorySlots = determineNumberOfFreeInventorySlots()
  return numberOfItemsAddedToBag <= numberOfFreeInventorySlots
end

function Questing.areBagsFull()
  return determineNumberOfFreeInventorySlots() == 0
end

function waitForQuestHasBeenAccepted()
  return Events.waitForEvent('QUEST_ACCEPTED')
end

function isAnyActiveQuestCompletable()
  return _.findFirstCompleteActiveQuest() ~= nil
end

function _.findFirstCompleteActiveQuest()
  for index = 1, GetNumActiveQuests() do
    if Compatibility.isRetail() then
      local questID = GetActiveQuestID(index)
      if Compatibility.QuestLog.isComplete(questID) then
        return index
      end
    else
      local isComplete = select(2, GetActiveTitle(index))
      if isComplete then
        return index
      end
    end
  end

  return nil
end

function isAnyActiveQuestCompletable2()
  local activeQuests = Compatibility.GossipInfo.retrieveActiveQuests()
  return Array.any(activeQuests, function(quest)
    return Compatibility.QuestLog.isComplete(quest.questID)
  end)
end

function registerUnavailableQuests(npcID)
  local questsThatShouldBeAvailableFromNPC = Questing.Database.retrieveQuestsThatShouldBeAvailableFromNPC(npcID)
  local objectPointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(npcID)
  local availableQuestsSet
  if objectPointer and Core.retrieveObjectPointer('npc') == objectPointer then
    local availableQuests = Compatibility.Quests.retrieveAvailableQuests()
    local retrieveQuestIdentifier
    if Compatibility.isRetail() then
      retrieveQuestIdentifier = function(quest)
        return quest.questID
      end
    else
      retrieveQuestIdentifier = function(quest)
        return quest.name
      end
    end
    availableQuestsSet = Set.create(Array.map(availableQuests, retrieveQuestIdentifier))
  else
    availableQuestsSet = Set.create()
  end
  local retrieveIdentifierFromQuestingQuest
  if Compatibility.isRetail() then
    retrieveIdentifierFromQuestingQuest = function(quest)
      return quest.id
    end
  else
    retrieveIdentifierFromQuestingQuest = function(quest)
      return quest.name
    end
  end
  Array.forEach(questsThatShouldBeAvailableFromNPC, function(quest)
    if not Set.contains(availableQuestsSet, retrieveIdentifierFromQuestingQuest(quest)) then
      unavailableQuestIDs[quest.id] = true
    end
  end)
end

function _.isClosestPointDifferentThanCurrentActivityPoint(closestPoint)
  return not activity or activity.point.pointer ~= closestPoint.pointer
end

function _.run ()
  local regularChecksTicker = C_Timer.NewTicker(0, function()
    Coroutine.runAsCoroutine(function()
      if not Questing.isRunning() then
        Movement.stopPathFindingAndMoving()
      end

      if Questing.isRunning() then
        local points = retrieveDynamicPoints()
        local closestPoint = determineClosestPoint(points)
        if closestPoint and _.isClosestPointDifferentThanCurrentActivityPoint(closestPoint) then
          if activity then
            activity:Cancel()
          end
          doPoint(closestPoint)
        end
      end
    end)
  end)

  local yielder = Yielder.createYielder()

  while true do
    _.talents()

    local time = GetTime()
    for key, value in pairs(recentlyVisitedObjectivePoints) do
      if time - value.time > 60 then
        recentlyVisitedObjectivePoints[key] = nil
      end
    end

    if Questing.isRunning() and Core.isCharacterInCombat() and not Core.isCharacterAttacking() then
      local pointer = Core.receiveUnitsThatAttackTheCharacter()[1] -- TODO: Improve targeting (i.e. the one that can go down fastes when targeted, the one which can relatively go done fast when targeted and does a lot of damage (lowest HP first, squishiest first))
      if pointer then
        local point = Core.retrieveObjectPosition(pointer)
        local name = Core.retrieveObjectName(pointer)
        print('doMob', name)
        Movement.stopPathFindingAndMoving()
        _.doMob(pointer)
      end
    end
    if Questing.isRunning() and isIdle() then
      AddOn.savedVariables.perCharacter.QuestingPointToMove = nil

      local quests = retrieveQuestLogQuests()
      local autoCompleteQuests = Array.filter(quests, function(quest)
        return quest.isAutoComplete and Compatibility.QuestLog.isComplete(quest.questID)
      end)
      Array.forEach(autoCompleteQuests, _.completeAutoCompleteQuest)

      local questIDs = retrieveQuestLogQuestIDs()
      Array.forEach(questIDs, function(questID)
        if Compatibility.QuestLog.isFailed(questID) then
          Core.abandonQuest(questID)
        end
      end)

      if Compatibility.isRetail() then
        for index = 1, GetNumAutoQuestPopUps() do
          local questID, popUpType = GetAutoQuestPopUp(index)

          if popUpType == 'OFFER' and not Compatibility.QuestLog.isOnQuest(questID) then
            ShowQuestOffer(questID)
            AutoQuestPopupTracker_RemovePopUp(questID)
            Events.waitForEvent('QUEST_DETAIL')
            AcceptQuest()
            waitForQuestHasBeenAccepted()
          end
        end
      end

      local npcID = HWT.ObjectId('npc')
      if npcID then
        registerUnavailableQuests(npcID)
      end

      if Core.isCharacterGhost() then
        local corpsePosition = Movement.createPoint(Core.receiveCorpsePosition())
        Questing.Coroutine.moveToUntil(corpsePosition, {
          stopCondition = function()
            return StaticPopup1Button1:IsShown()
          end
        })
        StaticPopup1Button1:Click()
      elseif Questing.canLearnRiding() then
        Questing.learnRiding()
      elseif _.itSeemsMakeSenseToSell() then
        print('Selling...')
        _.sell()
      else
        moveToClosestPoint()
      end
    end

    if not Questing.isRunning() then
      regularChecksTicker:Cancel()
      Movement.stopPathFindingAndMoving()
      return
    end

    yielder.yield()
  end
end

function _.completeAutoCompleteQuest(questID)
  ShowQuestComplete(questID)
  AutoQuestPopupTracker_RemovePopUp(questID)
  _.completeQuest()
end

function _.itSeemsMakeSenseToSell()
  return Questing.areBagsFull() and _.isSellVendorSet()
end

function _.isSellVendorSet()
  return Boolean.toBoolean(Questing.closestNPCs.Sell)
end

function _.sell()
  local sellNPC = Questing.closestNPCs.Sell
  Questing.Coroutine.gossipWithAt(sellNPC, sellNPC.objectID)
  if MerchantFrame:IsShown() then
    _.sellItemsAtVendor()
  else
    if _.hasSellingGossipOption() then
      _.selectSellingGossipOption()
    end
    local wasSuccessful = Events.waitForEvent('MERCHANT_SHOW', 2)
    if wasSuccessful then
      _.sellItemsAtVendor()
    end
  end
  CloseMerchant()
end

function _.hasSellingGossipOption()
  return Boolean.toBoolean(_.retrieveSellingGossipOption())
end

function _.isSellingGossipOption(option)
  return option.icon == 132060
end

function _.selectSellingGossipOption()
  local option = _.retrieveSellingGossipOption()
  if option then
    Compatibility.GossipInfo.selectOption(option.gossipOptionID)
  end
end

function _.retrieveSellingGossipOption()
  local options = Compatibility.GossipInfo.retrieveOptions()
  return Array.find(options, _.isSellingGossipOption)
end

function _.sellItemsAtVendor()
  print('_.sellItemsAtVendor()')
  for containerIndex = 0, NUM_BAG_SLOTS do
    for slotIndex = 1, Compatibility.Container.receiveNumberOfSlotsOfContainer(containerIndex) do
      local itemInfo = Compatibility.Container.retrieveItemInfo(containerIndex, slotIndex)
      local classID = select(6, GetItemInfoInstant(itemInfo.itemID))
      if itemInfo and (
        itemInfo.quality == Enum.ItemQuality.Poor or
          (itemInfo.quality == Enum.ItemQuality.Common and (classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor)) or
          (AddOn.savedVariables.perCharacter.QuestingOptions.sellUncommon and itemInfo.quality == Enum.ItemQuality.Uncommon) or
          (AddOn.savedVariables.perCharacter.QuestingOptions.sellRare and itemInfo.quality == Enum.ItemQuality.Rare)
      ) then
        Compatibility.Container.UseContainerItem(containerIndex, slotIndex)
        Events.waitForEvent('BAG_UPDATE_DELAYED')
      end
    end
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

function _.initializeSavedVariables()
  if exploredObjects == nil then
    -- objectID to flags
    exploredObjects = {}
  end

  if AddOn.savedVariables.perCharacter.QuestingOptions == nil then
    AddOn.savedVariables.perCharacter.QuestingOptions = {}
  end
end

local function onQuestTurnedIn()
  objectIDsOfObjectsWhichCurrentlySeemAbsent = Set.create()
end

local function onEvent(self, event, ...)
  if event == 'QUEST_TURNED_IN' then
    onQuestTurnedIn(...)
  elseif event == 'GOSSIP_SHOW' then
    print('GOSSIP_SHOW')
  elseif event == 'QUEST_ACCEPTED' then
    print('QUEST_ACCEPTED')
  elseif event == 'QUEST_ACCEPT_CONFIRM' then
    print('QUEST_ACCEPT_CONFIRM', Unlocker.retrieveQuestGiverStatus('target'))
  elseif event == 'QUEST_LOG_CRITERIA_UPDATE' then
    print('QUEST_LOG_CRITERIA_UPDATE', Unlocker.retrieveQuestGiverStatus('target'))
  elseif event == 'QUEST_DETAIL' then
    print('QUEST_DETAIL')
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('QUEST_TURNED_IN')
frame:RegisterEvent('GOSSIP_SHOW')
frame:RegisterEvent('QUEST_ACCEPTED')
frame:RegisterEvent('QUEST_ACCEPT_CONFIRM')
if Compatibility.isRetail() then
  frame:RegisterEvent('QUEST_LOG_CRITERIA_UPDATE')
end
frame:RegisterEvent('QUEST_DETAIL')
frame:SetScript('OnEvent', onEvent)

Questing.convertMapPositionToWorldPosition = convertMapPositionToWorldPosition

function testHandleObjective()
  local continentID = Movement.retrieveContinentID()
  local mapID, mapPosition = C_Map.GetMapPosFromWorldPos(continentID, savedPosition)
  local continentID, position = retrieveWorldPositionFromMapPosition(mapID, mapPosition.x, mapPosition.y)
  local point = {
    x = position.x,
    y = position.y,
    z = position.z,
    questIDs = {}
  }
  return Questing.handleObjective(point)
end

function _.talents()
  if not Core.isCharacterInCombat and C_ClassTalents.GetNextStarterBuildPurchase() then
    ClassTalentFrame.TalentsTab:LoadConfigInternal(Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID, true, true)
  end
end
