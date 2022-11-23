Bot = {}

local isRunning = false

function Bot.isRunning()
  return isRunning
end

local handler = nil

function Bot.start()
  if not Bot.isRunning() then
    local text = 'Starting bot'
    if GMRHelpers.isFullyLoaded() then
      text = text .. '...'
    else
      text = text .. ' when GMR is fully loaded...'
    end
    print(text)

    isRunning = true

    doWhenGMRIsFullyLoaded(function()
      handler = Scheduling.doEachFrame(function()
        Bot.Warrior.castSpell()
      end)

      Questing.start()
      if not GMR.Frames.CombatRotationMode then
        GMR.CombatRotationToggle()
      end
    end)
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
