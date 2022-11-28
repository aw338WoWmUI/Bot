local addOnName, AddOn = ...
SavedVariables = SavedVariables or {}

local _ = {}

local savedVariables = {}

function SavedVariables.registerAccountWideSavedVariables(addOnName, variablesTable)
  _.ensureEntryForAddOn(addOnName)
  savedVariables[addOnName].accountWide = variablesTable
end

function SavedVariables.registerSavedVariablesPerCharacter(addOnName, variablesTable)
  _.ensureEntryForAddOn(addOnName)
  savedVariables[addOnName].perCharacter = variablesTable
end

function SavedVariables.saveSavedVariables()
  for addOnName in pairs(savedVariables) do
    SavedVariables.saveSavedVariablesOfAddOn(addOnName)
  end
end

function SavedVariables.saveSavedVariablesOfAddOn(addOnName)
  _.saveAccountWideSavedVariablesOfAddOn(addOnName)
  _.savePerCharacterSavedVariablesOfAddOn(addOnName)
end

function SavedVariables.loadSavedVariablesOfAddOn(addOnName)
  return {
    accountWide = _.loadAccountWideSavedVariables(addOnName),
    perCharacter = _.loadPerCharacterSavedVariables(addOnName)
  }
end

function _.ensureEntryForAddOn(addOnName)
  if not savedVariables[addOnName] then
    _.createEntryForAddOn(addOnName)
  end
end

function _.createEntryForAddOn(addOnName)
  savedVariables[addOnName] = {
    accountWide = nil,
    perCharacter = nil
  }
end

function _.generateAccountDirectory()
  local account = HWT.GetCurrentAccount()
  local appDirectory = HWT.GetAppDirectory()
  appDirectory = string.gsub(appDirectory, '\\', '/')
  if string.sub(appDirectory, string.len(appDirectory)) ~= '/' then
    appDirectory = appDirectory + '/'
  end
  return appDirectory .. 'Account/' .. account
end

function _.loadAccountWideSavedVariables(addOnName)
  local filePath = _.generateFilePathToAccountWideSavedVariablesOfAddOn(addOnName)
  return _.loadSavedVariables(filePath)
end

function _.loadPerCharacterSavedVariables(addOnName)
  local filePath = _.generateFilePathToPerCharacterSavedVariablesOfAddOn(addOnName)
  return _.loadSavedVariables(filePath)
end

function _.loadSavedVariables(filePath)
  if HWT.FileExists(filePath) then
    local content = HWT.ReadFile(filePath)
    local result = HWT.LoadScript(filePath, 'return ' .. content)
    if type(result) == 'function' then
      return result()
    else
      error(result)
    end
  else
    return {}
  end
end

function _.saveAccountWideSavedVariablesOfAddOn(addOnName)
  local variablesTable = savedVariables[addOnName].accountWide
  local filePath = _.generateFilePathToAccountWideSavedVariablesOfAddOn(addOnName)
  _.writeVariablesTable(variablesTable, filePath)
end

function _.generateFilePathToAccountWideSavedVariablesOfAddOn(addOnName)
  local account = HWT.GetCurrentAccount()
  return _.generateAccountDirectory() .. '/SavedVariables' .. '/' .. addOnName .. '.lua'
end

function _.savePerCharacterSavedVariablesOfAddOn(addOnName)
  local variablesTable = savedVariables[addOnName].perCharacter
  local filePath = _.generateFilePathToPerCharacterSavedVariablesOfAddOn(addOnName)
  _.writeVariablesTable(variablesTable, filePath)
end

function _.generateFilePathToPerCharacterSavedVariablesOfAddOn(addOnName)
  local account = HWT.GetCurrentAccount()
  local serverName = GetRealmName()
  local characterName = UnitName('player')
  return _.generateAccountDirectory() .. '/' .. serverName .. '/' .. characterName .. '/SavedVariables' .. '/' .. addOnName .. '.lua'
end

function _.writeVariablesTable(variablesTable, filePath)
  if not variablesTable and HWT.FileExists(filePath) then
    variablesTable = {}
  end

  if variablesTable then
    local serializedContent = Serialization.serialize(variablesTable)
    _.writeFile(filePath, serializedContent)
  end
end

local function onLogout(...)
  SavedVariables.saveSavedVariables()
end

local function onEvent(self, event, ...)
  if event == 'PLAYER_LOGOUT' then
    onLogout(...)
  end
end

function _.writeFile(filePath, content)
  local directoryPath = _.extractDirectory(filePath)
  _.makeDirectoryRecursively(directoryPath)
  HWT.WriteFile(filePath, content)
end

function _.extractDirectory(filePath)
  local index = _.findInStringFromRight(filePath, '/')
  if index ~= nil then
    return string.sub(filePath, 1, index - 1)
  else
    return filePath
  end
end

function _.findInStringFromRight(string, pattern)
  local reversedString = string.reverse(string)
  local startIndex, endIndex = string.find(reversedString, pattern)
  if startIndex ~= nil then
    return string.len(string) - endIndex + 1
  else
    return nil
  end
end

function _.makeDirectoryRecursively(path)
  local parts = String.split('/', path)
  local subPath = parts[1]
  for index = 2, #parts do
    local part = parts[index]
    if part ~= '' then
      subPath = subPath .. '/' .. part
      if not HWT.DirectoryExists(subPath) then
        HWT.CreateDirectory(subPath)
      end
    end
  end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', onEvent)
frame:RegisterEvent('PLAYER_LOGOUT')
