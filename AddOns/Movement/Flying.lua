Movement = Movement or {}
Movement.Flying = {}

function Movement.Flying.areConditionsMetForFlyingHigher(targetPoint)
  return Movement.Flying.isThereAnObstacleInFrontOfTheCharacter(targetPoint)
end

function Movement.Flying.isThereAnObstacleInFrontOfTheCharacter(targetPoint)
	local distance = math.min(15, Core.calculateDistanceFromCharacterToPosition(targetPoint))
  return Movement.isObstacleInFrontOfCharacter(distance)
end

function Movement.Flying.flyHigher(targetPoint)
  Core.jumpOrStartAscend()
  Coroutine.waitFor(function ()
    local characterPosition = Core.retrieveCharacterPosition()
    local distance = math.min(15, Core.calculateDistanceBetweenPositions(characterPosition, targetPoint))
    return Movement.thereAreZeroCollisions(characterPosition, Core.retrievePositionBetweenPositions(characterPosition, targetPoint, distance))
  end)
  Core.stopAscending()
end
