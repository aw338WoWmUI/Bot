Questing = Questing or {}
Questing.Database = {}

questLookup = {}
for _, quest in ipairs(quests) do
  questLookup[quest.id] = quest
end

Array.forEach(quests, function(quest)
  if quest.requiresLevel then
    quest.requiredLevel = quest.requiresLevel
    quest.requiresLevel = nil
  end
  if quest.starterID and type(quest.starterID) == 'number' then
    quest.starterIDs = { quest.starterID }
    quest.starterID = nil
  else
    quest.starterIDs = { }
  end
end)

quests = Array.filter(quests, function (quest)
  return quest.sides[1] ~= 'None' and next(quest.starterIDs)
end)

function Questing.Database.retrieveQuest(id)
  return questLookup[id]
end

function Questing.Database.retrieveQuestsThatShouldBeAvailable()
  return Array.filter(quests, shouldQuestBeAvailable)
end

local npcLookup = {}
for _, npc in ipairs(NPCs) do
  npcLookup[npc.id] = npc
end

function Questing.Database.retrieveNPC(id)
  return npcLookup[id]
end

function Questing.Database.createNPCsIterator()
  local index = nil
  return function ()
    index = next(NPCs, index)
    return NPCs[index]
  end
end

function Questing.Database.retrieveQuestsThatShouldBeAvailableFromNPC(npcID)
  return Array.filter(quests, function(quest)
    return Array.includes(quest.starterIDs, npcID) and shouldQuestBeAvailable(quest)
  end)
end

local questGiverIDsSet = Set.create(questGiverIDs)

function Questing.Database.isQuestGiver(npcID)
  return toBoolean(questGiverIDsSet[npcID])
end
