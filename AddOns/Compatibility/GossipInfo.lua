Compatibility = Compatibility or {}
Compatibility.GossipInfo = {}

function Compatibility.GossipInfo.retrieveAvailableQuests()
  if C_GossipInfo.GetAvailableQuests then
    return C_GossipInfo.GetAvailableQuests()
  else
    local availableQuests = {}
    local data = { GetGossipAvailableQuests()}
    local numberOfFields = 7
    for index = 1, #data, numberOfFields do
      local availableQuest = {
        index = math.ceil(index / numberOfFields),
        title = data[index],
        questLevel = data[index + 1],
        isTrivial = data[index + 2],
        frequence = data[index + 3],
        repeatable = data[index + 4],
        isComplete = false,
        isLegendary = data[index + 5],
        isIgnored = data[index + 6],
        questID = nil
      }
      table.insert(availableQuests, availableQuest)
    end
    return availableQuests
  end
end

function Compatibility.GossipInfo.retrieveActiveQuests()
  if C_GossipInfo.GetActiveQuests then
    return C_GossipInfo.GetActiveQuests()
  else
    local activeQuests = {}
    local data = { GetGossipActiveQuests() }
    local numberOfFields = 6
    for index = 1, #data, numberOfFields do
      local activeQuest = {
        index = math.ceil(index / numberOfFields),
        title = data[index],
        questLevel = data[index + 1],
        isTrivial = data[index + 2],
        frequence = nil,
        repeatable = nil,
        isComplete = data[index + 3],
        isLegendary = data[index + 4],
        isIgnored = data[index + 5],
        questID = nil
      }
      table.insert(activeQuests, activeQuest)
    end
    return activeQuests
  end
end

function Compatibility.GossipInfo.selectAvailableQuest(questIdentifier)
  if C_GossipInfo.SelectAvailableQuest then
    return C_GossipInfo.SelectAvailableQuest(questIdentifier)
  else
    return SelectGossipAvailableQuest(questIdentifier)
  end
end

function Compatibility.GossipInfo.hasGossipOptions()
  if _G.GetNumGossipOptions then
    return GetNumGossipOptions() >= 1
  else
    return Array.hasElements(C_GossipInfo.GetOptions())
  end
end

function Compatibility.GossipInfo.retrieveOptions()
  -- TODO: Compatibility for WotLK and Vanilla
  return C_GossipInfo.GetOptions()
end

function Compatibility.GossipInfo.hasAvailableQuests()
  local numberOfAvailableQuests
  if C_GossipInfo.GetNumAvailableQuests then
    numberOfAvailableQuests = C_GossipInfo.GetNumAvailableQuests()
  else
    numberOfAvailableQuests = GetNumGossipAvailableQuests()
  end
  return numberOfAvailableQuests >= 1
end

function Compatibility.GossipInfo.selectActiveQuest(questIdentifier)
  if C_GossipInfo.SelectActiveQuest then
    return C_GossipInfo.SelectActiveQuest(questIdentifier)
  else
    return SelectGossipActiveQuest(questIdentifier)
  end
end

function Compatibility.GossipInfo.selectOption(gossipOptionID)
  -- TODO: Compatibility for WotLK and Vanilla
  return C_GossipInfo.SelectOption(gossipOptionID)
end
