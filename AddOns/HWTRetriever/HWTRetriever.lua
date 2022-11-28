local addOnName, AddOn = ...
HWTRetriever = HWTRetriever or {}

local _ = {}

function HWTRetriever.putHWTOnTheGlobalScope()
  local string = '_G.HWT = ({...})[1]'
  if GMR.RunEncryptedScript then
    GMR.RunEncryptedScript(GMR.Encrypt(string))
  else
    GMR.RunString(string)
  end
end

function HWTRetriever.retrieveHWT()
  local globalName = _.generateFreeRandomString(16)
  local string = '_G.' .. globalName .. ' = ({...})[1]'
  if GMR.RunEncryptedScript then
    GMR.RunEncryptedScript(GMR.Encrypt(string))
  else
    GMR.RunString(string)
  end
  local HWT = _G[globalName]
  _G[globalName] = nil
  return HWT
end

function _.generateFreeRandomString(length)
  local randomString
  repeat
    randomString = _.generateRandomString(length)
  until not _G[randomString]
  return randomString
end

function _.generateRandomString(length)
  local randomString = ''
  for i = 1, length do
    randomString = randomString .. _.generateRandomCharacter()
  end
  return randomString
end

function _.generateRandomCharacter()
	return string.char(math.random(97, 122))
end
