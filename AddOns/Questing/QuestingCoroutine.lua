Questing = Questing or {}
Questing.Coroutine = {}

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
      -- print('isIdle', true)
      GMR.Questing.MoveTo(point.x, point.y, point.z)
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

  local position = retrievePosition()

  while GMR.IsExecuting() and not isJobDone(position) do
    if isIdle() then
      -- print('isIdle', true)
      position = retrievePosition()

      GMR.Questing.MoveTo(position.x, position.y, position.z)
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
    Events.waitForOneOfEvents({ 'GOSSIP_SHOW', 'QUEST_GREETING' }, 1)
  end
end

function Questing.Coroutine.interactWithObject(pointer, distance, delay)
  distance = distance or INTERACT_DISTANCE

  local position = createPoint(GMR.ObjectPosition(pointer))
  if not GMR.IsPlayerPosition(position.x, position.y, position.z, distance) then
    Questing.Coroutine.moveToObject(pointer, distance)
  end

  if GMR.IsExecuting() and GMR.ObjectExists(pointer) then
    local ticker
    ticker = C_Timer.NewTicker(0.1, function ()
      print('GMR.ObjectDynamicFlags(pointer)', GMR.ObjectDynamicFlags(pointer))
      log('GMR.ObjectDynamicFlags(pointer)', GMR.ObjectDynamicFlags(pointer))
    end)
    C_Timer.After(3, function ()
      ticker:Cancel()
    end)
    print('before GMR.Interact(pointer)')
    GMR.Interact(pointer)
    print('after GMR.Interact(pointer)')
    Events.waitForOneOfEvents({ 'GOSSIP_SHOW', 'QUEST_GREETING' }, 1)
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

function Questing.Coroutine.gossipWithAt(point, objectID, optionToSelect)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  if GMR.IsExecuting() then
    gossipWithAt(point.x, point.y, point.z, objectID, optionToSelect)
  end
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
