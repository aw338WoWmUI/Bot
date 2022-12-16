local addOnName, AddOn = ...
local _ = {}

local questGiverStatuses = Set.create({
  Unlocker.QuestGiverStatuses.DailyQuest,
  Unlocker.QuestGiverStatuses.Quest
})

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

function AddOn.retrieveQuestStartPoints()
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

  points = Array.filter(points, function(point)
    return Array.any(point.questIDs, QuestsToAccept.isQuestToAccept)
  end)

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
      return _.generateQuestStartPointsFromStarters(quest)
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
          return _.generateQuestStartPointsFromStarters(quest)
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

function _.generateQuestStartPointsFromStarters(quest)
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
