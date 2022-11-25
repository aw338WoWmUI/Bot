Logging = {}

local _ = {}

local IS_LOGGING_ENABLED = true

function Logging.log(...)
  if IS_LOGGING_ENABLED then
    local string = strjoin(' ', unpack(Array.map({ ... }, Serialization.valueToString)))
    Logging.logToFile(string)
  end
end

function Logging.log2(filePath, ...)
  if IS_LOGGING_ENABLED then
    local string = strjoin(' ', unpack(Array.map({ ... }, Serialization.valueToString)))
    Logging.logToFile2(filePath, string)
  end
end

function Logging.writeToLogFile2(filePath, content)
  if IS_LOGGING_ENABLED then
    HWT.WriteFile(filePath, content, true)
  end
end

function Logging.logToFile2(filePath, content)
  if IS_LOGGING_ENABLED then
    Logging.writeToLogFile2(filePath, tostring(content) .. '\n')
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
