ObjectQuests = ObjectQuests or {}
local addOnName, AddOn = ...
local _ = {}

function ObjectQuests.ObjectIsQuestObjective(object)
  if Compatibility.isRetail() then
    Unlocker.ObjectIsQuestObjective(object)
  else
    local objectID = HWT.ObjectId(object)
    ---@type QuestieDB
    local QuestieDB = QuestieLoader:ImportModule('QuestieDB')
    local npc = QuestieDB:GetNPC(objectID)
    if npc then
      -- TODO: Implement
      error('Not implemented.')
    end
  end
end

function ObjectQuests.ObjectQuests(object)
  if Compatibility.isRetail() then
    return Unlocker.ObjectQuests(object)
  else
    -- TODO: Implement
    error('Not implemented.')
  end
end
