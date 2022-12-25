Movement = Movement or {}
Movement.Dragonriding = {}

local SKYWARD_ASCENT_SPELL_ID = 372610
local SURGE_FORWARD = 372608
local WHIRLING_SURGE = 361584

-- TODO: Does it work correctly (in terms that the pitch and yaw are correctly considered)?
function Movement.Dragonriding.areConditionsMetForFlyingHigher(targetPoint)
  return SpellCasting.canBeCasted(SKYWARD_ASCENT_SPELL_ID) and Movement.Dragonriding.isObstacleInFrontOfCharacter(targetPoint)
end

function Movement.Dragonriding.isObstacleInFrontOfCharacter(targetPoint)
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
	return SpellCasting.canBeCasted(SURGE_FORWARD) and not Movement.isObstacleInFrontOfCharacter(30)
end

function Movement.Dragonriding.surgeForward()
  Core.castSpellByID(SURGE_FORWARD)
end

function Movement.Dragonriding.areConditionsMetForWhirlingSurge()
	return SpellCasting.canBeCasted(WHIRLING_SURGE) and not Movement.isObstacleInFrontOfCharacter(45)
end

function Movement.Dragonriding.whirlingSurge()
  Core.castSpellByID(WHIRLING_SURGE)
end
