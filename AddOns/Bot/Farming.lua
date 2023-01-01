Bot = Bot or {}
Bot.Farming = Bot.Farming or {}
local _ = {}

function Bot.createTogglableFarming(retrieveNextPosition, findFarmedThings)
	local togglable = Togglable.Togglable:new(function ()
    return Bot.startFarming(retrieveNextPosition, findFarmedThings)
  end)

  return togglable
end

function Bot.startFarming(retrieveNextPosition, findFarmedThings)
  local stoppable, stoppableInternal = Stoppable.Stoppable:new()

  Coroutine.runAsCoroutine(function()
    local moveToNextNode = nil
    local isVisitingNodesEnabled = false

    local lookForThings
    local visitNodes

    local function doLookForThings()
      local pausable, pausableInternal = Pausable.Pausable:new()

      Coroutine.runAsCoroutine(function()
        while true do
          local farmedThings = findFarmedThings()
          if #farmedThings >= 1 then
            print('Found farmed thing(s).')

            local characterPosition = Core.retrieveCharacterPosition()
            local closestFarmedThing = Array.min(farmedThings, function(cache)
              local position = Core.retrieveObjectPosition(cache)
              return Core.calculateDistanceBetweenPositions(characterPosition, position)
            end)

            local function doFarmThing()
              if Core.canCharacterAttackUnit(closestFarmedThing) then
                return Core.doMob(closestFarmedThing)
              else
                return Core.moveToAndInteractWithObject(closestFarmedThing)
              end
            end

            await(visitNodes:pause())
            local farmThing = doFarmThing()
            pausable:alsoPause(farmThing)
            await(farmThing)
            visitNodes:resume()
          end

          Coroutine.waitForDuration(1)
        end
      end)

      return pausable
    end

    local retrieveNextClosestPosition, markPositionAsVisited = retrieveNextPosition()

    local HOW_TO_CLOSE_TO_FLY_TO_NODE = 40

    local function doVisitNodes()
      local pausable, pausableInternal = Pausable.Pausable:new()

      Coroutine.runAsCoroutine(function()
        while true do
          local closestNode = retrieveNextClosestPosition()
          print('closestNode')
          DevTools_Dump(closestNode)
          if closestNode then
            moveToNextNode = Core.moveTo(closestNode, {
              distance = HOW_TO_CLOSE_TO_FLY_TO_NODE,
              additionalStopConditions = function()
                return pausable:hasBeenRequestedToPause() or pausable:isPaused() or pausable:hasStopped()
              end
            })
            await(moveToNextNode)
            if _.hasVisitedNode(closestNode) then
              markPositionAsVisited(closestNode)
            end

            pausableInternal:pauseIfHasBeenRequestedToPause()
          end

          Coroutine.yieldAndResume()
        end
      end)

      return pausable
    end

    function _.doHandleEventOfCharacterBeingAttacked()
      local stoppable, stoppableInternal = Stoppable.Stoppable:new()

      Coroutine.runAsCoroutine(function()
        while stoppable:isRunning() do
          local attackers = Array.filter(Core.retrieveObjectPointers(), Core.isUnitAttackingTheCharacter)
          local isThereAnAttacker = Array.hasElements(attackers)
          if isThereAnAttacker then
            await(Resolvable.all(
              {
                lookForThings:pause(),
                visitNodes:pause()
              }
            ))
            await(_.handleAttackers())
            lookForThings:resume()
            visitNodes:resume()
          end

          Coroutine.yieldAndResume()
        end
      end)

      return stoppable
    end

    function _.hasVisitedNode(node)
      local characterPosition = Core.retrieveCharacterPosition()
      return Core.calculateDistanceBetweenPositions(characterPosition, node) <= HOW_TO_CLOSE_TO_FLY_TO_NODE
    end

    function _.retrieveAttackers()
      return Array.filter(Core.retrieveObjectPointers(), Core.isUnitAttackingTheCharacter)
    end

    function _.retrieveClosestAttacker()
      return Array.min(_.retrieveAttackers(), Core.calculateDistanceFromCharacterToObject)
    end

    function _.handleAttackers()
      local resolvable, resolvableInternal = Resolvable.Resolvable:new()

      Coroutine.runAsCoroutine(function()
        local closestAttacker = _.retrieveClosestAttacker()
        while closestAttacker do
          await(Core.doMob(closestAttacker))

          Coroutine.yieldAndResume()

          closestAttacker = _.retrieveClosestAttacker()
        end
        resolvableInternal:resolve()
      end)

      return resolvable
    end

    lookForThings = doLookForThings()
    stoppable:alsoStop(lookForThings)
    visitNodes = doVisitNodes()
    stoppable:alsoStop(visitNodes)
    local doHandleEventOfCharacterBeingAttacked = _.doHandleEventOfCharacterBeingAttacked()
    stoppable:alsoStop(doHandleEventOfCharacterBeingAttacked)
  end)

  return stoppable
end

function Bot.Farming.retrieveNextPosition(retrieveAllPositions)
  local positions = retrieveAllPositions()
  local stillToVisit = Set:new(positions)

  local function retrieveNextClosestPosition()
    local closestPosition = nil
    local distanceToClosestPosition = nil
    local characterPosition = Core.retrieveCharacterPosition()
    for position in stillToVisit:iterator() do
      local distance = Core.calculateDistanceBetweenPositions(characterPosition, position)
      if distanceToClosestPosition == nil or distance < distanceToClosestPosition then
        closestPosition = position
        distanceToClosestPosition = distance
      end
    end
    return closestPosition
  end

  local function markAsVisited(position)
    stillToVisit:remove(position)

    if stillToVisit:isEmpty() then
      stillToVisit = Set:new(positions)
    end
  end

  return retrieveNextClosestPosition, markAsVisited
end
