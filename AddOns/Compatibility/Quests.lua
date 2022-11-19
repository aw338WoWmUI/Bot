Compatibility = Compatibility or {}
Compatibility.Quests = {}

function Compatibility.Quests.retrieveAvailableQuests()
  if GossipFrame:IsShown() then
    local availableQuests = Compatibility.GossipInfo.retrieveAvailableQuests()
    Array.forEach(availableQuests, function (quest, index)
      quest.index = index
    end)
    return availableQuests
  else
    local numberOfAvailableQuests = GetNumAvailableQuests()
    local availableQuests = {}
    if _G.GetAvailableQuestInfo then
      for index = 1, numberOfAvailableQuests do
        local isTrivial, frequency, repeatable, isLegendary, questID = GetAvailableQuestInfo(index)
        local availableQuest = {
          index = index,
          title = QuestUtils_GetQuestName(questID),
          questLevel = GetAvailableLevel(index),
          isTrivial = isTrivial,
          frequency = frequency,
          repeatable = repeatable,
          isComplete = false,
          isLegendary = isLegendary,
          isIgnored = nil,
          questID = questID
        }
        table.insert(availableQuests, availableQuest)
      end
    else
      for index = 1, numberOfAvailableQuests do
        local title = GetAvailableTitle(index)
        local availableQuest = {
          index = index,
          title = title,
          questLevel = nil,
          isTrivial = nil,
          frequency = nil,
          repeatable = nil,
          isComplete = false,
          isLegendary = nil,
          isIgnored = nil,
          questID = nil
        }
        table.insert(availableQuests, availableQuest)
      end
    end
    return availableQuests
  end
end
