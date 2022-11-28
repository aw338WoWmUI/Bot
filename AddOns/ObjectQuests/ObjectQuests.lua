local addOnName, AddOn = ...
PackageInitialization.initializePackage(addOnName)
local _ = {}

function ObjectIsQuestObjective(object)
  if Compatibility.isRetail() then
    Unlocker.ObjectIsQuestObjective(object)
  else
    local objectID = HWT.ObjectId(object)
    ---@type QuestieDB
    local QuestieDB = QuestieLoader:ImportModule('QuestieDB')
    local npc = QuestieDB:GetNPC(objectID)
    if npc then

    end
  end
end

function ObjectQuests(object)
  if Compatibility.isRetail() then
    Unlocker.ObjectQuests(object)
  else

  end
end
