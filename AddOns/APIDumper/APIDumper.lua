local _ = {}

local directory = 'C:/documentation'

function dumpGMRAPIRetail()
  _.dumpForVersion(GMR, 'GMR', 'documentation_gmr_retail.lua')
end

function dumpGMRAPIWotLK()
  _.dumpForVersion(GMR, 'GMR', 'documentation_gmr_wotlk.lua')
end

function dumpGMRAPIVanilla()
  _.dumpForVersion(GMR, 'GMR', 'documentation_gmr_vanilla.lua')
end

function dumpHWTAPIRetail()
  GMR.RunString('_G.HWT = ({...})[1]')
  _.dumpForVersion(HWT, 'HWT', 'documentation_hwt_retail.lua')
end

function dumpHWTAPIWotLK()
  GMR.RunString('_G.HWT = ({...})[1]')
  _.dumpForVersion(HWT, 'HWT', 'documentation_hwt_wotlk.lua')
end

function dumpHWTAPIVanilla()
  GMR.RunString('_G.HWT = ({...})[1]')
   _.dumpForVersion(HWT, 'HWT', 'documentation_hwt_vanilla.lua')
end

function _.dumpForVersion(variable, variableName, outputFileName)
  local output = _.dump(variable, variableName)
  if not GMR.DirectoryExists(directory) then
    GMR.CreateDirectory(directory)
  end
  GMR.WriteFile(directory .. '/' .. outputFileName, output)
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
      local documentation = _.APIDocumentation[b]
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

_.APIDocumentation = {
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
