function createActionSequenceDoer(actions)
  local index = 1

  return {
    run = function()
      while index <= #actions do
        local action = actions[index]
        if action.isDone() then
          if action.whenIsDone then
            action.whenIsDone()
          end
          index = index + 1
        else
          break
        end
      end

      if index <= #actions then
        local action = actions[index]
        action.run()
      end
    end
  }
end

function createActionSequenceDoer2(actions)
  local isRunning = false
  local isActionRunning = false
  local hasStopped = false
  local index = 1

  local run2
  run2 = function ()
    if not hasStopped then
      while index <= #actions do
        local action = actions[index]
        if action.isDone() then
          isActionRunning = false
          if action.whenIsDone then
            action.whenIsDone()
          end
          index = index + 1
        else
          break
        end
      end

      if index <= #actions then
        if not isActionRunning  then
          local action = actions[index]
          isActionRunning = true
          action.run()
        end

        C_Timer.After(0, run2)
      end
    end
  end

  return {
    run = function()
      if not isRunning then
        isRunning = true
        run2()
      end
    end,

    stop = function()
      hasStopped = true
    end
  }
end
