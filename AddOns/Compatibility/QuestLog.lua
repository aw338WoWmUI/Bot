Compatibility = Compatibility or {}
Compatibility.QuestLog = {}

function Compatibility.QuestLog.retrieveInfo(index)
  if C_QuestLog.GetInfo then
    return C_QuestLog.GetInfo(index)
  else
    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden, isScaling = GetQuestLogTitle(index)
    return {
      title = title,
      questLogIndex = nil,
      questID = questID,
      campaignID = nil,
      level = level,
      difficultyLevel = nil,
      suggestedGroup = suggestedGroup,
      frequency = frequency,
      isHeader = isHeader,
      isCollapsed = isCollapsed,
      startEvent = startEvent,
      isTask = isTask,
      isBounty = isBounty,
      isStory = isStory,
      isScaling = isScaling,
      isOnMap = isOnMap,
      hasLocalPOI = hasLocalPOI,
      isHidden = isHidden,
      isAutoComplete = nil,
      overrideSortOrder = nil,
      readyForTranslation = nil
    }
  end
end

function Compatibility.QuestLog.isFailed(questID)
  if C_QuestLog.IsFailed then
    return C_QuestLog.IsFailed(questID)
  else
    local index = Compatibility.QuestLog.retrieveIndexForQuestID(questID)
    local isComplete = select(6, GetQuestLogTitle(index))
    return isComplete == -1
  end
end

function Compatibility.QuestLog.retrieveNumberOfQuestLogEntries()
  if C_QuestLog.GetNumQuestLogEntries then
    return C_QuestLog.GetNumQuestLogEntries()
  else
    return GetNumQuestLogEntries()
  end
end

function Compatibility.QuestLog.retrieveIndexForQuestID(questID)
  if C_QuestLog.GetLogIndexForQuestID then
    return C_QuestLog.GetLogIndexForQuestID(questID)
  else
    return GetQuestLogIndexByID(questID)
  end
end

function Compatibility.QuestLog.retrieveNumberOfQuestLogEntries()
  if C_QuestLog.GetNumQuestLogEntries then
    return C_QuestLog.GetNumQuestLogEntries()
  else
    return GetNumQuestLogEntries()
  end
end