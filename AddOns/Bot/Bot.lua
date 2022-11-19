Bot = {}

local isRunning = false

function Bot.isRunning()
  return isRunning
end

local handler = nil

function Bot.start()
  if not Bot.isRunning() then
    print('Starting bot...')
    isRunning = true

    handler = Scheduling.doEachFrame( function()
      Bot.Warrior.castSpell()
    end)

    Questing.start()
    if not GMR.Frames.CombatRotationMode then
      GMR.CombatRotationToggle()
    end
  end
end

function Bot.stop()
  if Bot.isRunning() then
    print('Stopping bot...')
    isRunning = false
    handler:Cancel()
    Questing.stop()
    if GMR.Frames.CombatRotationMode then
      GMR.CombatRotationToggle()
    end
  end
end

function Bot.toggle()
  if isRunning then
    Bot.stop()
  else
    Bot.start()
  end
end

---- Prevent the GMR login frame from showing
--hooksecurefunc('CreateFrame', function(_, name)
--  if name == 'LoginFrame' then
--    LoginFrame.Show = function()
--    end
--  end
--end)
