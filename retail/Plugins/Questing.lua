function useExtraActionButton1()
  local playerPosition = GMR.GetPlayerPosition()
  if GMR.IsFlyingMount(GMR.GetMount()) then
    local z = GMR.GetZCoordinate(playerPosition.x, playerPosition.y)
    local destination = {
      x = playerPosition.x,
      y = playerPosition.y,
      z = z
    }

    if GMR.IsPlayerPosition(destination.x, destination.y, destination.z, 3) then
      GMR.Dismount()
    end

    GMR.Questing.ExtraActionButton1(destination.x, destination.y, destination.z)
  else
    GMR.Questing.ExtraActionButton1(playerPosition.x, playerPosition.y, playerPosition.z)
  end
end
