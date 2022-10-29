local function onGossipShow()
  print('onGossipShow')
  local questID = GMR.GetQuestId()
  if questID then
    local availableQuests = C_GossipInfo.GetAvailableQuests()
    local availableQuest = Array.find(availableQuests, function(quest)
      return quest.questID == questID
    end)
    if availableQuest then
      C_GossipInfo.SelectAvailableQuest(availableQuest.questID)
    else
      local activeQuests = C_GossipInfo.GetActiveQuests()
      local activeQuest = Array.find(activeQuests, function(quest)
        return quest.questID == questID
      end)
      if activeQuest then
        C_GossipInfo.SelectActiveQuest(activeQuest.questID)
      end
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
