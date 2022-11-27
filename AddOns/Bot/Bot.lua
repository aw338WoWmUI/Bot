local addOnName, AddOn, exports, imports = ...
local Modules = imports and imports.Modules or _G.Modules
local Bot = Modules.determineExportsVariable(addOnName, exports)
local Questing = Modules.determineImportVariables('Questing', imports)

local isRunning = false

function Bot.isRunning()
  return isRunning
end

function Bot.start()
  if not Bot.isRunning() then
    print('Starting bot...')

    isRunning = true

    Questing.start()
  end
end

function Bot.stop()
  if Bot.isRunning() then
    print('Stopping bot...')
    isRunning = false
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
