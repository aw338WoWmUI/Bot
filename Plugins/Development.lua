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
    GMR.WriteFile('C:/log.txt', content, true)
  end
end

function logToFile(content)
  if IS_LOGGING_ENABLED then
    writeToLogFile(tostring(content) .. '\n')
  end
end

local function writeToLogFile2(filePath, content)
  if IS_LOGGING_ENABLED then
    GMR.WriteFile(filePath, content, true)
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

-- logAPICalls2('GMR.EnemyMovement')
--logAPICallsOfAPIsWhichMatch(function (apiName)
--  return string.match(apiName, 'Move') or string.match(apiName, 'Mesh')
--end)
--logAPICallsOfAPIsWhichMatch(function (apiName)
--  return string.match(apiName, 'Handler')
--end)
-- logAPICalls2('GMR.MapMove')
-- logAPICalls2('GMR.EngageMeshTo')
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

--GMR.LibDraw.Sync(function ()
--  local playerPosition = GMR.GetPlayerPosition();
--  local x1, y1, z1 = playerPosition.x, playerPosition.y, playerPosition.z;
--  local x2, y2, z2 = GMR.ObjectPosition('target');
--  if x2 then
--    GMR.LibDraw.Line(x1, y1, z1, x2, y2, z2)
--  end
--end)

-- local playerPosition = GMR.GetPlayerPosition(); local x1, y1, z1 = playerPosition.x, playerPosition.y, playerPosition.z; local x2, y2, z2 = GMR.ObjectPosition('target'); GMR.LibDraw.Line(x1, y1, z1, x2, y2, z2)

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
    local availableQuests = Compatibility.GossipInfo.GetAvailableQuests()
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

function bbbb2223()
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end
    local mapID = 1429
  local position = {
    x = -9462.2880859375,
    y = 98.464942932129,
    z = 58.34167098999
  }
  return __A.GetClosestMeshPolygon(mapID, position.x, position.y, position.z - 10, position.x, position.y,
    position.z + 10)
end

function bbbb22234()
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end
  local continentID = select(8, GetInstanceInfo())
  local position = Movement.retrievePlayerPosition()
  return HWT.GetClosestMeshPolygon(continentID, position.x, position.y, position.z, 1000, 1000, 1000)
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

--doWhenGMRIsFullyLoaded(function ()
--  function drawPoints(points)
--    local playerPosition = GMR.GetPlayerPosition()
--    --local previousPoint = points[1]
--    --for i = 2, Array.length(points) do
--    --  local point = points[i]
--    --  GMR.LibDraw.Line(previousPoint[1], previousPoint[2], previousPoint[3], point[1], point[2], point[3])
--    --  previousPoint = point
--    --end
--
--    for i = 1, Array.length(points) do
--      local point = points[i]
--      GMR.LibDraw.GroundCircle(point[1], point[2], point[3], 0.5)
--    end
--  end
--
--  function draw()
--    drawPoints(GMR.Tables.Area.DeeprunTram)
--  end
--
--  GMR.LibDraw.Sync(draw)
--end)

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
  GMR.Log = function(...)
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

function toggleGMR()
  if GMR.IsExecuting() then
    GMR.Stop()
  else
    GMR.Execute()
  end
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

---- /dump log(toBinary(retrieveObjectNPCFlags('target')))
--GMR.ObjectDynamicFlags()
---- /dump log(toBinary(GMR.ObjectDynamicFlags('target')))
--
--log(toBinary(HWT.UnitFlags('target')))
--
--log(toBinary(GMR.ObjectFlags2('target')))
--
--log(toBinary(retrieveObjectFlags3('target')))
--
--log(toBinary(retrieveObjectFlags('target')))
--
--log(toBinary(HWT.ObjectDynamicFlags('target')))
--GMR.IsFlightmasterDiscoverable()
--GMR.Flight

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
