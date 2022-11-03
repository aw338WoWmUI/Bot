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

  return {
    run = function()
      if not isRunning then
        isRunning = true

        local yielder = createYielder()

        while not hasStopped do
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
            if not isActionRunning then
              local action = actions[index]
              isActionRunning = true
              action.run()
            end

            yielder.yield()
          else
            return
          end
        end
      end
    end,

    stop = function()
      hasStopped = true
    end
  }
end
