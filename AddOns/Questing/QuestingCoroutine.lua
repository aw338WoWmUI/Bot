Questing = Questing or {}
Questing.Coroutine = {}

local function moveTo(to, hasArrived)
  local from = Movement.retrievePlayerPosition()
  local pathFinder = Movement.createPathFinder()
  local path = pathFinder.start(from, to)
  Movement.path = path
  local pathMover = Movement.movePath(path, function ()
    return not Questing.isRunning() or (hasArrived and hasArrived())
  end)
end

function Questing.Coroutine.moveTo(point, distance)
  distance = distance or INTERACT_DISTANCE

  if Movement.isPositionInTheAir(point) and not Movement.canCharacterFly() then
    point = createPoint(
      point.x,
      point.y,
      Movement.retrieveGroundZ(point) or point.z
    )
  end

  local function hasArrived()
    return GMR.IsPlayerPosition(point.x, point.y, point.z, distance)
  end

  while Questing.isRunning() and not hasArrived() do
    if isIdle() then
      moveTo(point, hasArrived)
      waitFor(function()
        return hasArrived() or isIdle()
      end)
    else
      yieldAndResume()
    end
  end

  if Questing.isRunning() then
    Movement.stopMoving()
  end
end

function Questing.Coroutine.moveToObject(pointer, distance)
  distance = distance or INTERACT_DISTANCE

  local function retrievePosition()
    local position = createPoint(GMR.ObjectPosition(pointer))

    if Movement.isPositionInTheAir(position) and not Movement.canCharacterFly() then
      position = createPoint(
        position.x,
        position.y,
        Movement.retrieveGroundZ(position) or position.z
      )
    end

    return position
  end

  local function isJobDone()
    if not GMR.ObjectExists(pointer) then
      return true
    else
      local position = retrievePosition()
      return GMR.IsPlayerPosition(position.x, position.y, position.z, distance)
    end
  end

  while Questing.isRunning() and not isJobDone() do
    if isIdle() then
      local position = retrievePosition()
      moveTo(position)
      waitFor(function()
        return isJobDone() or isIdle()
      end)
    else
      yieldAndResume()
    end
  end

  if Questing.isRunning() then
    Movement.stopMoving()
  end
end

function Questing.Coroutine.interactWithAt(point, objectID, distance, delay)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  if Questing.isRunning() then
    local pointer = GMR.FindObject(objectID)
    if pointer then
      if IsMounted() then
        GMR.Dismount()
      end
      GMR.Interact(pointer)
      waitForDuration(2)
    end
  end
end

function Questing.Coroutine.interactWithObjectWithObjectID(objectID, distance, delay)
  local pointer = GMR.FindObject(objectID)
  print('pointer', pointer)
  if pointer then
    Questing.Coroutine.interactWithObject(pointer, distance, delay)
  end
end

function Questing.Coroutine.interactWithObject(pointer, distance, delay)
  distance = distance or INTERACT_DISTANCE

  local position = createPoint(GMR.ObjectPosition(pointer))
  if not GMR.IsPlayerPosition(position.x, position.y, position.z, distance) then
    Questing.Coroutine.moveToObject(pointer, distance)
  end

  if Questing.isRunning() and GMR.ObjectExists(pointer) then
    if IsMounted() then
      GMR.Dismount()
    end
    GMR.Interact(pointer)
    waitForDuration(2)
  end
end

function Questing.Coroutine.useItemOnNPC(point, objectID, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  if Questing.isRunning() then
    GMR.Questing.UseItemOnNpc(point.x, point.y, point.z, objectID, itemID, distance)
  end
end

function Questing.Coroutine.useItemOnGround(point, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  if Questing.isRunning() then
    GMR.Questing.UseItemOnGround(point.x, point.y, point.z, itemID, distance)
  end
end

function Questing.Coroutine.useItemOnPosition(position, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(position.x, position.y, position.z, distance) then
    Questing.Coroutine.moveTo(position, distance)
  end

  Questing.Coroutine.useItem(itemID)
end

function Questing.Coroutine.useItem(itemID)
  if Questing.isRunning() then
    local playerPosition = Movement.retrievePlayerPosition()
    GMR.Questing.UseItemOnPosition(playerPosition.x, playerPosition.y, playerPosition.z, itemID)
  end
end

local function selectOption(optionToSelect)
  if Questing.isRunning() then
    C_GossipInfo.SelectOption(optionToSelect)
  end
end

local function gossipWithObject(pointer, chooseOption)
  local name = GMR.ObjectName(pointer)
  print(name)
  while Questing.isRunning() and GMR.ObjectExists(pointer) and GMR.ObjectPointer('npc') ~= pointer do
    Questing.Coroutine.interactWithObject(pointer)
    waitFor(function()
      return GMR.ObjectPointer('npc') == pointer
    end, 2)
  end
  print('aa')
  if Questing.isRunning() then
    local gossipOptionID = chooseOption()
    if gossipOptionID then
      selectOption(gossipOptionID)
    end
  end
end

local function gossipWithObjectWithObjectID(objectID, chooseOption)
  local objectPointer = GMR.FindObject(objectID)

  print('objectPointer', objectPointer, objectID)

  if objectPointer then
    gossipWithObject(objectPointer, chooseOption)
  else
    local npc = Questing.Database.retrieveNPC(objectID)
    if npc and npc.coordinates and next(npc.coordinates) then
      local positions = Array.map(npc.coordinates, function(coordinates)
        return Questing.convertMapPositionToWorldPosition(coordinates)
      end)
      local continentID = select(8, GetInstanceInfo())
      local positionsOnContinent = Array.filter(positions, function(position)
        return position.continentID == continentID
      end)
      local visitedPositions = Set.create()

      local function findClosestPositionThatCanStillBeVisited()
        local positionsThatCanStillBeVisited = Array.filter(positionsOnContinent, function(position)
          return not visitedPositions[position]
        end)
        return Array.min(positionsThatCanStillBeVisited, function(position)
          return GMR.GetDistanceToPosition(position.x, position.y, position.z)
        end)
      end

      local closestPosition = findClosestPositionThatCanStillBeVisited()
      while closestPosition do
        Questing.Coroutine.moveTo(closestPosition)
        visitedPositions:add(closestPosition)
        local objectPointer = GMR.FindObject(objectID)
        if objectPointer then
          gossipWithObject(objectPointer, chooseOption)
          break
        else
          closestPosition = findClosestPositionThatCanStillBeVisited()
        end
      end
    end
  end
end

function Questing.Coroutine.gossipWith(objectID, optionToSelect)
  gossipWithObjectWithObjectID(objectID, Function.returnValue(optionToSelect))
end

function Questing.Coroutine.gossipWithAndSelectOneOfOptions(objectID, options)
  options = Set.create(options)
  gossipWithObjectWithObjectID(objectID, function()
    local availableOptions = C_GossipInfo.GetOptions()
    local option = Array.find(availableOptions, function(option)
      return options[option.gossipOptionID]
    end)
    if option then
      return option.gossipOptionID
    else
      return nil
    end
  end)
end

function Questing.Coroutine.gossipWithAt(point, objectID, optionToSelect)
  Questing.Coroutine.interactWithAt(point, objectID)
  selectOption(optionToSelect)
end

function Questing.Coroutine.doMob(pointer)
  local distance = GMR.GetCombatRange()
  local objectID = GMR.ObjectId(pointer)

  local function isJobDone()
    return not GMR.ObjectExists(pointer) or GMR.IsDead(pointer)
  end

  while Questing.isRunning() and not isJobDone() do
    if isIdle() then
      local position = createPoint(GMR.ObjectPosition(pointer))
      if not GMR.IsPlayerPosition(position.x, position.y, position.z, distance) then
        Questing.Coroutine.moveToObject(pointer, distance)
      end

      if IsMounted then
        GMR.Dismount()
      end
      GMR.TargetObject(pointer)
      GMR.StartAttack()
      waitFor(function()
        return isJobDone() or isIdle()
      end)
    else
      yieldAndResume()
    end
  end

  print('--- Questing.Coroutine.doMob')
end
