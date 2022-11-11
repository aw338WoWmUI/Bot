Questing = Questing or {}
Questing.Coroutine = {}

function Questing.Coroutine.moveTo(point, distance)
  distance = distance or INTERACT_DISTANCE

  local function hasArrived()
    return GMR.IsPlayerPosition(point.x, point.y, point.z, distance)
  end

  while GMR.IsExecuting() and not hasArrived() do
    if isIdle() then
      GMR.Questing.MoveTo(point.x, point.y, point.z)
      waitFor(function()
        return hasArrived() or isIdle()
      end)
    else
      yieldAndResume()
    end
  end
end

function Questing.Coroutine.interactWithAt(x, y, z, objectID, distance, delay)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(x, y, z, distance) then
    local point = createPoint(x, y, z)
    Questing.Coroutine.moveTo(point, distance)
  end

  if GMR.IsExecuting() then
    GMR.Questing.InteractWith(
      x,
      y,
      z,
      objectID,
      delay or nil,
      distance
    )
  end
end

function Questing.Coroutine.doMob(x, y, z, objectID)
  local distance = GMR.GetCombatRange()

  if not GMR.IsPlayerPosition(x, y, z, distance) then
    local point = createPoint(x, y, z)
    Questing.Coroutine.moveTo(point, distance)
  end

  if GMR.IsExecuting() then
    GMR.Questing.KillEnemy(x, y, z, objectID)
  end
end
