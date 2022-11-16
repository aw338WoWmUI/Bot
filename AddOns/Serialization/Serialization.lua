Serialization = {}

function Serialization.valueToString(value)
  local valueType = type(value)
  if valueType == 'table' then
    return Serialization.tableToString(value)
  elseif valueType == 'string' then
    return Serialization.makeString(value)
  else
    return tostring(value)
  end
end

function Serialization.tableToString(table, maxDepth)
  local references = {}
  local result = ''
  result = result .. '{' .. '\n'
  result = result .. Serialization.tableToStringWithIndention(table, 0, 1, maxDepth, references)
  result = result .. '}' .. '\n'
  return result
end

function Serialization.makeString(text)
  if string.match(text, '\n') then
    return Serialization.makeMultiLineString(text)
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

    for replacedCharacter, characterReplacement in pairs(Serialization.escapedCharacters) do
      text = string.gsub(text, replacedCharacter, characterReplacement)
    end

    return quoteCharacter .. text .. quoteCharacter
  end
end

function Serialization.tableToStringWithIndention(table, indention, depth, maxDepth, references)
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
          result = result .. Serialization.tableToStringWithIndention(value, indention + 1, nextDepth, maxDepth, references)
          result = result .. string.rep('  ', indention + 1) .. '}' .. '\n'
        else
          result = result .. string.rep('  ', indention + 1) .. outputtedKey .. '=' .. tostring(value) .. '\n'
        end
        -- references[value] = true
      else
        result = result .. string.rep('  ', indention + 1) .. outputtedKey .. '=' .. Serialization.valueToString(value) .. '\n'
      end
    end
  end
  return result
end

function Serialization.makeMultiLineString(text)
  local level = 0
  while string.match(text, Serialization.createClosingBracketOfLevel(level)) do
    level = level + 1
  end
  return Serialization.createOpeningBracketOfLevel(level) .. '\n' .. text .. Serialization.createClosingBracketOfLevel(level)
end

Serialization.escapedCharacters = {
  ['\\'] = '\\\\',
  ['\a'] = '\\a',
  ['\b'] = '\\b',
  ['\f'] = '\\f',
  ['\n'] = '\\n',
  ['\r'] = '\\r',
  ['\t'] = '\\t',
  ['\v'] = '\\v'
}

function Serialization.createClosingBracketOfLevel(level)
  return ']' .. string.rep('=', level) .. ']'
end

function Serialization.createOpeningBracketOfLevel(level)
  return '[' .. string.rep('=', level) .. '['
end
