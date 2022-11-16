local receive_server_updates = false

local FIRE_BREATH = 357208
local DISINTEGRATE = nil -- TODO
local AZURE_STRIKE = nil -- TODO
local LIVING_FLAME = nil -- TODO

function GMR.ClassRotation()
  if GMR.IsCastable(FIRE_BREATH) then
    GMR.Cast(FIRE_BREATH) -- TODO: Targeting
  elseif GMR.IsCastable(DISINTEGRATE, 'target') then
    GMR.Cast(DISINTEGRATE)
  elseif GMR.IsCastable(AZURE_STRIKE) and GMR.GetNumEnemies('player', 25) >= 2 then
    GMR.Cast(AZURE_STRIKE)
  elseif GMR.IsCastable(LIVING_FLAME, 'target') then
    GMR.Cast(LIVING_FLAME)
  end
end
