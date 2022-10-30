hooksecurefunc(C_GossipInfo, 'SelectActiveQuest', function (value)
  local activeQuests = C_GossipInfo.GetActiveQuests()
  if value >= 1 and value <= #activeQuests then
    local activeQuest = activeQuests[value]
    C_GossipInfo.SelectActiveQuest(activeQuest.questID)
  end
end)
