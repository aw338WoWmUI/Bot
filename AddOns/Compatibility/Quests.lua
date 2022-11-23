Compatibility = Compatibility or {}
Compatibility.Quests = {}

local _ = {}

function Compatibility.Quests.retrieveAvailableQuests()
  if GossipFrame:IsShown() then
    local availableQuests = Compatibility.GossipInfo.retrieveAvailableQuests()
    Array.forEach(availableQuests, function(quest, index)
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

function Compatibility.Quests.selectAvailableQuest(questIdentifier)
  if GossipFrame:IsShown() then
    Compatibility.GossipInfo.selectAvailableQuest(questIdentifier)
  elseif QuestFrame:IsShown() then
    SelectAvailableQuest(questIdentifier)
  end
end

function Compatibility.Quests.retrieveActiveQuests()
  if GossipFrame:IsShown() then
    local activeQuests = Compatibility.GossipInfo.retrieveActiveQuests()
    Array.forEach(activeQuests, function(quest, index)
      quest.index = index
    end)
    return activeQuests
  else
    local numberOfActiveQuests = GetNumActiveQuests()
    local activeQuests = {}
    if _G.GetActiveQuestID then
      for index = 1, numberOfActiveQuests do
        local questID = GetActiveQuestID(index)
        local availableQuest = {
          index = index,
          title = QuestUtils_GetQuestName(questID),
          questLevel = GetAvailableLevel(index),
          isComplete = Compatibility.QuestLog.isComplete(questID),
          questID = questID
        }
        table.insert(activeQuests, availableQuest)
      end
    else
      local titleToQuest = _.retrieveTitleToQuestLookup()
      for index = 1, numberOfActiveQuests do
        local title, isComplete = GetActiveTitle(index)
        local info = titleToQuest[title]
        local availableQuest = {
          index = index,
          title = title,
          questLevel = info.level,
          isComplete = isComplete,
          questID = info.questID
        }
        table.insert(activeQuests, availableQuest)
      end
    end
    return activeQuests
  end
end

function _.retrieveTitleToQuestLookup()
  local titleToQuest = {}
  for index = 1, Compatibility.QuestLog.retrieveNumberOfQuestLogEntries() do
    local info = Compatibility.QuestLog.retrieveInfo(index)
    if info.questID then
      titleToQuest[info.title] = info
    end
  end
  return titleToQuest
end

function Compatibility.Quests.selectActiveQuest(questIdentifier)
  if GossipFrame:IsShown() then
    Compatibility.GossipInfo.selectActiveQuest(questIdentifier)
  elseif QuestFrame:IsShown() then
    SelectActiveQuest(questIdentifier)
  end
end
