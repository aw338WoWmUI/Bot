local function calculateDistance(a, b)
  return math.sqrt(
    math.pow(b.x - a.x, 2) +
      math.pow(b.y - a.y, 2)
  )
end

local faceSmoothly = GMR.FaceSmoothly
GMR.FaceSmoothly = function(...)
  local args = { ... }
  local x, y, z
  if type(args[1]) == 'string' then
    x, y, z = GMR.ObjectPosition(x)
  else
    x, y, z = args[1], args[2], args[3]
  end

  if x and y and z and not GMR.IsFacingXYZ(x, y, z) then
    local playerPosition = Core.retrieveCharacterPosition()

    local distance = calculateDistance(playerPosition, { x = x, y = y })

    if distance <= 5 then
      GMR.FaceDirection(x, y, z)
      return
    end
  end

  return faceSmoothly(...)
end
