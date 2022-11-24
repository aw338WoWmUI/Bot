local addOnName, AddOn = ...

--function selectCloseQuests(quests)
--  local playerPosition = Core.retrieveCharacterPosition()
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

---@type QuestieTooltips
local QuestieTooltips = QuestieLoader:ImportModule('QuestieTooltips')

function AddOn.retrieveQuestieTooltip(object)
  local key
  if Core.isUnit(object) then
    key = 'm'
  elseif Core.isGameObject(object) then
    key = 'o'
  elseif Core.isItem(object) then
    key = 'i'
  end
  if key then
    key = key .. '_' .. HWT.ObjectId(object)
    return QuestieTooltips.lookupByKey[key]
  else
    return nil
  end
end
