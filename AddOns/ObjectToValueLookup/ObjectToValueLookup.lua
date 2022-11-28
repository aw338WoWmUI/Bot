local addOnName, AddOn = ...
ObjectToValueLookup = ObjectToValueLookup or {}

local NIL_KEY = '__N'
local VALUE_KEY = '__V'

local function retrieveKey(key)
  if key == nil then
    return NIL_KEY
  else
    return key
  end
end

function ObjectToValueLookup:new(convertObjectToArray)
  local lookup = {
    _values = {},
    _convertObjectToArray = convertObjectToArray
  }
  setmetatable(lookup, { __index = ObjectToValueLookup})
  return lookup
end

function ObjectToValueLookup:retrieveValue(object)
  local array = self._convertObjectToArray(object)

  local table = self._values
  for index = 1, Array.length(array) do
    local key = retrieveKey(array[index])
    local nextTable = table[key]
    if nextTable then
      table = nextTable
    else
      return nil
    end
  end

  return table[VALUE_KEY]
end

function ObjectToValueLookup:setValue(object, value)
  local array = self._convertObjectToArray(object)

  local table = self._values
  for index = 1, Array.length(array) do
    key = retrieveKey(array[index])
    if not table[key] then
      table[key] = {}
    end
    table = table[key]
  end

  table[VALUE_KEY] = value
end
