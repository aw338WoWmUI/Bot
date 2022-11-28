local addOnName, AddOn = ...
Questing = Questing or {}

Questing.Database = {}

local _ = {}

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule('QuestieDB')
---@type QuestieLib
local QuestieLib = QuestieLoader:ImportModule('QuestieLib')
---@type QuestieCorrections
local QuestieCorrections = QuestieLoader:ImportModule('QuestieCorrections')
---@type QuestieEvent
local QuestieEvent = QuestieLoader:ImportModule('QuestieEvent')
---@type QuestiePlayer
local QuestiePlayer = QuestieLoader:ImportModule('QuestiePlayer')
---@type QuestieJourney
local QuestieJourney = QuestieLoader:ImportModule('QuestieJourney')
---@type QuestieReputation
local QuestieReputation = QuestieLoader:ImportModule('QuestieReputation')
---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule('ZoneDB')

function Questing.Database.retrieveQuest(id)
  local quest = QuestieDB:GetQuest(id)
  if quest then
    return Questing.Database.convertQuestieQuestToQuestingQuest(quest)
  else
    return nil
  end
end

local function convertPointsToMapPoints(points)
  return Array.flatMap(points, function(point)
    local ID = point.id
    local NPC = Questing.Database.retrieveNPC(ID)
    if NPC and NPC.coordinates then
      return Array.map(NPC.coordinates, function(coordinates)
        return {
          questID = ID,
          mapID = coordinates[1],
          x = coordinates[2],
          y = coordinates[3],
        }
      end)
    else
      return nil
    end
  end)
end

function Questing.Database.receiveQuestsOnMap(mapID)
  local quests = Questing.Database.retrieveQuestsThatShouldBeAvailable(mapID)
  return Array.selectTrue(Array.flatMap(quests, function(quest)
    if Compatibility.QuestLog.isComplete(quest.id) then
      return convertPointsToMapPoints(quest.enders)
    elseif not Compatibility.QuestLog.isOnQuest(quest.id) then
      return convertPointsToMapPoints(quest.starters)
    end
  end))
end

function Questing.Database.receiveQuestsOnMapThatCanBeAccepted(mapID)
  local availableQuests = Questing.Database.retrieveQuestsThatShouldBeAvailable(mapID)
  return Array.filter(availableQuests, function (quest)
    return AddOn.isNotOnQuest(quest.id)
  end)
end

function Questing.Database.retrieveQuestsOnMapThatTheCharacterIsOn(mapID)
  local availableQuests = Questing.Database.retrieveQuestsThatShouldBeAvailable(mapID)
  local quests = Array.filter(availableQuests, function(quest)
    local isOnQuest = Compatibility.QuestLog.isOnQuest(quest.id)
    return isOnQuest
  end)

  local questieQuests = Array.map(quests, function (quest)
    return QuestieDB:GetQuest(quest.id)
  end)

  return Array.flatMap(questieQuests, _.convertQuestieQuestToQuestOnMap)
end

function _.convertQuestieQuestToQuestOnMap(quest)
  local objectives = {} -- TODO: Other types (game objects)
  if quest.Objectives then
    for _, objective in ipairs(quest.Objectives) do
      for objectID, object in pairs(objective.spawnList) do
        for zoneID, spawnPoints in pairs(object.Spawns) do
          local mapID = ZoneDB:GetUiMapIdByAreaId(zoneID)
          for _, spawnPoint in ipairs(spawnPoints) do
            local objective = {
              questID = quest.Id,
              mapID = mapID,
              x = spawnPoint[1] / 100,
              y = spawnPoint[2] / 100
            }
            table.insert(objectives, objective)
          end
        end
      end
    end
  end
  return objectives
end

function Questing.Database.retrieveQuestsThatShouldBeAvailable(mapID)
  local result = {}

  local zoneID = ZoneDB:GetAreaIdByUiMapId(mapID)
  local quests = QuestieJourney.zoneMap[zoneID]

  if (not quests) then
    return nil
  end

  local sortedQuestByLevel = QuestieLib:SortQuestIDsByLevel(quests)

  for _, levelAndQuest in pairs(sortedQuestByLevel) do
    ---@type number
    local questID = levelAndQuest[2]
    -- Only show quests which are not hidden
    if QuestieCorrections.hiddenQuests and ((not QuestieCorrections.hiddenQuests[questID]) or QuestieEvent:IsEventQuest(questID)) and QuestieDB.QuestPointers[questID] then
      -- Completed quests
      if Questie.db.char.complete[questID] then
      else
        local queryResult = QuestieDB.QueryQuest(
          questID,
          {
            "exclusiveTo",
            "nextQuestInChain",
            "parentQuest",
            "preQuestSingle",
            "preQuestGroup",
            "requiredMinRep",
            "requiredMaxRep"
          }
        ) or {}
        local exclusiveTo = queryResult[1]
        local nextQuestInChain = queryResult[2]
        local parentQuest = queryResult[3]
        local preQuestSingle = queryResult[4]
        local preQuestGroup = queryResult[5]
        local requiredMinRep = queryResult[6]
        local requiredMaxRep = queryResult[7]

        -- Exclusive quests will never be available since another quests permanently blocks them.
        -- Marking them as complete should be the most satisfying solution for user
        if (nextQuestInChain and Questie.db.char.complete[nextQuestInChain]) or (exclusiveTo and QuestieDB:IsExclusiveQuestInQuestLogOrComplete(exclusiveTo)) then
          -- The parent quest has been completed
        elseif parentQuest and Questie.db.char.complete[parentQuest] then
          -- Unoptainable reputation quests
        elseif not QuestieReputation:HasReputation(requiredMinRep, requiredMaxRep) then
          -- A single pre Quest is missing
        elseif not QuestieDB:IsPreQuestSingleFulfilled(preQuestSingle) then
          -- Multiple pre Quests are missing
        elseif not QuestieDB:IsPreQuestGroupFulfilled(preQuestGroup) then
          -- Repeatable quests
        elseif QuestieDB.IsRepeatable(questID) then
          -- Available quests
        else
          tinsert(result, questID)
        end
      end
      temp = {}
    end
  end

  local result2 = Array.map(
    result,
    Questing.Database.retrieveQuest
  )

  local result3 = Questing.Database.filterQuests(result2)

  return result3
end

function Questing.Database.filterQuests(quests)
  local level = UnitLevel('player')
  return Array.filter(quests, function(quest)
    return quest.requiredLevel <= level
  end)
end

function Questing.Database.convertQuestieQuestsToQuestingQuests(quests)
  return Array.map(quests, Questing.Database.convertQuestieQuestToQuestingQuest)
end

local function convertQuestieObjectReferencesToQuestingStructure(data)
  local result
  if data.NPC then
    result = Array.map(data.NPC, function(questID)
      return {
        type = 'npc',
        id = questID
      }
    end)
  elseif data.Item then
    result = Array.map(data.Item, function(questID)
      return {
        type = 'item',
        id = questID
      }
    end)
  elseif data.GameObject then
    result = Array.map(data.GameObject, function(questID)
      return {
        type = 'object',
        id = questID
      }
    end)
  else
    result = {}
  end
  return result
end

function Questing.Database.convertQuestieQuestToQuestingQuest(quest)
  local sidesAndRaces = Questing.Database.convertQuestieRacesToQuestingSidesAndRaces(quest.requiredRaces)
  local starters = convertQuestieObjectReferencesToQuestingStructure(quest.Starts)
  local enders = {}
  local finisher = quest.Finisher
  if finisher then
    local type
    if finisher.Type == 'monster' then
      type = 'npc'
    elseif finisher.Type == 'object' then
      type = 'object'
    else
      print('finisher.Type', finisher.Type)
    end
    table.insert(enders, {
      type = type,
      id = finisher.Id
    })
  end
  local objectives = {} -- TODO: Other types (game objects)
  for _, objective in ipairs(quest.Objectives) do
    local type = objective.Type
    if type == 'monster' then
      type = 'npc'
    end
    local objective = {
      type = type,
      id = objective.Id
    }
    table.insert(objectives, objective)
  end
  return {
    id = quest.Id,
    name = quest.name,
    requiredLevel = quest.requiredLevel,
    sides = sidesAndRaces.sides,
    races = sidesAndRaces.races,
    classes = Questing.Database.convertQuestieClassesToQuestingClasses(quest.requiredClasses),
    starters = starters,
    enders = enders,
    preQuestIDs = Array.concat(quest.preQuestGroup or {}, quest.preQuestSingle or {}),
    storylinePreQuestIDs = {},
    objectives = objectives
  }
end

local function areFlagsSet(bitMap, flags)
  return bit.band(bitMap, flags) == flags
end

function Questing.Database.convertQuestieRacesToQuestingSidesAndRaces(questieRaces)
  local sides = {}
  local races = {}
  local alliance = false
  local horde = false

  local allianceFlagsToRaces = {
    [QuestieDB.raceKeys.DRAENEI] = 'Draenei',
    [QuestieDB.raceKeys.DWARF] = 'Dwarf',
    [QuestieDB.raceKeys.GNOME] = 'Gnome',
    [QuestieDB.raceKeys.HUMAN] = 'Human',
    [QuestieDB.raceKeys.NIGHT_ELF] = 'Night Elf',
  }

  local hordeFlagsToRaces = {
    [QuestieDB.raceKeys.BLOOD_ELF] = 'Blood Elf',
    [QuestieDB.raceKeys.ORC] = 'Orc',
    [QuestieDB.raceKeys.TAUREN] = 'Tauren',
    [QuestieDB.raceKeys.TROLL] = 'Troll',
    [QuestieDB.raceKeys.UNDEAD] = 'Undead',
  }

  for flags, string in pairs(allianceFlagsToRaces) do
    if areFlagsSet(questieRaces, flags) then
      alliance = true
      table.insert(sides, string)
    end
  end

  for flags, string in pairs(hordeFlagsToRaces) do
    if areFlagsSet(questieRaces, flags) then
      horde = true
      table.insert(sides, string)
    end
  end

  if alliance then
    table.insert(sides, 'Alliance')
  end
  if horde then
    table.insert(sides, 'Horde')
  end

  return {
    sides = sides,
    races = races
  }
end

function Questing.Database.convertQuestieClassesToQuestingClasses(questieClasses)
  local classes = {}

  local classFlagsToClasses = {
    [QuestieDB.classKeys.WARRIOR] = 'Warrior',
    [QuestieDB.classKeys.PALADIN] = 'Paladin',
    [QuestieDB.classKeys.HUNTER] = 'Hunter',
    [QuestieDB.classKeys.DRUID] = 'Druid',
    [QuestieDB.classKeys.MAGE] = 'Mage',
    [QuestieDB.classKeys.PRIEST] = 'Priest',
    [QuestieDB.classKeys.ROGUE] = 'Rogue',
    [QuestieDB.classKeys.SHAMAN] = 'Shamana',
    [QuestieDB.classKeys.WARLOCK] = 'Warlock'
  }

  for flags, string in pairs(classFlagsToClasses) do
    if areFlagsSet(questieClasses, flags) then
      table.insert(classes, string)
    end
  end

  return classes
end

function Questing.Database.retrieveNPC(id)
  local npc = QuestieDB:GetNPC(id)
  if npc then
    return Questing.Database.convertQuestieNPCToQuestingNPC(npc)
  else
    return nil
  end
end

function Questing.Database.convertQuestieNPCToQuestingNPC(npc)
  local coordinates
  if npc.spawns then
    coordinates = Array.flatMap(Object.entries(npc.spawns), function(keyAndValue)
      local zoneID = keyAndValue.key
      local mapID = ZoneDB:GetUiMapIdByAreaId(zoneID)
      local coordinatePairs = keyAndValue.value
      return Array.map(coordinatePairs, function(coordinates)
        return {
          mapID,
          coordinates[1] / 100,
          coordinates[2] / 100
        }
      end)
    end)
  else
    coordinates = {}
  end

  return {
    id = npc.id,
    coordinates = coordinates,
    canRepair = areFlagsSet(npc.npcFlags, QuestieDB.npcFlags.REPAIR),
    isInnkeeper = areFlagsSet(npc.npcFlags, QuestieDB.npcFlags.INNKEEPER),
    isGrpyhonMaster = areFlagsSet(npc.npcFlags, QuestieDB.npcFlags.FLIGHT_MASTER),
    isVendor = areFlagsSet(npc.npcFlags, QuestieDB.npcFlags.VENDOR)
  }
end

function Questing.Database.createNPCsIterator()
  local id = nil
  return function()
    id = next(QuestieDB.NPCPointers, id)
    return Questing.Database.retrieveNPC(id)
  end
end

function Questing.Database.retrieveQuestsThatShouldBeAvailableFromNPC(npcID)
  local npc = QuestieDB:GetNPC(npcID)
  local questIDs = npc.questStarts
  if questIDs then
    local quests = Array.map(questIDs, Questing.Database.retrieveQuest)
    return Array.filter(quests, function(quest)
      return shouldQuestBeAvailable(quest)
    end)
  else
    return {}
  end
end

function Questing.Database.isQuestGiver(npcID)
  local npc = QuestieDB:GetNPC(npcID)
  local questIDs = npc.questStarts
  return Boolean.toBoolean(next(questIDs))
end
