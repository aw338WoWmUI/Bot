Movement = Movement or {}
Movement.Dragonriding = {}

-- TODO: Does it work correctly (in terms that the pitch and yaw are correctly considered)?
function Movement.Dragonriding.areConditionsMetForFlyingHigher(targetPoint)
  if not Movement.Dragonriding.isAPointAvailable() then
    return false
  end

  local distance = math.min(15, Core.calculateDistanceFromCharacterToPosition(targetPoint))
  return Movement.isObstacleInFrontOfCharacter(distance)
end

function Movement.Dragonriding.flyHigher()
  Movement.Dragonriding.castSkywardAscent()
end

function Movement.Dragonriding.liftUp()
  HWT.SetPitch(0)
  Movement.Dragonriding.castSkywardAscent()
  Coroutine.waitForDuration(1.5)
end

function Movement.Dragonriding.castSkywardAscent()
  local SKYWARD_ASCENT_SPELL_ID = 372610
  Core.castSpellByID(SKYWARD_ASCENT_SPELL_ID)
end

function Movement.Dragonriding.faceDirection(yaw, pitch, action)
  Movement.faceDirection(yaw, pitch, function()
    return action.isDone() or action.shouldCancel()
  end)
end

function Movement.Dragonriding.faceWaypoint(waypoint, action)
  local pitch

  local yaw, pitchFromCharacterToWaypoint = Movement.calculateAnglesFromCharacterToPoint(waypoint)
  if Core.calculate2DDistanceFromCharacterToPosition(waypoint) > 10 then
    pitch = math.rad(-5)
  else
    pitch = pitchFromCharacterToWaypoint
  end

  Movement.Dragonriding.faceDirection(yaw, pitch, action)
end

function Movement.Dragonriding.areConditionsMetForSurgeForward()
	return Movement.Dragonriding.isAPointAvailable() and not Movement.isObstacleInFrontOfCharacter(30)
end

function Movement.Dragonriding.areNumberOfPointsAvailable(amount)
  return C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460).numFullFrames >= amount
end

function Movement.Dragonriding.isAPointAvailable()
  return Movement.Dragonriding.areNumberOfPointsAvailable(1)
end

function Movement.Dragonriding.surgeForward()
	local SURGE_FORWARD = 372608
  Core.castSpellByID(SURGE_FORWARD)
end

function Movement.Dragonriding.areConditionsMetForWhirlingSurge()
	return Movement.Dragonriding.areNumberOfPointsAvailable(3) and not Movement.isObstacleInFrontOfCharacter(45)
end

function Movement.Dragonriding.whirlingSurge()
	local WHIRLING_SURGE = 361584
  Core.castSpellByID(WHIRLING_SURGE)
end
