Logging = {}

local _ = {}

local IS_LOGGING_ENABLED = true

function Logging.log(...)
  if IS_LOGGING_ENABLED then
    local string = strjoin(' ', unpack(Array.map({ ... }, Serialization.valueToString)))
    Logging.logToFile(string)
  end
end

function Logging.logToFile(content)
  if IS_LOGGING_ENABLED then
    _.writeToLogFile(tostring(content) .. '\n')
  end
end

function _.writeToLogFile(content)
  if IS_LOGGING_ENABLED then
    HWT.WriteFile('C:/log.txt', content, true)
  end
end
