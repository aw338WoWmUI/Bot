local addOnName, AddOn = ...

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
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule('QuestieJourney')

function findQuests()
  local result = {}

  local zoneId = QuestiePlayer:GetCurrentZoneId()
  local quests = QuestieDB:GetQuestsByZoneId(zoneId)

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
        elseif not GMR.IsQuestActive(questID) then
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

function AddOn.retrieveQuestStartPoints()
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
