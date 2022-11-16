Bot = {}

function Bot.start()
  efficientlyLevelToMaximumLevel()
end

-- Prevent the GMR login frame from showing
hooksecurefunc('CreateFrame', function (_, name)
  if name == 'LoginFrame' then
    LoginFrame.Show = function () end
  end
end)
