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
              if isActionRunning and action.shouldCancel and action.shouldCancel() then
                if action.onCancel then
                  action.onCancel()
                end
                return false
              else
                break
              end
            end
          end

          if index <= #actions then
            local action = actions[index]
            isActionRunning = true
            -- print('run action', index, GetTime())
            action.run()

            yielder.yield()
          else
            return true
          end
        end
      end
    end,

    stop = function()
      hasStopped = true
    end
  }
end
