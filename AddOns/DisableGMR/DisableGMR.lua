-- Prevent the GMR login and subscribe frame from showing
hooksecurefunc('CreateFrame', function(_, name)
  if name == 'LoginFrame' then
    LoginFrame.Show = function()
    end
  elseif name == 'SubscribeFrame' then
    SubscribeFrame.Show = function()
    end
  end
end)
