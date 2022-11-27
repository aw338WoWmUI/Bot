local addOnName, AddOn, exports, imports = ...

local function determineExportsVariable(addOnName, exports)
  if exports then
    return exports
  elseif _G[addOnName] then
    return _G[addOnName]
  else
    local exports = {}
    _G[addOnName] = exports
    return exports
  end
end

local Modules = determineExportsVariable(addOnName, exports)

Modules.determineExportsVariable = determineExportsVariable

function Modules.determineImportVariable(importAddOnName, imports)
  return (imports or _G)[importAddOnName]
end

function Modules.determineImportVariables(...)
  local args = { ... }
  local numberOfArguments = #args
  local lastArgument = args[numberOfArguments]
  local lastImportNameArgumentIndex
  local imports
  if type(lastArgument) == 'table' then
    imports = lastArgument
    lastImportNameArgumentIndex = numberOfArguments - 1
  else
    imports = nil
    lastImportNameArgumentIndex = numberOfArguments
  end
  local importVariables = {}
  for index = 1, lastImportNameArgumentIndex do
    local importAddOnName = args[index]
    local importVariable = Modules.determineImportVariable(importAddOnName, imports)
    importVariables[index] = importVariable
  end
  return unpack(importVariables)
end
