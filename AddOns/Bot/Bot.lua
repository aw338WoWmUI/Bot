Bot = {}

local isRunning = false

function Bot.start()
  if not isRunning then
    isRunning = true
    -- efficientlyLevelToMaximumLevel()
    C_Timer.NewTicker(0, function()
      Bot.Warrior.castSpell()
    end)
  end
end

---- Prevent the GMR login frame from showing
--hooksecurefunc('CreateFrame', function(_, name)
--  if name == 'LoginFrame' then
--    LoginFrame.Show = function()
--    end
--  end
--end)
