local function calculateDistance(a, b)
  return math.sqrt(
    math.pow(b.x - a.x, 2) +
      math.pow(b.y - a.y, 2)
  )
end

local faceSmoothly = GMR.FaceSmoothly
GMR.FaceSmoothly = function(x, y, z)
  local playerPosition = GMR.GetPlayerPosition()
  if (
    GMR.IsPositionUnderwater(playerPosition.x, playerPosition.y, playerPosition.z) or
    GMR.IsPointInTheAir(playerPosition.x, playerPosition.y, playerPosition.z)
  ) then
    if type(x) == 'string' then
      x, y, z = GMR.ObjectPosition(x)
    end

    local distance = calculateDistance(playerPosition, { x = x, y = y })

    if distance > 0.5 then
      GMR.FaceDirection(x, y, z)
    end

    if distance < 0.5 then
      if z < playerPosition.z then
        GMR.SetPitch(-0.5 * PI)
      elseif z > playerPosition.z then
        GMR.SetPitch(0.5 * PI)
      end
    end
  else
    faceSmoothly(x, y, z)
  end
end
