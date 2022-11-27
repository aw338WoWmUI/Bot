ActionSequenceDoer = {}

function ActionSequenceDoer.createActionSequenceDoer(actions)
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

function ActionSequenceDoer.createActionSequenceDoer2(actions, options)
  options = options or {}
  local isRunning = false
  local isActionRunning = false
  local _hasStopped = false
  local index = 1

  local actionSequenceDoer
  actionSequenceDoer = {
    run = function()
      if not isRunning then
        isRunning = true

        local yielder = Yielder.createYielder()

        while not _hasStopped do
          while index <= #actions do
            local action = actions[index]
            if action:isDone(actionSequenceDoer) then
              isActionRunning = false
              if action.whenIsDone then
                action:whenIsDone(actionSequenceDoer)
              end
              index = index + 1
            else
              if isActionRunning and action.shouldCancel and action:shouldCancel(actionSequenceDoer) then
                if action.onCancel then
                  action:onCancel(actionSequenceDoer)
                  actionSequenceDoer.stop()
                end
                if options.onStop then
                  options.onStop(actionSequenceDoer)
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
            action:run(actionSequenceDoer)

            yielder.yield()
          else
            actionSequenceDoer.stop()
            if options.onStop then
              options.onStop(actionSequenceDoer)
            end
            return true
          end
        end

        if options.onStop then
          options.onStop(actionSequenceDoer)
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
