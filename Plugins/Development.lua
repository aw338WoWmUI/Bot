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

local a
a = function (variable, variableName)
  local output = ''
  output = output .. variableName .. ' = {}\n'
  for name, value in pairs(variable) do
    local b = variableName
    if isValidName(name) then
      b = b .. '.' .. name
    else
      b = b .. '[' ..  makeString(name) .. ']'
    end
    if type(value) == 'function' then
      output = output .. 'function ' .. b .. '() end\n'
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
  GMR.WriteFile('C:/documentation.lua', output)
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

function tableToString(table)
  return tableToStringWithIndention(table, 0)
end

local valueToString

function tableToStringWithIndention(table, indention)
  local result = ''
  if table == nil then
    result = 'nil'
  else
    result = '{\n'
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
        result = result .. string.rep('  ', indention + 1) .. outputtedKey .. '={' .. '\n'
        result = result .. tableToStringWithIndention(value, indention + 1)
        result = result .. string.rep('  ', indention + 1) .. '}' .. '\n'
      else
        result = result .. string.rep('  ', indention + 1) .. outputtedKey .. '=' .. valueToString(value) .. '\n'
      end
    end
    result = result .. '}'
  end
  return result
end

valueToString = function (value)
  local valueType = type(value)
  if valueType == 'table' then
    return tableToString(value)
  elseif valueType == 'string' then
    return makeString(value)
  else
    return tostring(value)
  end
end

function logAPICalls(apiName)
  local parts = splitString(apiName, '.')
  local table = _G
  for index = 1, #parts - 1 do
    table = table[parts[index]]
  end
  hooksecurefunc(table, parts[#parts], function (...)
    local output = 'call to ' .. apiName
    if #{...} >= 1 then
      output = output .. ':\n'
      for index, value in ipairs({...}) do
        output = output .. tostring(index) .. '.'
        if type(value) == 'table' then
          output = output .. '\n'
        else
          output = output .. ' '
        end
        output = output .. valueToString(value) .. '\n'
      end
    else
      output = output .. ' with 0 arguments.\n'
    end
    GMR.WriteFile('C:/log.txt', output, true)
  end)
end

GMR.WriteFile('C:/log.txt', '')
logAPICalls('GMR.DefineQuest')
