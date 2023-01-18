Lua = Lua or {}
local addOnName, AddOn = ...
local _ = {}

function Lua.isValidName(name)
  return string.match(name, '^[%a_][%d%a_]*$') and not Lua.isReservedKeyword(name)
end

function Lua.isReservedKeyword(name)
  return _.reservedKeywords[name] == true
end

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
