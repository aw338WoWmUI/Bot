Questing = Questing or {}
Questing.Database = {}

questLookup = {}
for _, quest in ipairs(quests) do
  questLookup[quest.id] = quest
end

quests = Array.filter(quests, function (quest)
  return (not quest.sides or quest.sides[1] ~= 'None') and next(quest.starterIDs)
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

local turnInNPCIDs = Set.create(Array.map(quests, function (quest)
  return quest.enderID
end))

function Questing.Database.isTurnInNPC(npcID)
  return toBoolean(turnInNPCIDs[npcID])
end

local npcLocations = {}

function Questing.Database.storeNPCLocation(npcID, location)
  if not npcLocations[npcID] then
    npcLocations[npcID] = {}
  end
  table.insert(npcLocations[npcID], location)
end

function Questing.Database.retrieveNPCLocation(npcID)
  return npcLocations[npcID]
end
