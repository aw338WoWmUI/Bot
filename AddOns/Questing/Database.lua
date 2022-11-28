local addOnName, AddOn = ...
Questing = Questing or {}

Questing.Database = {}

questLookup = {}
for _, quest in ipairs(quests) do
  questLookup[quest.id] = quest
end

quests = Array.filter(quests, function(quest)
  return (not quest.sides or quest.sides[1] ~= 'None') and quest.starters and next(quest.starters)
end)

table.insert(questLookup[49402].preQuestIDs, 49239)

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
  if NPCs then
    local index = nil
    return function()
      index = next(NPCs, index)
      return NPCs[index]
    end
  else
    return function()
      return nil
    end
  end
end

function Questing.Database.retrieveQuestsThatShouldBeAvailableFromNPC(npcID)
  -- FIXME: More efficient lookup.
  return Array.filter(quests, function(quest)
    return (
      Array.any(
        quest.starters,
        function(object)
          return object.type == 'npc' and object.id == npcID
        end
      ) and
        shouldQuestBeAvailable(quest)
    )
  end)
end

local questGiverIDsSet = Set.create(questGiverIDs)

function Questing.Database.isQuestGiver(npcID)
  return Boolean.toBoolean(questGiverIDsSet[npcID])
end

local turnInNPCIDs = Set.create(Array.map(quests, function(quest)
  return quest.enderID
end))

function Questing.Database.isTurnInNPC(npcID)
  return Boolean.toBoolean(turnInNPCIDs[npcID])
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

Array.forEach(quests, function(quest)
  local objectives = quest.objectives
  if objectives then
    Array.forEach(objectives, function(objective, index)
      Array.forEach(objective, function(object)
        if object.type == 'npc' then
          local objectID = object.id
          local npc = Questing.Database.retrieveNPC(objectID)
          if npc then
            if not npc.objectiveOf then
              npc.objectiveOf = {}
            end
            local questID = quest.id
            if not npc.objectiveOf[questID] then
              npc.objectiveOf[questID] = Set.create()
            end
            npc.objectiveOf[questID]:add(index)
          end
        end
      end)
    end)
  end

  local starters = quest.starters
  if starters then
    Array.forEach(starters, function(object)
      if object.type == 'npc' then
        local objectID = object.id
        local npc = Questing.Database.retrieveNPC(objectID)
        if npc then
          if not npc.startsQuests then
            npc.startsQuests = Set.create()
          end
          local questID = quest.id
          npc.startsQuests:add(questID)
        end
      end
    end)
  end
end)
