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

-- TODO: Does it work correctly (in terms that the pitch and yaw are correctly considered)?
function Movement.Dragonriding.areConditionsMetForFlyingHigher(targetPoint)
  return (
    SpellCasting.canBeCasted(SKYWARD_ASCENT_SPELL_ID) and
      Movement.Dragonriding.isObstacleInFrontOfCharacter(targetPoint) and
      _.areEnoughPointsAvailableToReachTargetHeight(targetPoint.z)
  )
end

function _.areEnoughPointsAvailableToReachTargetHeight(targetHeight)
  local characterPosition = Core.retrieveCharacterPosition()
  return Movement.Dragonriding.areAMinimumOfNPointsAvailable(math.ceil((targetHeight - characterPosition.z) / SKYWARD_ASCENT_ASCEND_HEIGHT))
end

function Movement.Dragonriding.isObstacleInFrontOfCharacter(targetPoint)
  local distance = math.min(15, Core.calculateDistanceFromCharacterToPosition(targetPoint))
  return Movement.isObstacleInFrontOfCharacter(distance)
end

function Movement.Dragonriding.flyHigher()
  Movement.Dragonriding.liftUp()
end

function Movement.Dragonriding.liftUp()
  HWT.SetPitch(0)
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
  if Movement.thereAreZeroCollisions(characterPosition, waypoint) then
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
      not Movement.isObstacleInFrontOfCharacter(30)
  )
end

function Movement.Dragonriding.surgeForward()
  Core.castSpellByID(SURGE_FORWARD)
end

function Movement.Dragonriding.areConditionsMetForWhirlingSurge()
  return (
    SpellCasting.canBeCasted(WHIRLING_SURGE) and
      Movement.Dragonriding.areEnoughPointsAvailableForSpell(WHIRLING_SURGE_COST) and
      not Movement.isObstacleInFrontOfCharacter(45)
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

function Movement.Dragonriding.retrieveNumberOfPoints()
	return C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460).numFullFrames
end

function Movement.Dragonriding.areAMinimumOfNPointsAvailable(n)
	return Movement.Dragonriding.retrieveNumberOfPoints() >= n
end

function Movement.Dragonriding.areEnoughPointsAvailableForSpell(cost)
	return Movement.Dragonriding.areAMinimumOfNPointsAvailable(cost + NUMBER_OF_POINTS_TO_SAVE_FOR_SKYWARD_ASCENT)
end
