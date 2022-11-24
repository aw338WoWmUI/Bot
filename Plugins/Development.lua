-- Dependencies: Core

function findIn(table, searchTerm)
  searchTerm = string.lower(searchTerm)
  for name in pairs(table) do
    if string.match(string.lower(name), searchTerm) then
      print(name)
    end
  end
end

local IS_LOGGING_ENABLED = true

local function writeToLogFile(content)
  if IS_LOGGING_ENABLED then
    HWT.WriteFile('C:/log.txt', content, true)
  end
end

function logToFile(content)
  if IS_LOGGING_ENABLED then
    writeToLogFile(tostring(content) .. '\n')
  end
end

local function writeToLogFile2(filePath, content)
  if IS_LOGGING_ENABLED then
    HWT.WriteFile(filePath, content, true)
  end
end

function logToFile2(filePath, content)
  if IS_LOGGING_ENABLED then
    writeToLogFile2(filePath, tostring(content) .. '\n')
  end
end

function log2(filePath, ...)
  if IS_LOGGING_ENABLED then
    local string = strjoin(' ', unpack(Array.map({ ... }, Serialization.valueToString)))
    logToFile2(filePath, string)
  end
end

function log(...)
  if IS_LOGGING_ENABLED then
    local string = strjoin(' ', unpack(Array.map({ ... }, Serialization.valueToString)))
    logToFile(string)
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

function logObjectInfo(name)
  name = name or GameTooltipTextLeft1:GetText()
  local objects = Core.retrieveObjects()
  local object = Array.min(
    Array.filter(
      objects,
      function(object)
        return object.Name == name
      end
    ),
    function(object)
      return Core.retrieveDistanceBetweenObjects('player', object.pointer)
    end
  )
  if object then
    logToFile(object.x .. ',\n' .. object.y .. ',\n' .. object.z .. ',\n' .. object.ID)
  end
end

function logTargetInfo()
  local unit = 'target'
  local objectID = HWT.ObjectId(unit)
  if objectID then
    local position = Core.retrieveObjectPosition(unit)
    logToFile(position.continentID .. ',\n' .. position.x .. ',\n' .. position.y .. ',\n' .. position.z .. ',\n' .. objectID)
  end
end

function logPlayerPosition()
  local playerPosition = Core.retrieveCharacterPosition()
  logToFile(playerPosition.continentID .. ',\n' .. playerPosition.x .. ',\n' .. playerPosition.y .. ',\n' .. playerPosition.z)
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
    return object.Name == name
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

function toBinary(value, width)
  local result = ''
  width = width or 64
  for index = 1, width do
    if bit.band(bit.rshift(value, index - 1), 1) == 1 then
      result = '1' .. result
    else
      result = '0' .. result
    end
    if index < width and index % 8 == 0 then
      result = ' ' .. result
    end
  end
  return result
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

function logDescriptors(filePath, object)
  for descriptorNumber = 0, 10000 do
    local value = toBinary(HWT.ObjectDescriptor(object, descriptorNumber, HWT.GetValueTypesTable().ULong))
    log2(filePath, descriptorNumber, value)
  end
end

function dsjkaasdjkdasjkl1()
  logDescriptors('C:/npc1.txt', 'target')
end

function dsjkaasdjkdasjkl2()
  logDescriptors('C:/npc2.txt', 'target')
end

function dsjkaasdjkdasjkl3()
  logDescriptors('C:/npc3.txt', 'target')
end
