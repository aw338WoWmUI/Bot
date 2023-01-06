Bot = Bot or {}
Bot.Farming = Bot.Farming or {}
local _ = {}

local farmedThing = nil
local nextNode = nil

function Bot.createTogglableFarming(retrieveNextPosition, findFarmedThings)
  local togglable = Togglable.Togglable:new(function()
    return Bot.startFarming(retrieveNextPosition, findFarmedThings)
  end)

  _.visualize()

  return togglable
end

function Bot.createTogglableAssistedFarming(retrieveNextPosition, findFarmedThings)
  local togglable = Togglable.Togglable:new(function()
    return Bot.startAssistedFarming(retrieveNextPosition, findFarmedThings)
  end)

  _.visualize()

  return togglable
end

function _.visualize()
  Draw.Sync(function()
    if farmedThing then
      local characterPosition = Core.retrieveCharacterPosition()
      local position = Core.retrieveObjectPosition(farmedThing)
      Draw.SetColorRaw(0, 1, 0, 1)
      Draw.Circle(position.x, position.y, position.z, 3)
      Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
    end

    if nextNode then
      local characterPosition = Core.retrieveCharacterPosition()
      local position = nextNode
      Draw.SetColorRaw(0, 0, 1, 1)
      Draw.Circle(position.x, position.y, position.z, 3)
      Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
    end
  end)
end

local HOW_TO_CLOSE_TO_FLY_TO_NODE = 146

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
              nextNode = nil
              farmedThing = closestFarmedThing
              if Core.canCharacterAttackUnit(closestFarmedThing) then
                return Core.doMob(closestFarmedThing)
              else
                return Core.moveToAndInteractWithObject(closestFarmedThing)
              end
            end

            print(1)
            await(visitNodes:pause())
            print(2)
            local farmThing = doFarmThing()
            print(3)
            pausable:alsoPause(farmThing)
            print(4)
            await(farmThing)
            farmedThing = nil
            print(5)
            visitNodes:resume()
            print(6)
          end

          Coroutine.waitForDuration(1)
        end
      end)

      return pausable
    end

    local retrieveNextClosestPosition, markPositionAsVisited = retrieveNextPosition()

    local function doVisitNodes()
      local pausable, pausableInternal = Pausable.Pausable:new()

      Coroutine.runAsCoroutine(function()
        while true do
          local closestNode = retrieveNextClosestPosition()
          if closestNode then
            nextNode = closestNode
            moveToNextNode = Core.moveTo(closestNode, {
              distance = HOW_TO_CLOSE_TO_FLY_TO_NODE,
              additionalStopConditions = function()
                return pausable:hasBeenRequestedToPause() or pausable:isPaused() or pausable:hasStopped()
              end
            })
            await(moveToNextNode)
            nextNode = nil
            if _.hasVisitedNode(closestNode) then
              markPositionAsVisited(closestNode)
            end
          end

          print('p1')
          pausableInternal:pauseIfHasBeenRequestedToPause()
          print('p2')

          Coroutine.yieldAndResume()
        end
      end)

      return pausable
    end

    function _.doHandleEventOfCharacterBeingAttacked()
      local stoppable, stoppableInternal = Stoppable.Stoppable:new()

      Coroutine.runAsCoroutine(function()
        while stoppable:hasBeenRequestedToStop() do
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

        stoppableInternal:resolve()
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

function Bot.startAssistedFarming(retrieveNextPosition, findFarmedThings)
  local stoppable, stoppableInternal = Stoppable.Stoppable:new()

  local retrieveNextClosestPosition, markPositionAsVisited = retrieveNextPosition()

  Coroutine.runAsCoroutine(function()
    while stoppable:hasBeenRequestedToStop() do
      if nextNode and Core.calculateDistanceFromCharacterToPosition(nextNode) <= HOW_TO_CLOSE_TO_FLY_TO_NODE then
        markPositionAsVisited(nextNode)
        nextNode = nil
      end

      local farmedThings = findFarmedThings()
      if #farmedThings >= 1 then
        local characterPosition = Core.retrieveCharacterPosition()
        local closestFarmedThing = Array.min(farmedThings, function(cache)
          local position = Core.retrieveObjectPosition(cache)
          return Core.calculateDistanceBetweenPositions(characterPosition, position)
        end)

        nextNode = nil
        if farmedThing == nil then
          print('distance', Core.calculateDistanceFromCharacterToObject(closestFarmedThing))
        end
        farmedThing = closestFarmedThing
        if not positions then
          positions = {}
        end
        if Core.isGameObject(farmedThing) then
          positions[Core.retrieveObjectPosition(farmedThing):toString()] = true
        end
      else
        nextNode = retrieveNextClosestPosition()
        farmedThing = nil
      end

      Coroutine.yieldAndResume()
    end

    nextNode = nil
    farmedThing = nil

    stoppableInternal:resolve()
  end)

  return stoppable
end

function Bot.addToSkipSet()
  if farmedThing then
    if not skipSet then
      skipSet = {}
    end
    skipSet[Core.retrieveObjectPosition(farmedThing):toString()] = true
  end
end

function Bot.Farming.retrieveNextPosition(retrieveAllPositions)
  local positions = retrieveAllPositions()
  local stillToVisit = {}
  Array.forEach(positions, function(position)
    stillToVisit[position:toString()] = true
  end)
  if visitedNodes then
    for positionString, visitedTime in pairs(visitedNodes) do
      if time() - visitedTime > 30 * 60 then
        stillToVisit[positionString] = nil
      end
    end

    for positionString, visitedTime in pairs(visitedNodes) do
      if time() - visitedTime > 30 * 60 then
        visitedNodes[positionString] = nil
      end
    end
  end

  local function retrieveNextClosestPosition()
    local closestPosition = nil
    local distanceToClosestPosition = nil
    local characterPosition = Core.retrieveCharacterPosition()
    for positionString in pairs(stillToVisit) do
      local position = Core.WorldPosition.fromString(positionString)
      local distance = Core.calculateDistanceBetweenPositions(characterPosition, position)
      if distanceToClosestPosition == nil or distance < distanceToClosestPosition then
        closestPosition = position
        distanceToClosestPosition = distance
      end
    end
    return closestPosition
  end

  local function markAsVisited(position)
    stillToVisit[position:toString()] = nil

    if Object.isEmpty(stillToVisit) then
      stillToVisit = {}
      Array.forEach(positions, function(position)
        stillToVisit[position:toString()] = true
      end)
    end

    if not visitedNodes then
      visitedNodes = {}
    end
    visitedNodes[position:toString()] = time()
  end

  return retrieveNextClosestPosition, markAsVisited
end