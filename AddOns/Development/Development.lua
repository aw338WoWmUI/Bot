Development = {}

function Development.logObjectInfo(name)
  name = name or GameTooltipTextLeft1:GetText()
  local objects = Core.retrieveObjects()
  local object = Array.min(
    Array.filter(
      objects,
      function(object)
        return Core.retrieveObjectName(object.pointer) == name
      end
    ),
    function(object)
      return Core.retrieveDistanceBetweenObjects('player', object.pointer)
    end
  )
  if object then
    Logging.logToFile(Core.retrieveCurrentContinentID() .. ',\n' .. object.x .. ',\n' .. object.y .. ',\n' .. object.z .. ',\n' .. object.objectID)
  end
end
