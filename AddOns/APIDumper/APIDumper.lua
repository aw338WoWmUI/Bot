local addOnName, AddOn = ...
APIDumper = APIDumper or {}

local _ = {}

local directory = 'C:/documentation'

function APIDumper.dumpGMRAPIRetail()
  _.dumpForVersion(GMR, 'GMR', 'documentation_gmr_retail.lua')
end

function APIDumper.dumpGMRAPIWotLK()
  _.dumpForVersion(GMR, 'GMR', 'documentation_gmr_wotlk.lua')
end

function APIDumper.dumpGMRAPIVanilla()
  _.dumpForVersion(GMR, 'GMR', 'documentation_gmr_vanilla.lua')
end

function APIDumper.dumpHWTAPIRetail()
  HWTRetriever.putHWTOnTheGlobalScope()
  _.dumpForVersion(HWT, 'HWT', 'documentation_hwt_retail.lua')
end

function APIDumper.dumpHWTAPIWotLK()
  HWTRetriever.putHWTOnTheGlobalScope()
  _.dumpForVersion(HWT, 'HWT', 'documentation_hwt_wotlk.lua')
end

function APIDumper.dumpHWTAPIVanilla()
  HWTRetriever.putHWTOnTheGlobalScope()
   _.dumpForVersion(HWT, 'HWT', 'documentation_hwt_vanilla.lua')
end

function _.dumpForVersion(variable, variableName, outputFileName)
  local output = _.dump(variable, variableName)
  if not HWT.DirectoryExists(directory) then
    HWT.CreateDirectory(directory)
  end
  HWT.WriteFile(directory .. '/' .. outputFileName, output)
end

function _.dump(variable, variableName)
  local output = ''
  output = output .. variableName .. ' = {}\n'
  local keys = Object.keys(variable)
  table.sort(keys, function(a, b)
    return strcmputf8i(tostring(a), tostring(b)) < 0
  end)
  for index, name in ipairs(keys) do
    local value = variable[name]
    local b = variableName
    if _.isValidName(name) then
      b = b .. '.' .. name
    else
      b = b .. '[' .. Serialization.makeString(name) .. ']'
    end
    if type(value) == 'function' then
      local documentation = AddOn.APIDocumentation[b]
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
      output = output .. _.dump(value, b)
    else
      local valueOutput
      local valueType = type(value)
      if valueType == 'number' or valueType == 'boolean' then
        valueOutput = tostring(value)
        output = output .. b .. ' = ' .. valueOutput .. '\n'
      elseif valueType == 'string' then
        valueOutput = Serialization.makeString(value)
        output = output .. b .. ' = ' .. valueOutput .. '\n'
      else
        -- print(b, type(value))
      end
    end
  end
  return output
end

function _.isValidName(name)
  return string.match(name, '^[%a_][%d%a_]*$') and not _.isReservedKeyword(name)
end

function _.isReservedKeyword(name)
  return _.reservedKeywords[name] == true
end

_.escapedCharacters = {
  ['\\'] = '\\\\',
  ['\a'] = '\\a',
  ['\b'] = '\\b',
  ['\f'] = '\\f',
  ['\n'] = '\\n',
  ['\r'] = '\\r',
  ['\t'] = '\\t',
  ['\v'] = '\\v'
}

_.reservedKeywords = {
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
