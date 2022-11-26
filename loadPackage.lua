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

function HWTRetriever.putHWTOnTheGlobalScope()
  local string = '_G.HWT = ({...})[1]'
  if GMR.RunEncryptedScript then
    GMR.RunEncryptedScript(GMR.Encrypt(string))
  else
    GMR.RunString(string)
  end
end

Conditionals.doOnceWhen(
  function()
    return _G.GMR and GMR.RunString
  end,
  function()
    HWTRetriever.putHWTOnTheGlobalScope()

  end
)
