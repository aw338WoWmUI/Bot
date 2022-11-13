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
  local _hasStopped = false
  local index = 1

  local actionSequenceDoer
  actionSequenceDoer = {
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
                  actionSequenceDoer.stop()
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
            -- print('run action', index)
            action.run()

            yielder.yield()
          else
            return true
          end
        end
      end
    end,

    stop = function()
      _hasStopped = true
    end,

    hasStopped = function()
      return _hasStopped
    end
  }

  return actionSequenceDoer
end
