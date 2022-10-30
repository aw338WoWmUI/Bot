C_GossipInfo.GetNumOptions = function ()
  return #C_GossipInfo.GetOptions()
end

local selectOption = C_GossipInfo.SelectOption
C_GossipInfo.SelectOption = function (value, ...)
  local options = C_GossipInfo.GetOptions()
  if value >= 1 and value <= #options then
    local option = options[value]
    return selectOption(option.gossipOptionID, ...)
  else
    return selectOption(value, ...)
  end
end

local function isMassQuestId(questID)
  local thread = coroutine.create(function ()
    return GMR.IsMassQuestId(questID)
  end)
  local hadError, result = coroutine.resume(thread)
  if hadError then
    return false
  else
    return result
  end
end

local function onGossipShow()
  local questID = GMR.GetQuestId()

  local function isOneOfTheQuests(quest)
    return (questID and quest.questID == questID) or isMassQuestId(quest.questID)
  end

  local availableQuests = C_GossipInfo.GetAvailableQuests()
  local availableQuest = Array.find(availableQuests, isOneOfTheQuests)
  if availableQuest then
    C_GossipInfo.SelectAvailableQuest(availableQuest.questID)
  else
    local activeQuests = C_GossipInfo.GetActiveQuests()
    local activeQuest = Array.find(activeQuests, isOneOfTheQuests)
    if activeQuest then
      C_GossipInfo.SelectActiveQuest(activeQuest.questID)
    end
  end
end

local function onEvent(self, event, ...)
  if event == 'GOSSIP_SHOW' then
    onGossipShow(...)
  end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', onEvent)
frame:RegisterEvent('GOSSIP_SHOW')
