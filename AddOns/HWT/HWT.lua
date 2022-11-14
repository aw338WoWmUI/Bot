HWT = nil

doWhenGMRIsFullyLoaded(function ()
  GMR.RunEncryptedScript(GMR.Encrypt('_G.HWT = ({...})[1]'))
end)
