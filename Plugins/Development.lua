local function tablePack(...)
  return {
    n = select('#', ...),
    ...
  }
end

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

local escapedCharacters = {
  ['\\'] = '\\\\',
  ['\a'] = '\\a',
  ['\b'] = '\\b',
  ['\f'] = '\\f',
  ['\n'] = '\\n',
  ['\r'] = '\\r',
  ['\t'] = '\\t',
  ['\v'] = '\\v'
}

local function createOpeningBracketOfLevel(level)
  return '[' .. string.rep('=', level) .. '['
end

local function createClosingBracketOfLevel(level)
  return ']' .. string.rep('=', level) .. ']'
end

local function makeMultiLineString(text)
  local level = 0
  while string.match(text, createClosingBracketOfLevel(level)) do
    level = level + 1
  end
  return createOpeningBracketOfLevel(level) .. '\n' .. text .. createClosingBracketOfLevel(level)
end

local function makeString(text)
  if string.match(text, '\n') then
    return makeMultiLineString(text)
  else
    local quoteCharacter
    if not string.match(text, "'") then
      quoteCharacter = "'"
    elseif not string.match(text, '"') then
      quoteCharacter = '"'
    else
      quoteCharacter = "'"
      text = string.gsub(text, "'", "\\'")
    end

    for replacedCharacter, characterReplacement in pairs(escapedCharacters) do
      text = string.gsub(text, replacedCharacter, characterReplacement)
    end

    return quoteCharacter .. text .. quoteCharacter
  end
end

local APIDocumentation = {
  ['GMR.MeshTo'] = {
    parameters = {
      {
        name = 'x',
        type = 'number'
      },
      {
        name = 'y',
        type = 'number'
      },
      {
        name = 'z',
        type = 'number'
      }
    }
  },
  ['GMR.DefineQuest'] = {
    parameters = {
      {
        name = 'factionFor',
        type = 'string | table',
        description = "'Alliance', 'Horde' or {'Alliance', 'Horde'}"
      },
      {
        name = 'classesFor',
        type = 'table | nil',
        description = 'A list of classes that the quest is for. When `nil` is passed, then the quest is considered to be for all classes. Valid values for the classes seem to be the keys of `GMR.Variables.Specializations`.'
      },
      {
        name = 'questID',
        type = 'number'
      },
      {
        name = 'questName',
        type = 'string'
      },
      {
        name = 'gmrQuestType',
        type = 'string',
        description = 'Possible values include `Custom`, `MassPickUp` and `Grinding`.'
      }
      -- There are more parameters
    }
  },
  ['GMR.GetPositionFromPosition'] = {
    description = 'Calculates a position based on another position, a length, and two angles.',
    parameters = {
      {
        name = 'x',
        type = 'number'
      },
      {
        name = 'y',
        type = 'number'
      },
      {
        name = 'z',
        type = 'number'
      },
      {
        name = 'length',
        type = 'number'
      },
      {
        name = 'angle1',
        type = 'number',
        description = 'In radian.'
      },
      {
        name = 'angle2',
        type = 'number',
        description = 'In radian.'
      }
    }
  }
}

local a
a = function(variable, variableName)
  local output = ''
  output = output .. variableName .. ' = {}\n'
  for name, value in pairs(variable) do
    local b = variableName
    if isValidName(name) then
      b = b .. '.' .. name
    else
      b = b .. '[' .. makeString(name) .. ']'
    end
    if type(value) == 'function' then
      local documentation = APIDocumentation[b]
      if documentation then
        if documentation.description then
          output = output .. '--- ' .. documentation.description
        end
        if documentation.parameters then
          for _, parameter in ipairs(documentation.parameters) do
            output = output .. '--- @param ' .. parameter.name
            if parameter.type then
              output = output .. ' ' .. parameter.type
            end
            if parameter.description then
              output = output .. ' ' .. parameter.description
            end
            output = output .. '\n'
          end
        end
      end
      if string.match(b, '%[') then
        output = output .. b .. ' = function('
      else
        output = output .. 'function ' .. b .. '('
      end
      if documentation and documentation.parameters then
        for index, parameter in ipairs(documentation.parameters) do
          if index > 1 then
            output = output .. ', '
          end
          output = output .. parameter.name
        end
      end
      output = output .. ') end\n'
    elseif type(value) == 'table' then
      output = output .. a(value, b)
    else
      local valueOutput
      local valueType = type(value)
      if valueType == 'number' or valueType == 'boolean' then
        valueOutput = tostring(value)
        output = output .. b .. ' = ' .. valueOutput .. '\n'
      elseif valueType == 'string' then
        valueOutput = makeString(value)
        output = output .. b .. ' = ' .. valueOutput .. '\n'
      else
        -- print(b, type(value))
      end
    end
  end
  return output
end

function dumpAPI()
  local output = a(GMR, 'GMR')
  GMR.WriteFile('C:/documentation/documentation.lua', output)
end

function splitString(text, splitString)
  local parts = {}
  local startIndex
  local endIndex

  startIndex, endIndex = string.find(text, splitString, 1, true)
  while startIndex ~= nil do
    local part = string.sub(text, 1, startIndex - 1)
    table.insert(parts, part)
    text = string.sub(text, endIndex + 1)
    startIndex, endIndex = string.find(text, splitString, 1, true)
  end

  table.insert(parts, text)
  return parts
end

function tableToString(table, maxDepth)
  local references = {}
  local result = ''
  result = result .. '{' .. '\n'
  result = result .. tableToStringWithIndention(table, 0, 1, maxDepth, references)
  result = result .. '}' .. '\n'
  return result
end

valueToString = nil

function tableToStringWithIndention(table, indention, depth, maxDepth, references)
  local result = ''
  if table == nil then
    result = 'nil'
  else
    local nextDepth = depth + 1
    for key, value in pairs(table) do
      local outputtedKey
      if type(key) == 'number' then
        outputtedKey = '[' .. tostring(key) .. ']'
      elseif type(key) == 'string' then
        if string.match(key, ' ') then
          outputtedKey = '["' .. tostring(key) .. '"]'
        else
          outputtedKey = tostring(key)
        end
      else
        outputtedKey = '[' .. tostring(key) .. ']'
      end
      if type(value) == 'table' then
        if (not maxDepth or depth <= maxDepth) and not references[value] then
          result = result .. string.rep('  ', indention + 1) .. outputtedKey .. '={' .. '\n'
          result = result .. tableToStringWithIndention(value, indention + 1, nextDepth, maxDepth, references)
          result = result .. string.rep('  ', indention + 1) .. '}' .. '\n'
        else
          result = result .. string.rep('  ', indention + 1) .. outputtedKey .. '=' .. tostring(value) .. '\n'
        end
        -- references[value] = true
      else
        result = result .. string.rep('  ', indention + 1) .. outputtedKey .. '=' .. valueToString(value) .. '\n'
      end
    end
  end
  return result
end

valueToString = function(value)
  local valueType = type(value)
  if valueType == 'table' then
    return tableToString(value)
  elseif valueType == 'string' then
    return makeString(value)
  else
    return tostring(value)
  end
end

local function outputList(list)
  local output = ''
  for index = 1, list.n do
    local value = list[index]
    output = output .. tostring(index) .. '.'
    if type(value) == 'table' then
      output = output .. '\n'
    else
      output = output .. ' '
    end
    output = output .. valueToString(value) .. '\n'
  end
  return output
end

function logAPICalls(apiName)
  local parts = splitString(apiName, '.')
  local table = _G
  for index = 1, #parts - 1 do
    table = table[parts[index]]
  end
  hooksecurefunc(table, parts[#parts], function(...)
    local output = 'call to ' .. apiName
    local args = tablePack(...)
    if args.n >= 1 then
      output = output .. ':\n'
      output = output .. outputList(args)
    else
      output = output .. ' with 0 arguments.\n'
    end
    GMR.WriteFile('C:/log.txt', output, true)
  end)
end

function logAPICalls2(apiName)
  local parts = splitString(apiName, '.')
  local table = _G
  for index = 1, #parts - 1 do
    table = table[parts[index]]
  end
  local originalFunction = table[parts[#parts]]
  table[parts[#parts]] = function(...)
    local output = 'call to ' .. apiName
    local args = tablePack(...)
    if args.n >= 1 then
      output = output .. ':\n'
      output = output .. outputList(args)
    else
      output = output .. ' with 0 arguments.\n'
    end

    local result = { originalFunction(...) }

    output = output .. 'Result:\n'
    local packedResult = tablePack(unpack(result))
    output = output .. outputList(packedResult)

    output = output .. '\n'

    -- output = output .. 'Stack trace:\n' .. debugstack() .. '\n'
    GMR.WriteFile('C:/log.txt', output, true)

    return unpack(result)
  end
end

function logAllAPICalls()
  for key in pairs(GMR) do
    if type(GMR[key]) == 'function' then
      if key ~= 'WriteFile' then
        logAPICalls2('GMR.' .. key)
      end
    end
  end
end

-- logAPICalls2('GMR.GetVendorPath')
-- logAPICalls2('GMR.VendorPathHandler')
--logAPICalls2('GMR.GetObject')
--logAPICalls2('GMR.LibDraw.Array')
--logAPICalls2('GMR.OffMeshHandler')
--logAPICalls2('GMR.LibDraw.SetColorRaw')
--logAPICalls2('GMR.GetPath')
--logAPICalls2('GMR.GetPathBetweenPoints')
-- logAllAPICalls()
--logAPICalls2('GMR.GetClosestMeshPolygon')
--logAPICalls2('GMR.GetPoints')
-- logAPICalls2('GMR.OffMeshHandler')
--logAPICalls2('GMR.FaceDirection')
--logAPICalls2('GMR.FaceSmoothly')
--logAPICalls2('GMR.MapMove')
--logAPICalls2('GMR.Mesh')
--logAPICalls2('GMR.MeshTo')
--logAPICalls2('GMR.MoveTo')
--logAPICalls2('GMR.MeshHandler')
--logAPICalls2('GMR.CustomPathHandler')
--logAPICalls2('GMR.MeshMovementHandler')
--logAPICalls2('GMR.MovementHandler')
-- logAPICalls2('GMR.ExecutePath')
-- logAPICalls2('GMR.GetPositionFromPosition')
-- logAPICalls2('GMR.TraceLine')
--logAPICalls2('GMR.LibDraw.Line')
-- logAPICalls2('GMR.RunString')
--logAPICalls2('GMR.LibDraw.GroundCircle')
--logAPICalls2('GMR.DefineQuest')
--logAPICalls2('GMR.GetMeshPoints')
--logAPICalls2('GMR.GetClosestMeshPolygon')
--logAPICalls2('GMR.GetClosestPointOnMesh')
--logAPICalls2('GMR.GetMeshToDestination')
--logAPICalls2('GMR.GetPath')
--logAPICalls2('GMR.LibDraw.Circle')
--logAPICalls2('GMR.LibDraw.GroundCircle')
-- logAPICalls2('GMR.MoveTo')
-- logAPICalls2('GMR.MeshTo')
-- logAPICalls2('GMR.Questing.MoveTo')
-- logAPICalls2('GMR.DefineQuest')
-- logAPICalls2('GMR.StopMoving')
-- logAPICalls2('GMR.DefineSetting')
-- logAPICalls2('GMR.DefineSettings')
-- GMR.WriteFile('C:/log.txt', '')
-- logAPICalls('GMR.TraceLine')
--logAPICalls2('GMR.MeshCallback')
--logAPICalls2('GMR.MeshMovementHandler')
--logAPICalls2('GMR.OffMeshHandler')
--logAPICalls2('GMR.MeshHandler')
--logAPICalls2('GMR.IsLoSMeshing')
--logAPICalls2('GMR.Mesh')
--logAPICalls2('GMR.IsInvalidMesh')
--logAPICalls2('GMR.MeshTo')
--logAPICalls2('GMR.Questing.MoveTo')
--logAPICalls2('GMR.MoveTo')
--logAPICalls2('GMR.IsExecuting')
-- logAPICalls2('GMR.LibDraw.Line')
--for name in pairs(GMR.LibDraw) do
--  if type(GMR.LibDraw[name]) == 'function' then
--    logAPICalls2('GMR.LibDraw.' .. name)
--  end
--end
--local functionName = 'DefineQuester'
--GMR[functionName] = function (...)
--  print(functionName, ...)
--  print(debugstack())
--end

--local TraceLineHitFlags = {
--  COLLISION = 1048849
--}
--
--hooksecurefunc(GMR, 'TraceLine', function(x1, y1, z1, x2, y2, z2, hitFlags)
--  if hitFlags == TraceLineHitFlags.COLLISION then
--    GMR.LibDraw.Line(x1, y1, z1, x2, y2, z2)
--  end
--end)

--hooksecurefunc(GMR.LibDraw, 'clearCanvas', function ()
--  local playerPosition = GMR.GetPlayerPosition();
--  local x1, y1, z1 = playerPosition.x, playerPosition.y, playerPosition.z;
--  local x2, y2, z2 = GMR.ObjectPosition('target');
--  if x2 then
--    GMR.LibDraw.Line(x1, y1, z1, x2, y2, z2)
--  end
--end)

-- local playerPosition = GMR.GetPlayerPosition(); local x1, y1, z1 = playerPosition.x, playerPosition.y, playerPosition.z; local x2, y2, z2 = GMR.ObjectPosition('target'); GMR.LibDraw.Line(x1, y1, z1, x2, y2, z2)

function logToFile(content)
  GMR.WriteFile('C:/log.txt', tostring(content) .. '\n', true)
end

local IS_LOGGING_ENABLED = true

function log(...)
  if IS_LOGGING_ENABLED then
    local string = strjoin(' ', unpack(Array.map({...}, valueToString)))
    logToFile(string)
  end
end

function logTargetPosition()
  local x, y, z = GMR.ObjectPosition('target')
  if x then
    logToFile(tostring(x) .. ', ' .. y .. ', ' .. z)
  end
end

function logQuestInfo()
  local questID = GetQuestID();
  local questName = QuestUtils_GetQuestName(questID)
  logToFile(tostring(questID) .. ",\n'" .. questName .. "'")
end

function logNPCPositionAndID()
  local unit = 'target'
  local objectID = GMR.ObjectId(unit)
  if objectID then
    local x, y, z = GMR.ObjectPosition(unit)
    logToFile(tostring(x) .. ',\n' .. y .. ',\n' .. z .. ',\n' .. objectID)
  end
end

function logNearbyObjects()
  local objects = GMR.GetNearbyObjects(5)
  logToFile(tableToString(objects))
end

function includePointerInObject(objects)
  local result = {}
  for pointer, object in pairs(objects) do
    object.pointer = pointer
    table.insert(result, object)
  end
  return result
end

function logObjectInfo(name)
  name = name or GameTooltipTextLeft1:GetText()
  local objects = retrieveObjects()
  local object = Array.min(
    Array.filter(
      objects,
      function(object)
        return object.Name == name
      end
    ),
    function(object)
      return GMR.GetDistanceBetweenObjects('player', object.pointer)
    end
  )
  if object then
    logToFile(object.x .. ',\n' .. object.y .. ',\n' .. object.z .. ',\n' .. object.ID)
  end
end

function logTargetInfo()
  local unit = 'target'
  local objectID = GMR.ObjectId(unit)
  if objectID then
    local x, y, z = GMR.ObjectPosition(unit)
    logToFile(x .. ',\n' .. y .. ',\n' .. z .. ',\n' .. objectID)
  end
end

function logPlayerPosition()
  local playerPosition = GMR.GetPlayerPosition()
  logToFile(playerPosition.x .. ',\n' .. playerPosition.y .. ',\n' .. playerPosition.z)
end

function logQuestSkeleton()
  local unit = 'target'
  local objectID = GMR.ObjectId(unit)
  if objectID then
    local x, y, z = GMR.ObjectPosition(unit)
    local questID = GetQuestID()
    local questName = QuestUtils_GetQuestName(questID)
    local output = '' ..
      'do\n' ..
      '  local questID = ' .. questID .. '\n' ..
      '  defineQuest(\n' ..
      '    questID,\n' ..
      "    '" .. questName .. "',\n" ..
      '    ' .. x .. ',\n' ..
      '    ' .. y .. ',\n' ..
      '    ' .. z .. ',\n' ..
      '    ' .. objectID .. ',\n' ..
      '    nil,\n' ..
      '    nil,\n' ..
      '    nil,\n' ..
      '    nil,\n' ..
      '    function()\n' ..
      '\n' ..
      '    end,\n' ..
      '    function()\n' ..
      '\n' ..
      '    end\n' ..
      '  )\n' ..
      'end\n'
    logToFile(output)
  end
end

function logQuestGiver()
  local unit = 'target'
  local objectID = GMR.ObjectId(unit)
  if objectID then
    local continentID = select(8, GetInstanceInfo())
    local x, y, z = GMR.ObjectPosition(unit)
    local questID = GetQuestID();
    local questName = QuestUtils_GetQuestName(questID)
    local availableQuests = C_GossipInfo.GetAvailableQuests()
    local output = '' ..
      '{\n' ..
      '  objectID = ' .. objectID .. ',\n' ..
      '  continentID = ' .. continentID .. ',\n' ..
      '  x = ' .. x .. ',\n' ..
      '  y = ' .. y .. ',\n' ..
      '  z = ' .. z .. ',\n' ..
      '  questIDs = {\n'
    local questIDs = {}
    local questID = GetQuestID()
    if questID then
      table.insert(questIDs, questID)
    end
    questIDs = Array.concat(
      questIDs,
      Array.map(availableQuests, function(quest)
        return quest.questID
      end)
    )
    Array.forEach(questIDs, function(questID)
      output = output ..
        '    ' .. questID .. ',\n'
    end)
    output = output ..
      '  }\n' ..
      '}'
    logToFile(output)
  end
end

function logQuestForMassPickUp()
  local unit = 'target'
  local objectID = GMR.ObjectId(unit)
  if objectID then
    local x, y, z = GMR.ObjectPosition(unit)
    local questID = GetQuestID()
    local output = '{ ' .. questID .. ', ' .. x .. ', ' .. y .. ', ' .. z .. ', ' .. objectID .. ' }'
    logToFile(output)
  end
end

function aaaaaa()
  local mapID = MapUtil.GetDisplayableMapForPlayer()
  local playerPosition = GMR.GetPlayerPosition()
  print('player position')
  printTable(playerPosition)

  print('a')
  local x3, y3, z3 = GMR.GetClosestPointOnMesh(mapID, playerPosition.x, playerPosition.y, playerPosition.z)
  print('aa', x3, y3, z3)

  local x, y, z
  for z3 = 10000, 0, -1 do
    -- print('z3', z3)
    x, y, z = GMR.GetClosestPointOnMesh(mapID, playerPosition.x, playerPosition.y, z3)
    if x then
      break
    end
  end
  print('closest point on mesh')
  print(x, y, z)
  if x ~= playerPosition.x or y ~= playerPosition.y then
    local x2, y2, z2 = GMR.GetClosestPointOnMesh(mapID, playerPosition.x, playerPosition.y, z)
    print('closest point on mesh 2')
    print(x2, y2, z2)
  end
end

function bbbb()
  local playerPosition = GMR.GetPlayerPosition()
  printTable(playerPosition)
  return GMR.GetZCoordinate(playerPosition.x, playerPosition.y)
end

function bbbb2()
  local position = {
    x = -9462.2880859375,
    y = 98.464942932129,
    z = 58.34167098999
  }
  return GMR.GetZCoordinate(position.x, position.y)
end

function bbbb3()
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end
  local mapID = 1429
  local position = {
    x = -9462.2880859375,
    y = 98.464942932129,
    z = 58.34167098999
  }
  return GMR.GetClosestMeshPolygon(mapID, position.x, position.y, position.z - 10, position.x, position.y,
    position.z + 10)
end

function bbbb4()
  local position = {
    x = -9462.2880859375,
    y = 98.464942932129,
    z = 58.34167098999
  }
  return GMR.MeshTo(position.x, position.y, position.z)
end

function bbbb5()
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end
  local mapID = 1429
  local position = {
    x = -9475.013671875,
    y = 116.13453674316,
    z = 57.011684417725
  }
  print('GMR.IsOnMeshPoint', GMR.IsOnMeshPoint(position.x, position.y, position.z))
  GMR.MeshTo(position.x, position.y, position.z)
  return GMR.GetClosestPointOnMesh(mapID, position.x, position.y, position.z, true)
end

function bbbb6()
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end
  local mapID = 1429
  local position = {
    x = -9475.013671875,
    y = 116.13453674316,
    z = 57.011684417725
  }
  return GMR.MeshTo(position.x, position.y)
end

function logPlayerMapPosition()
  local mapID = C_Map.GetBestMapForUnit('player')
  local position = C_Map.GetPlayerMapPosition(mapID, 'player')
  logToFile('{ x = ' .. position.x .. ', y = ' .. position.y .. '}')
end

function logDistanceToObject(name)
  name = name or GameTooltipTextLeft1:GetText()
  local objects = retrieveObjects()
  local object = Array.find(objects, function(object)
    return object.Name == name
  end)
  if object then
    local distance = GMR.GetDistanceBetweenObjects('player', object.pointer)
    logToFile('distance = ' .. distance)
  end
end

function moveToTarget()
  local x, y, z = GMR.ObjectPosition('target')
  if x then
    GMR.Questing.MoveTo(x, y, z)
  end
end

function storePosition()
  GMR_SavedVariablesPerCharacter.storedPosition = GMR.GetPlayerPosition()
end

function moveToStoredPosition()
  local storedPosition = GMR_SavedVariablesPerCharacter.storedPosition
  if storedPosition then
    GMR.Questing.MoveTo(storedPosition.x, storedPosition.y, storedPosition.z)
  end
end

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and _G.GMR.LibDraw and _G.GMR.LibDraw.clearCanvas then
    ticker:Cancel()
    local clearCanvas = GMR.LibDraw.clearCanvas

    function drawPoints(points)
      local playerPosition = GMR.GetPlayerPosition()
      --local previousPoint = points[1]
      --for i = 2, Array.length(points) do
      --  local point = points[i]
      --  GMR.LibDraw.Line(previousPoint[1], previousPoint[2], previousPoint[3], point[1], point[2], point[3])
      --  previousPoint = point
      --end

      for i = 1, Array.length(points) do
        local point = points[i]
        GMR.LibDraw.GroundCircle(point[1], point[2], point[3], 0.5)
      end
    end

    function draw()
      drawPoints(GMR.Tables.Area.DeeprunTram)
    end

    -- draw()

    GMR.LibDraw.clearCanvas = function(...)
      local result = { clearCanvas(...) }

      -- draw()

      return unpack(result)
    end
  end
end)

function stopMoving()
  local wasExecuting = GMR.IsExecuting()
  if not wasExecuting then
    GMR.Execute()
  end
  GMR.Stop()
  if wasExecuting then
    GMR.Execute()
  end
end

function enableLogging()
  local gmrLog = GMR.Log
  GMR.Log = function (...)
    log(...)
    return gmrLog(...)
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

hooksecurefunc(C_GossipInfo, 'SelectActiveQuest', function(...)
  print('C_GossipInfo.SelectActiveQuest', ...)
end)

enableLogging()

function aadsakjdsa()
  -- GMR.ModifyPath()
  return GMR.GetPath(
    -1589.9603271484,
    -873.77026367188,
    12.970695495605
  )
end

function ccdsad()
  local pointer = GMR.FindObject(278313)
  local x, y, z = GMR.ObjectPosition(pointer)
  GMR.FaceDirection(x, y, z)
end

function ccdsasdasdad()
  local pointer = GMR.FindObject(278313)
  local x, y, z = GMR.ObjectPosition(pointer)
  return GMR.GetDistanceToPosition(x, y, z)
end

function toBinary(value)
  local result = ''
  for index = 1, 32 do
    if bit.band(bit.rshift(value, index - 1), 1) == 1 then
      result = '1' .. result
    else
      result = '0' .. result
    end
    if index == 8 or index == 16 then
      result = ' ' .. result
    end
  end
  return result
end

function aaaaaaaadsdjkasd()
  local dynamicFlags = GMR.ObjectDynamicFlags(GMR.FindObject(278313))
  local result = toBinary(dynamicFlags)
  print(result)
end

-- GMR.ObjectRawType(GMR.FindObject(278313)) -- 8

function hasFlag2(flags, flag)
  return bit.band(flags, flag) == flag
end

function hasFlag(flag)
  local flags1 = GMR.ObjectFlags('target')
  local flags2 = GMR.ObjectFlags2('target')
  print('ObjectFlags', hasFlag2(flags1, flag))
  print('ObjectFlags2', hasFlag2(flags2, flag))
end

function printFlags()
  local flags1 = GMR.ObjectFlags('target')
  local flags2 = GMR.ObjectFlags2('target')
  print('ObjectFlags', toBinary(flags1))
  print('ObjectFlags2', toBinary(flags2))
end

function adjsadjka()
  local continentID = 0
  local mapID, point = C_Map.GetMapPosFromWorldPos(continentID, {
    x = -6153,
    y = 48,
    z = 417
  })
  local mapPoint = UiMapPoint.CreateFromVector2D(mapID, point)
  C_Map.SetUserWaypoint(mapPoint)
end

-- GMR.GetClosestMeshPolygon()
-- GMR.GetClosestPointOnMesh()

-- GMR.LoadMeshFiles()
-- GMR.GetClosestMeshPolygon(1643, -93.19278717041, -1074.8294677734, 61.544826507568, 1, 1, 1000)
-- GMR.GetMeshPoints('0x001000540000264B', -93.19278717041, -1074.8294677734, 61.677707672119, 0.13288116455078)
-- GMR.GetMeshToDestination()
-- GMR.MeshHandler()

-- GMR.MeshHandler(1135.46484375, 62.296180725098, 13.241092681885, nil)
-- GMR.CustomPathHandler()
-- GMR.MeshMovementHandler()
