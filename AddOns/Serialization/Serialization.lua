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
  return Serialization.tableToStringWithIndention(table, 1, maxDepth, references)
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

function Serialization.tableToStringWithIndention(table, depth, maxDepth, references)
  local result
  if Array.isArrayWithSubsequentIndexes(table) then
    result = Serialization.arrayToStringWithIndention(table, depth, maxDepth, references)
  else
    result = Serialization.keyValueTableToStringWithIndention(table, depth, maxDepth, references)
  end
  return result
end

function Serialization.arrayToStringWithIndention(table, depth, maxDepth, references)
  local result = ''
  if table == nil then
    result = 'nil'
  else
    result = result .. '{' .. '\n'
    local nextDepth = depth + 1
    local inside = ''
    for key, value in pairs(table) do
      if type(value) == 'table' then
        if (not maxDepth or depth <= maxDepth) and not references[value] then
          inside = inside .. Serialization.tableToStringWithIndention(value, nextDepth, maxDepth, references)
        else
          inside = inside .. tostring(value)
        end
        -- references[value] = true
      else
        inside = inside .. Serialization.valueToString(value)
      end
      if next(table, key) then
        inside = inside .. ',\n'
      end
    end
    inside = Serialization.indent(inside, 1)
    result = result .. inside .. '\n'
    result = result .. '}'
  end
  return result
end

function Serialization.keyValueTableToStringWithIndention(table, depth, maxDepth, references)
  local result = ''
  if table == nil then
    result = 'nil'
  else
    result = result .. '{' .. '\n'
    local nextDepth = depth + 1
    local inside = ''
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
          inside = inside .. outputtedKey .. '=' .. '\n'
          inside = inside .. Serialization.tableToStringWithIndention(value, nextDepth, maxDepth, references)
        else
          inside = inside .. outputtedKey .. '=' .. tostring(value)
        end
        -- references[value] = true
      else
        inside = inside .. outputtedKey .. '=' .. Serialization.valueToString(value)
      end
      if next(table, key) then
        inside = inside .. ',\n'
      end
    end
    inside = Serialization.indent(inside, 1)
    result = result .. inside .. '\n'
    result = result .. '}'
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

function Serialization.indent(string, numberOfIndentions)
  local lines = { strsplit('\n', string) }
  local indentedLines = Array.map(lines, function(line)
    return Serialization.indentLine(line, numberOfIndentions)
  end)
  return strjoin('\n', unpack(indentedLines))
end

function Serialization.indentLine(line, numberOfIndentions)
  return string.rep('  ', numberOfIndentions) .. line
end
