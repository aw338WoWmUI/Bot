HWTRetriever = {}

function HWTRetriever.putHWTOnTheGlobalScope()
  local string = '_G.HWT = ({...})[1]'
  if GMR.RunEncryptedScript then
    GMR.RunEncryptedScript(GMR.Encrypt(string))
  else
    GMR.RunString(string)
  end
end
