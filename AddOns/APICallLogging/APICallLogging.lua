local _ = {}

local IS_LOGGING_ENABLED = true

function logAPICalls(apiName)
  local parts = splitString(apiName, '.')
  local table = _G
  for index = 1, #parts - 1 do
    table = table[parts[index]]
  end
  hooksecurefunc(table, parts[#parts], function(...)
    local output = 'call to ' .. apiName
    local args = _.tablePack(...)
    if args.n >= 1 then
      output = output .. ':\n'
      output = output .. _.outputList(args)
    else
      output = output .. ' with 0 arguments.\n'
    end
    _.writeToLogFile(output)
  end)
end

local function createLogFunction(apiName, originalFunction)
  return function(...)
    local output = 'call to ' .. apiName
    local args = _.tablePack(...)
    if args.n >= 1 then
      output = output .. ':\n'
      output = output .. _.outputList(args)
    else
      output = output .. ' with 0 arguments.\n'
    end

    local result = { originalFunction(...) }

    output = output .. 'Result:\n'
    local packedResult = _.tablePack(unpack(result))
    output = output .. _.outputList(packedResult)

    output = output .. '\n'

    -- output = output .. 'Stack trace:\n' .. debugstack() .. '\n'
    _.writeToLogFile(output)

    return unpack(result)
  end
end

function logAPICalls2(apiName)
  local parts = splitString(apiName, '.')
  local table = _G
  for index = 1, #parts - 1 do
    table = table[parts[index]]
  end
  local originalFunction = table[parts[#parts]]
  table[parts[#parts]] = createLogFunction(apiName, originalFunction)
end

function logApiCalls3(apiName)
  local parts = splitString(apiName, '.')
  if #parts == 2 then
    Hooking.hookFunctionOnGlobalTable(parts[1], parts[2], function(originalFunction)
      return createLogFunction(apiName, originalFunction)
    end)
  else
    error('Only functions on a global are supported.')
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

function logAPICallsOfAPIsWhichMatch(doesMatch)
  for key in pairs(GMR) do
    local apiName = 'GMR.' .. key
    if type(GMR[key]) == 'function' and doesMatch(apiName) then
      print('Logging API calls to: ' .. apiName)
      logAPICalls2(apiName)
    end
  end
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

function _.outputList(list)
  local output = ''
  for index = 1, list.n do
    local value = list[index]
    output = output .. tostring(index) .. '.'
    if type(value) == 'table' then
      output = output .. '\n'
    else
      output = output .. ' '
    end
    output = output .. Serialization.valueToString(value) .. '\n'
  end
  return output
end

function _.writeToLogFile(content)
  if IS_LOGGING_ENABLED then
    GMR.WriteFile('C:/log.txt', content, true)
  end
end

function _.tablePack(...)
  return {
    n = select('#', ...),
    ...
  }
end
