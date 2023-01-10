Bot = Bot or {}
Bot.Farming = Bot.Farming or {}
local _ = {}

local farmedThing = nil
local nextNode = nil

function Bot.createTogglableFarming(retrieveNextPosition, findFarmedThings)
  return _.createTogglableFarming(function()
    return Bot.startFarming(retrieveNextPosition, findFarmedThings)
  end)
end

function Bot.createTogglableAssistedFarming(retrieveNextPosition, findFarmedThings)
  return _.createTogglableFarming(function()
    return Bot.startAssistedFarming(retrieveNextPosition, findFarmedThings)
  end)
end

function _.createTogglableFarming(createFarming)
  local togglable = Togglable.Togglable:new(function()
    local stoppable, stoppableInternal = Stoppable.Stoppable:new()

    local assistedFarming = createFarming()
    stoppable:alsoStop(assistedFarming)

    local visualization = _.visualize()
    stoppable:alsoStop(visualization)

    return stoppable
  end)

  return togglable
end

function _.visualize()
  local stoppable, stoppableInternal = Stoppable.Stoppable:new()

  local handle = Draw.Sync(function()
    if farmedThing then
      local characterPosition = Core.retrieveCharacterPosition()
      local position = Core.retrieveObjectPosition(farmedThing)
      if position and position.continentID == Core.retrieveCurrentContinentID() then
        Draw.SetColorRaw(0, 1, 0, 1)
        Draw.Circle(position.x, position.y, position.z, 3)
        Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
      end
    end

    if nextNode and nextNode.continentID == Core.retrieveCurrentContinentID() then
      local characterPosition = Core.retrieveCharacterPosition()
      local position = nextNode
      Draw.SetColorRaw(0, 0, 1, 1)
      Draw.Circle(position.x, position.y, position.z, 3)
      Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
    end
  end)

  stoppable:onStop(function()
    handle:cancel()
  end)

  return stoppable
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
        while not pausable:hasBeenRequestedToStop() do
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
            pausable:alsoStop(farmThing)
            pausable:alsoPause(farmThing)
            print(4)
            await(farmThing)
            farmedThing = nil
            print(5)
            visitNodes:resume()
            print(6)
          end

          pausableInternal:pauseIfHasBeenRequestedToPause()

          Coroutine.yieldAndResume()
        end

        pausableInternal:resolve()
      end)

      return pausable
    end

    local retrieveNextClosestPosition, markPositionAsVisited, skipPosition = retrieveNextPosition()

    local function doVisitNodes()
      local pausable, pausableInternal = Pausable.Pausable:new()

      Coroutine.runAsCoroutine(function()
        while not pausable:hasBeenRequestedToStop() do
          local closestNode = retrieveNextClosestPosition()
          if closestNode then
            nextNode = closestNode
            moveToNextNode = Core.moveTo(closestNode, {
              distance = HOW_TO_CLOSE_TO_FLY_TO_NODE,
              additionalStopConditions = function()
                return pausable:hasBeenRequestedToPause() or pausable:hasBeenRequestedToStop() or pausable:isPaused() or pausable:hasStopped()
              end
            })
            await(moveToNextNode)
            nextNode = nil
            if _.hasVisitedNode(closestNode) then
              markPositionAsVisited(closestNode)
            else
              skipPosition(closestNode)
            end
          end

          print('p1')
          pausableInternal:pauseIfHasBeenRequestedToPause()
          print('p2')

          Coroutine.yieldAndResume()
        end

        pausableInternal:resolve()
      end)

      return pausable
    end

    function _.doHandleEventOfCharacterBeingAttacked()
      local stoppable, stoppableInternal = Stoppable.Stoppable:new()

      Coroutine.runAsCoroutine(function()
        while not stoppable:hasBeenRequestedToStop() do
          local attackers = Array.filter(Core.retrieveObjectPointers(), Core.isUnitAttackingTheCharacter)
          local isThereAnAttacker = Array.hasElements(attackers)
          if isThereAnAttacker then
            print('combat 1')
            await(Resolvable.all(
              {
                lookForThings:pause(),
                visitNodes:pause()
              }
            ))
            print('combat 2')
            await(_.handleAttackers())
            print('combat 3')
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

  Coroutine.runAsCoroutine(function()
    local retrieveNextClosestPosition, markPositionAsVisited = retrieveNextPosition()

    while not stoppable:hasBeenRequestedToStop() do
      if nextNode and Core.isCharacterAtMaxAwayFrom(nextNode, HOW_TO_CLOSE_TO_FLY_TO_NODE) then
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
        farmedThing = closestFarmedThing
        if not positions then
          positions = {}
        end
        if Core.isGameObject(farmedThing) then
          positions[Core.retrieveObjectPosition(farmedThing):toString()] = true
        end
      else
        if not nextNode then
          nextNode = retrieveNextClosestPosition()
        end
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

function Bot.addToMiningAndHerbalismSkipSet()
  if farmedThing then
    if not miningAndHerbalismSkipSet then
      miningAndHerbalismSkipSet = {}
    end
    miningAndHerbalismSkipSet[Core.retrieveObjectPosition(farmedThing):toString()] = true
  end
end

function Bot.Farming.retrieveNextPosition(retrieveAllPositions, skipSet)
  local positions = retrieveAllPositions()
  local stillToVisit = {}

  local function fillStillToVisitWithPositionsToVisit()
    Array.forEach(positions, function(position)
      local positionString = position:toString()
      if not skipSet[positionString] then
        stillToVisit[positionString] = true
      end
    end)
  end

  fillStillToVisitWithPositionsToVisit()

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

  local function removePositionFromStillToVisit(position)
    stillToVisit[position:toString()] = nil

    if Object.isEmpty(stillToVisit) then
      stillToVisit = {}
      fillStillToVisitWithPositionsToVisit()
    end
  end

  local function markAsVisited(position)
    removePositionFromStillToVisit(position)

    if not visitedNodes then
      visitedNodes = {}
    end
    visitedNodes[position:toString()] = time()
  end

  local function skipPosition(position)
    skipSet[position:toString()] = true

    removePositionFromStillToVisit(position)
  end

  return retrieveNextClosestPosition, markAsVisited, skipPosition
end

function Bot.defineIndoorEntry()
  local position = Core.retrieveCharacterPosition()
  if not indoorEntries then
    indoorEntries = {}
  end
  table.insert(indoorEntries, position:toString())
end

function Bot.associateNodeWithClosestIndoorEntry()
  if farmedThing then
    local closestIndoorEntry = _.findClosestIndoorEntry()
    if closestIndoorEntry then
      local position = Core.retrieveObjectPosition(farmedThing)
      if position then
        if not positionsToIndoorEntries then
          positionsToIndoorEntries = {}
        end
        positionsToIndoorEntries[position:toString()] = closestIndoorEntry:toString()
      end
    end
  end
end

function _.findClosestIndoorEntry()
  if indoorEntries then
    return Core.WorldPosition.fromString(Array.min(indoorEntries, function(indoorEntry)
      return Core.calculateDistanceFromCharacterToPosition(Core.WorldPosition.fromString(indoorEntry))
    end))
  else
    return nil
  end
end

HWT.doWhenHWTIsLoaded(function()
  Draw.Sync(function()
    local indoorEntry = _.findClosestIndoorEntry()
    if indoorEntry and indoorEntry.continentID == Core.retrieveCurrentContinentID() and Core.calculateDistanceFromCharacterToPosition(indoorEntry) <= 100 then
      Draw.SetColorRaw(1, 0.5, 0, 1)
      Draw.Circle(indoorEntry.x, indoorEntry.y, indoorEntry.z, 0.5)
    end

    if farmedThing then
      local position = Core.retrieveObjectPosition(farmedThing)
      if position then
        local indoorEntryPositionString = positionsToIndoorEntries[position:toString()]
        if indoorEntryPositionString then
          local indoorEntry = Core.WorldPosition.fromString(indoorEntryPositionString)
          Draw.SetColorRaw(1, 0.5, 0, 1)
          Draw.Circle(indoorEntry.x, indoorEntry.y, indoorEntry.z, 0.5)
          Draw.Line(position.x, position.y, position.z, indoorEntry.x, indoorEntry.y, indoorEntry.z)
        end
      end
    end
  end)
end)
