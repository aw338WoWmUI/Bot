local addOnName, AddOn, exports, imports = ...
local Modules = imports and imports.Modules or _G.Modules
local Bot = Modules.determineExportsVariable(addOnName, exports)
local Questing = Modules.determineImportVariable('Questing', imports)

local isRunning = false

function Bot.isRunning()
  return isRunning
end

local handler = nil

function Bot.start()
  if not Bot.isRunning() then
    print('Starting bot...')

    isRunning = true

    --handler = Scheduling.doEachFrame(function()
    --  Bot.Warrior.castSpell()
    --end)

    Questing.start()
  end
end

function Bot.stop()
  if Bot.isRunning() then
    print('Stopping bot...')
    isRunning = false
    --handler:Cancel()
    Questing.stop()
  end
end

function Bot.toggle()
  if isRunning then
    Bot.stop()
  else
    Bot.start()
  end
end
