-- Dependencies: Core

function findIn(table, searchTerm)
  searchTerm = string.lower(searchTerm)
  for name in pairs(table) do
    if string.match(string.lower(name), searchTerm) then
      print(name)
    end
  end
end

function findInGMR(searchTerm)
  findIn(GMR, searchTerm)
end

local reservedKeywords = {
  ['and'] = true,
  ['break'] = true,
  ['do'] = true,
  ['else'] = true,
  ['elseif'] = true,
  ['end'] = true,
  ['false'] = true,
  ['for'] = true,
  ['function'] = true,
  ['if'] = true,
  ['in'] = true,
  ['local'] = true,
  ['nil'] = true,
  ['not'] = true,
  ['or'] = true,
  ['repeat'] = true,
  ['return'] = true,
  ['then'] = true,
  ['true'] = true,
  ['until'] = true,
  ['while'] = true
}

local function isReservedKeyword(name)
  return reservedKeywords[name] == true
end

local function isValidName(name)
  return string.match(name, '^[%a_][%d%a_]*$') and not isReservedKeyword(name)
end

function logTargetPosition()
  local position = Core.retrieveObjectPosition('target')
  if position then
    logToFile(position.continentID .. ', ' .. position.x .. ', ' .. position.y .. ', ' .. position.z)
  end
end

function logQuestInfo()
  local questID = GetQuestID();
  local questName = QuestUtils_GetQuestName(questID)
  logToFile(questID .. ",\n'" .. questName .. "'")
end

function logNPCPositionAndID()
  local unit = 'target'
  local objectID = HWT.ObjectId(unit)
  if objectID then
    local position = Core.retrieveObjectPosition(unit)
    logToFile(position.continentID .. ',\n' .. position.x .. ',\n' .. position.y .. ',\n' .. position.z .. ',\n' .. objectID)
  end
end

function logNearbyObjects()
  local objects = Core.retrieveObjectWhichAreCloseToTheCharacter(5)
  logToFile(tableToString(objects))
end

function logPlayerMapPosition()
  local mapID = C_Map.GetBestMapForUnit('player')
  local position = C_Map.GetPlayerMapPosition(mapID, 'player')
  logToFile('{ x = ' .. position.x .. ', y = ' .. position.y .. '}')
end

function logDistanceToObject(name)
  name = name or GameTooltipTextLeft1:GetText()
  local objects = Core.retrieveObjects()
  local object = Array.find(objects, function(object)
    return Core.retrieveObjectName(object.pointer) == name
  end)
  if object then
    local distance = Core.retrieveDistanceBetweenObjects('player', object.pointer)
    logToFile('distance = ' .. distance)
  end
end

function findTaxiNode(name)
  name = name or GameTooltipTextLeft1:GetText()
  local mapID = FlightMapFrame:GetMapID()
  local taxiNodes = C_TaxiMap.GetAllTaxiNodes(mapID)
  return Array.find(taxiNodes, function(node)
    return node.name == name
  end)
end

function logQuestID()
  local questID = GetQuestID()
  logToFile(questID)
end

function printQuestGiverStatus()
  local targetQuestGiverStatusNumber = __A.ObjectQuestGiverStatus('target')
  local status = Array.find(Object.entries(__A.GetObjectQuestGiverStatusesTable()), function (keyAndValue)
    local statusNumber = keyAndValue.value
    return statusNumber == targetQuestGiverStatusNumber
  end)
  if status then
    local statusName = status.key
    print(status.key)
  end
end

local function areFlagsSet(bitMap, flags)
  return bit.band(bitMap, flags) == flags
end

function retrieveObjectNPCFlags(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__npcFlags, HWT.GetValueTypesTable().ULong)
end

function retrieveObjectFlags(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__flags, HWT.GetValueTypesTable().ULong)
end

function retrieveObjectFlags3(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__flags3, HWT.GetValueTypesTable().ULong)
end
