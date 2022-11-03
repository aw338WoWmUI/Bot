function resumeWithShowingError(thread, ...)
  local result = {coroutine.resume(thread, ...)}
  local wasSuccessful = result[1]
  if not wasSuccessful then
    local errorMessage = result[2]
    error(errorMessage .. '\n' .. debugstack(thread), 0)
  end
  return unpack(result)
end

function waitFor(predicate, timeout)
  local thread = coroutine.running()
  local ticker
  local startTime = GetTime()
  ticker = C_Timer.NewTicker(0, function()
    if predicate() then
      ticker:Cancel()
      resumeWithShowingError(thread, true)
    elseif timeout and GetTime() - startTime >= timeout then
      ticker:Cancel()
      resumeWithShowingError(thread, false)
    end
  end)
  return coroutine.yield()
end

function waitForDuration(duration)
  local thread = coroutine.running()
  C_Timer.After(duration, function()
    resumeWithShowingError(thread)
  end)
  return coroutine.yield()
end
