Movement = Movement or {}
Movement.Dragonriding = {}

function Movement.Dragonriding.areConditionsMetForFlyingHigher()
  return Movement.isObstacleInFrontOfCharacter(15)
end

function Movement.Dragonriding.flyHigher()
  Movement.Dragonriding.castSkywardAscent()
end

function Movement.Dragonriding.liftUp()
  Movement.Dragonriding.castSkywardAscent()
end

function Movement.Dragonriding.castSkywardAscent()
	local SKYWARD_ASCENT_SPELL_ID = 372610
  Core.castSpellByID(SKYWARD_ASCENT_SPELL_ID)
end

function Movement.Dragonriding.facePoint(point, action)
	Movement.facePoint(point, function()
    return action.isDone() or action.shouldCancel()
  end)
end
