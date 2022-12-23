Compatibility = Compatibility or {}
Compatibility.TaskQuest = {}
local _ = {}

function Compatibility.TaskQuest.retrieveQuestsOnMap(mapID)
  return Array.map(C_TaskQuest.GetQuestsForPlayerByMapID(mapID), _.normalizeQuest)
end

function _.normalizeQuest(quest)
  quest.questID = quest.questId
  quest.questId = nil
  return quest
end
