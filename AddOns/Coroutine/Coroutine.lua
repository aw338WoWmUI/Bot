function resumeWithShowingError(thread, ...)
  local result = {coroutine.resume(thread, ...)}
  local wasSuccessful = result[1]
  if not wasSuccessful then
    local errorMessage = result[2]
    error(errorMessage .. '\n' .. debugstack(thread), 0)
  end
  return unpack(result)
end
