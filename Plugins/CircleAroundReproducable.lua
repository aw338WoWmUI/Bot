function reproduceCirclingAround()
  local playerPosition = GMR.GetPlayerPosition()
  local angle = GMR.ObjectRawFacing('player') + PI
  local tx, ty, tz = GMR.GetPositionFromPosition(playerPosition.x, playerPosition.y, playerPosition.z, 4, angle, 0)
  GMR.Mesh(tx, ty, tz)
end
