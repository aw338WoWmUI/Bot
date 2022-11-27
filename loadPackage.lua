local _ = {}

local Conditionals = {}

function Conditionals.doOnceWhen(areConditionsMet, fn)
  local ticker
  ticker = C_Timer.NewTicker(0, function()
    if areConditionsMet() then
      ticker:Cancel()

      fn()
    end
  end)
end

local HWTRetriever = {}

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

Conditionals.doOnceWhen(
  function()
    return _G.GMR and GMR.RunString
  end,
  function()
    local HWT = HWTRetriever.retrieveHWT()
    local filePath = 'E:/Bot/output.lua'
    local content = HWT.ReadFile(filePath)
    local result = HWT.LoadScript(filePath, content)
    if type(result) == 'function' then
      result()
    else
      error(result)
    end
  end
)
