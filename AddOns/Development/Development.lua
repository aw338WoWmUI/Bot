local addOnName, AddOn = ...
Development = Development or {}

function Development.logObjectInfo(name)
  name = name or GameTooltipTextLeft1:GetText()
  local objects = Core.retrieveObjects()
  local object = Array.min(
    Array.filter(
      objects,
      function(object)
        return Core.retrieveObjectName(object.pointer) == name
      end
    ),
    function(object)
      return Core.retrieveDistanceBetweenObjects('player', object.pointer)
    end
  )
  if object then
    Logging.logToFile(Core.retrieveCurrentContinentID() .. ',\n' .. object.x .. ',\n' .. object.y .. ',\n' .. object.z .. ',\n' .. object.objectID)
  end
end

function Development.toBinary(value, width)
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

function Development.logDescriptors(filePath, object)
  for descriptorNumber = 0, 10000 do
    local value = Development.toBinary(HWT.ObjectDescriptor(object, descriptorNumber, HWT.GetValueTypesTable().ULong))
    Logging.log2(filePath, descriptorNumber, value)
  end
end

function Development.logTargetInfo()
  local unit = 'target'
  local objectID = HWT.ObjectId(unit)
  if objectID then
    local position = Core.retrieveObjectPosition(unit)
    Logging.logToFile(position.continentID .. ',\n' .. position.x .. ',\n' .. position.y .. ',\n' .. position.z .. ',\n' .. objectID)
  end
end

function Development.logUnitFlags(object)
  Logging.log('npc flags', Development.toBinary(Core.retrieveObjectNPCFlags(object), 32))
  Logging.log('unit data flags', Development.toBinary(Core.retrieveUnitDataFlags(object), 32))
  Logging.log('unit data flags 2', Development.toBinary(Core.retrieveUnitDataFlags2(object), 32))
  Logging.log('unit data flags 3', Development.toBinary(Core.retrieveUnitDataFlags3(object), 32))
  Logging.log('object data dynamic flags', Development.toBinary(Core.retrieveObjectDataDynamicFlags(object), 32))
end


function Development.logPlayerPosition()
  local playerPosition = Core.retrieveCharacterPosition()
  Logging.logToFile(playerPosition.continentID .. ',\n' .. playerPosition.x .. ',\n' .. playerPosition.y .. ',\n' .. playerPosition.z)
end

function test()
  local a = setfenv(function ()
    print('WorldFrame', _G.WorldFrame)
    print('b', b)
  end, Object.assign({}, _G, {b = 'aaa'}))
  a()
end
