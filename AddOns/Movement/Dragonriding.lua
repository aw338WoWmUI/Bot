Movement = Movement or {}
Movement.Dragonriding = {}
local _ = {}

local NUMBER_OF_POINTS_TO_SAVE_FOR_SKYWARD_ASCENT = 3

local SKYWARD_ASCENT_SPELL_ID = 372610
local SURGE_FORWARD = 372608
local WHIRLING_SURGE = 361584

local SURGE_FORWARD_COST = 1
local WHIRLING_SURGE_COST = 3

local SKYWARD_ASCENT_ASCEND_HEIGHT = 52.485332489014

local LOOK_AHEAD_DISTANCE = 50

-- TODO: Does it work correctly (in terms that the pitch and yaw are correctly considered)?
function Movement.Dragonriding.areConditionsMetForFlyingHigher(targetPoint)
  local characterPosition = Core.retrieveCharacterPosition()
  local result = (
    SpellCasting.canBeCasted(SKYWARD_ASCENT_SPELL_ID) and
      (not IsFlying() or Movement.Dragonriding.isObstacleInFrontOfCharacter(targetPoint)) and
      _.areEnoughPointsAvailableToReachTargetHeight(math.max(targetPoint.z, characterPosition.z + Movement.Dragonriding.measureMountainHeight(targetPoint)))
  )
  if result then
    print('conditions are met for flying higher')
  end
  return result
end

function _.findWayOnTheSide()
  -- TODO: Implement
end

function _.areEnoughPointsAvailableToReachTargetHeight(targetHeight)
  local characterPosition = Core.retrieveCharacterPosition()
  return Movement.Dragonriding.areAMinimumOfNPointsAvailable(math.ceil((targetHeight - characterPosition.z) / SKYWARD_ASCENT_ASCEND_HEIGHT))
end

function Movement.Dragonriding.isObstacleInFrontOfCharacter(targetPoint)
  local characterPosition = Core.retrieveCharacterPosition()
  local position1 = characterPosition
  local distance = math.min(LOOK_AHEAD_DISTANCE, Core.calculate2DDistanceFromCharacterToPosition(targetPoint))
  local position2 = Movement.calculateIsObstacleInFrontToPosition(position1, distance)
  lines = {
    {
      position1,
      position2
    }
  }
  return Movement.thereAreCollisions(position1, position2)
end

function Movement.Dragonriding.flyHigher()
  Movement.Dragonriding.liftUp()
end

function Movement.Dragonriding.liftUp()
  HWT.SetPitch(math.rad(45))
  Movement.Dragonriding.castSkywardAscent()
  Coroutine.waitForDuration(1.5)
end

function Movement.Dragonriding.castSkywardAscent()
  Core.castSpellByID(SKYWARD_ASCENT_SPELL_ID)
end

function Movement.Dragonriding.faceDirection(yaw, pitch, action)
  Movement.faceDirection(yaw, pitch, function()
    return action.isDone() or action.shouldCancel()
  end)
end

function Movement.Dragonriding.updateFacing(waypoint, action)
  local pitch

  local yaw, pitchFromCharacterToWaypoint = Movement.calculateAnglesFromCharacterToPoint(waypoint)
  local characterPosition = Core.retrieveCharacterPosition()
  if Movement.thereAreZeroCollisions(characterPosition, Movement.createPointWithZOffset(waypoint, 0.1)) or
    Core.calculate2DDistanceFromCharacterToPosition(waypoint) <= 5 then
    pitch = pitchFromCharacterToWaypoint
  else
    pitch = math.rad(-5)
  end

  Movement.Dragonriding.faceDirection(yaw, pitch, action)
end

function Movement.Dragonriding.areConditionsMetForSurgeForward()
  return (
    SpellCasting.canBeCasted(SURGE_FORWARD) and
      Movement.Dragonriding.areEnoughPointsAvailableForSpell(SURGE_FORWARD_COST) and
      not Movement.isObstacleInFlyingDirection(Core.retrieveCharacterPosition(), 78.56)
  )
end

function Movement.Dragonriding.surgeForward()
  Core.castSpellByID(SURGE_FORWARD)
end

function Movement.Dragonriding.areConditionsMetForWhirlingSurge()
  return (
    SpellCasting.canBeCasted(WHIRLING_SURGE) and
      Movement.Dragonriding.areEnoughPointsAvailableForSpell(WHIRLING_SURGE_COST) and
      not Movement.isObstacleInFlyingDirection(Core.retrieveCharacterPosition(), 109.62)
  )
end

function Movement.Dragonriding.whirlingSurge()
  Core.castSpellByID(WHIRLING_SURGE)
end

function Movement.Dragonriding.measureSkywardAscentHeight()
  Coroutine.runAsCoroutine(function()
    local zBefore = Core.retrieveCharacterPosition().z
    Movement.Dragonriding.castSkywardAscent()
    local maxZ = zBefore
    local startTime = GetTime()
    local measureLength = 3 -- seconds
    while GetTime() - startTime <= measureLength do
      maxZ = math.max(maxZ, Core.retrieveCharacterPosition().z)
      Coroutine.yieldAndResume()
    end
    local height = maxZ - zBefore
    print('height', height)
    -- results:
    -- 52.485343933105
    -- 52.485332489014
  end)
end

local start
local stop

function Movement.Dragonriding.measureSurgeForwardDistance()
  Coroutine.runAsCoroutine(function()
    if not start then
      start = Core.retrieveCharacterPosition()
      Movement.Dragonriding.surgeForward()
    else
      stop = Core.retrieveCharacterPosition()
      local distance = Core.calculateDistanceBetweenPositions(start, stop)
      print('distance', distance)
    end
  end)
end

function Movement.Dragonriding.measureWhirlingSurgeDistance()
  Coroutine.runAsCoroutine(function()
    if not start then
      start = Core.retrieveCharacterPosition()
      Movement.Dragonriding.whirlingSurge()
    else
      stop = Core.retrieveCharacterPosition()
      local distance = Core.calculateDistanceBetweenPositions(start, stop)
      print('distance', distance)
    end
  end)
end

function Movement.Dragonriding.retrieveNumberOfPoints()
	return C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460).numFullFrames
end

function Movement.Dragonriding.areAMinimumOfNPointsAvailable(n)
	return Movement.Dragonriding.retrieveNumberOfPoints() >= n
end

function Movement.Dragonriding.areEnoughPointsAvailableForSpell(cost)
	return Movement.Dragonriding.areAMinimumOfNPointsAvailable(cost + NUMBER_OF_POINTS_TO_SAVE_FOR_SKYWARD_ASCENT)
end

local MAXIMUM_MOUNTAIN_HEIGHT = 1000

function Movement.Dragonriding.measureMountainHeight(waypoint)
	local length = LOOK_AHEAD_DISTANCE
  local characterPosition = Core.retrieveCharacterPosition()
  for offsetZ = 0, MAXIMUM_MOUNTAIN_HEIGHT, SKYWARD_ASCENT_ASCEND_HEIGHT do
    local z = characterPosition.z + offsetZ
    local a = Core.createWorldPosition(
      characterPosition.continentID,
      characterPosition.x,
      characterPosition.y,
      z
    )
    local b = Core.createWorldPosition(
      waypoint.continentID,
      waypoint.x,
      waypoint.y,
      z
    )
    local b2 = Core.retrievePositionBetweenPositions(a, b, length)
    if Movement.thereAreZeroCollisions(a, b2) then
      return offsetZ
    end
  end

  return nil
end
