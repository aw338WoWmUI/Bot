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
end

function Questing.Coroutine.interactWithAt(point, objectID, distance, delay)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, distance)
  end

  if GMR.IsExecuting() then
    GMR.Questing.InteractWith(
      point.x,
      point.y,
      point.z,
      objectID,
      delay or nil,
      distance
    )
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
