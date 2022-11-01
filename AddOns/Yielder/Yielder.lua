function createYielder()
  local thread = coroutine.running()
  local start = debugprofilestop()

  local function scheduleNextResume()
    start = debugprofilestop()
    resumeWithShowingError(thread)
  end

  return {
    hasRanOutOfTime = function()
      return debugprofilestop() - start >= 1 / 60
    end,

    yield = function()
      C_Timer.After(0, scheduleNextResume)
      coroutine.yield()
    end
  }
end
