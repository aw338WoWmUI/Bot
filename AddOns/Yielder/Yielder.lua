function createYielder(timePerRun)
  timePerRun = (timePerRun or 1 / 60) * 1000
  local thread = coroutine.running()
  local start = debugprofilestop()

  local function scheduleNextResume()
    start = debugprofilestop()
    resumeWithShowingError(thread)
  end

  return {
    hasRanOutOfTime = function()
      return debugprofilestop() - start >= timePerRun
    end,

    yield = function()
      C_Timer.After(0, scheduleNextResume)
      coroutine.yield()
    end
  }
end

function createResumableYielder()
  local thread = coroutine.running()

  return {
    resume = function ()
      if coroutine.status(thread) == 'suspended' then
        resumeWithShowingError(thread)
      end
    end,

    hasRanOutOfTime = function()
      return true
    end,

    yield = function()
      coroutine.yield()
    end
  }
end
