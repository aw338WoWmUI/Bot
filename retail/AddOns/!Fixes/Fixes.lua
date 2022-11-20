C_GossipInfo.GetNumOptions = function()
  return #C_GossipInfo.GetOptions()
end

GetNumGossipOptions = C_GossipInfo.GetNumOptions

local selectOption = C_GossipInfo.SelectOption
C_GossipInfo.SelectOption = function(value, ...)
  local options = C_GossipInfo.GetOptions()
  if value >= 1 and value <= #options then
    local option = options[value]
    return selectOption(option.gossipOptionID, ...)
  else
    return selectOption(value, ...)
  end
end

SelectGossipOption = C_GossipInfo.SelectOption

local function isMassQuestId(questID)
  local thread = coroutine.create(function()
    return GMR.IsMassQuestId(questID)
  end)
  local wasSuccessful, result = coroutine.resume(thread)
  if wasSuccessful then
    return result
  else
    return false
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

function GetNumQuestLogEntries()
  return C_QuestLog.GetNumQuestLogEntries()
end

function GetQuestLogTitle(index)
  local info = C_QuestLog.GetInfo(index)
  local isComplete = C_QuestLog.IsComplete(info.questID)
  return info.title, info.level, info.suggestedGroup, info.isHeader, info.isCollapsed, isComplete, info.frequency, info.questID, info.startEvent, nil, info.isOnMap, info.hasLocalPOI, info.isTask, info.isBounty, info.isStory, info.isHidden, info.isScaling
end

function SelectQuestLogEntry(index)
  local info = C_QuestLog.GetInfo(index)
  if info and info.questID then
    return C_QuestLog.SetSelectedQuest(info.questID)
  end
end

function SetAbandonQuest()
  return C_QuestLog.SetAbandonQuest()
end

function AbandonQuest()
  return C_QuestLog.AbandonQuest()
end

function GetContainerNumSlots(containerIndex)
  return C_Container.GetContainerNumSlots(containerIndex)
end

function GetContainerNumFreeSlots(containerIndex)
  return C_Container.GetContainerNumFreeSlots(containerIndex)
end

local function selectFirstGossipOption()
  local options = C_GossipInfo.GetOptions()
  local option = options[1]
  if option then
    C_GossipInfo.SelectOption(option.gossipOptionID)
  end
end

MerchantNameText = {
  GetText = function ()
    return GMR.ObjectName('npc')
  end
}

doWhenGMRIsFullyLoaded(function ()
  local gossipWith = GMR.Questing.GossipWith
  GMR.Questing.GossipWith = function (...)
    local result = {gossipWith(...)}
    local args = {...}
    if (
      Array.length(args) == 1 or -- call with just an NPC reference
        not args[7] -- call with gossip option omitted
    ) then
      selectFirstGossipOption()
    end
    return unpack(result)
  end
end)
