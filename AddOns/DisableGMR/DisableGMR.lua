local addOnName, AddOn = ...
DisableGMR = DisableGMR or {}

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
