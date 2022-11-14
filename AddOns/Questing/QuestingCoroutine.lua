Questing = Questing or {}
Questing.Coroutine = {}

local function moveTo(to)
  local from = Movement.retrievePlayerPosition()
  local pathFinder = Movement.createPathFinder()
  local path = pathFinder.start(from, to)
  Movement.path = path
  local pathMover = Movement.movePath(path)
  waitFor(function()
    return pathMover.hasStopped()
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

  while GMR.IsExecuting() and not hasArrived() do
    if isIdle() then
      moveTo(point)
      waitFor(function()
        return hasArrived() or isIdle()
      end)
    else
      yieldAndResume()
    end
  end

  if GMR.IsExecuting() then
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

  local function isJobDone(position)
    return not GMR.ObjectExists(pointer) or GMR.IsPlayerPosition(position.x, position.y, position.z, distance)
  end

  -- GMR.GetVendorPath()
  -- GMR.VendorPathHandler()

  local position = retrievePosition()

  while GMR.IsExecuting() and not isJobDone(position) do
    if isIdle() then
      position = retrievePosition()

      moveTo(position)
      waitFor(function()
        return isJobDone(position) or isIdle()
      end)
    else
      yieldAndResume()
    end
  end

  if GMR.IsExecuting() then
    Movement.stopMoving()
  end
end

function Questing.Coroutine.interactWithAt(point, objectID, distance, delay)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  if GMR.IsExecuting() then
    local pointer = GMR.FindObject(objectID)
    GMR.Interact(pointer)
    waitFor(function()
      return GMR.ObjectExists('npc')
    end, 2)
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

  if GMR.IsExecuting() and GMR.ObjectExists(pointer) then
    print('GMR.Interact', pointer)
    GMR.Interact(pointer)
  end
end

function Questing.Coroutine.useItemOnNPC(point, objectID, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  if GMR.IsExecuting() then
    GMR.Questing.UseItemOnNpc(point.x, point.y, point.z, objectID, itemID, distance)
  end
end

function Questing.Coroutine.useItemOnGround(point, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  if GMR.IsExecuting() then
    GMR.Questing.UseItemOnGround(point.x, point.y, point.z, itemID, distance)
  end
end

local function selectOption(optionToSelect)
  if GMR.IsExecuting() then
    C_GossipInfo.SelectOption(optionToSelect)
  end
end

local function gossipWithObject(pointer, chooseOption)
  local name = GMR.ObjectName(pointer)
  print(name)
  while GMR.IsExecuting() and GMR.ObjectExists(pointer) and GMR.ObjectPointer('npc') ~= pointer do
    Questing.Coroutine.interactWithObject(pointer)
    waitFor(function()
      return GMR.ObjectPointer('npc') == pointer
    end, 2)
  end
  print('aa')
  if GMR.IsExecuting() then
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
        local positionsThatCanStillBeVisited = Array.filter(positionsOnContinent, function (position)
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

function Questing.Coroutine.doMob(point, pointer)
  local distance = GMR.GetCombatRange()
  local objectID = GMR.ObjectId(pointer)

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  local function isJobDone()
    return not GMR.ObjectExists(pointer) or GMR.IsDead(pointer)
  end

  while GMR.IsExecuting() and not isJobDone() do
    if isIdle() then
      GMR.Questing.KillEnemy(point.x, point.y, point.z, objectID)
      waitFor(function()
        return isJobDone() or isIdle()
      end)
    else
      yieldAndResume()
    end
  end
end
