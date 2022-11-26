local addOnName, AddOn, exports, imports = ...

local function determineExportsVariable(addOnName, exports)
  return exports or _G[addOnName] or {}
end

local Modules = determineExportsVariable(addOnName, exports)

Modules.determineExportsVariable = determineExportsVariable

function Modules.determineImportVariable(importAddOnName, imports)
  return (imports or _G)[importAddOnName]
end
