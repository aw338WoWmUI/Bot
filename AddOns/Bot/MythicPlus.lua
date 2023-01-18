local __, AddOn = ...
local _ = {}

local MARK_OF_LIGHTNING = 396369
local MARK_OF_WIND = 396364

HWT.doWhenHWTIsLoaded(function ()
  Draw.Sync(function ()
    if Core.hasCharacterBuff(MARK_OF_LIGHTNING) or Core.hasCharacterBuff(MARK_OF_WIND) then
      local unitTokens = AddOn.retrieveUnitTokens()
      local otherBuff = _.determineOtherBuff()
      if otherBuff then
        local units = Array.filter(unitTokens, function (unitToken)
          return Core.hasUnitBuff(unitToken, otherBuff)
        end)
        Draw.SetColorRaw(0, 1, 0, 1)
        Array.forEach(units, function (unit)
          local position = Core.retrieveObjectPosition(unit)
          if position then
            Draw.Circle(position.x, position.y, position.z, Core.retrieveCharacterBoundingRadius(unit))
          end
        end)
      end
    end
  end)
end)

function _.determineOtherBuff()
	if Core.hasCharacterBuff(MARK_OF_LIGHTNING) then
    return MARK_OF_WIND
  elseif Core.hasCharacterBuff(MARK_OF_WIND) then
    return MARK_OF_LIGHTNING
  else
    return nil
  end
end
