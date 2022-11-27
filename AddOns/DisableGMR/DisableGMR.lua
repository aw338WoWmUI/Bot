local addOnName, AddOn, exports, imports = ...
local Modules = imports and imports.Modules or _G.Modules
local DisableGMR = Modules.determineExportsVariable(addOnName, exports)
local Function, Hooking = Modules.determineImportVariables('Function', 'Hooking', imports)

-- Prevent the GMR login and subscribe frame from showing
hooksecurefunc('CreateFrame', function(_, name)
  if name == 'LoginFrame' then
    LoginFrame.Show = Function.noOperation
  elseif name == 'SubscribeFrame' then
    SubscribeFrame.Show = Function.noOperation
  end
end)

Hooking.hookFunctionOnGlobalTable('GMR', 'Print', function ()
  return Function.noOperation
end)
