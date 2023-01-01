Bot = Bot or {}
local __, AddOn = ...
local _ = {}

AddOn.draconicCacheCoordinates = {
  { x = 24.2, y = 69.4 },
  { x = 24.3, y = 69.5 },
  { x = 24.6, y = 69.6 },
  { x = 25.2, y = 74.1 },
  { x = 25.8, y = 73.7 },
  { x = 27.2, y = 72.0 },
  { x = 27.6, y = 59.2 },
  { x = 28.3, y = 57.9 },
  { x = 28.3, y = 68.2 },
  { x = 28.9, y = 60.4 },
  { x = 29.4, y = 72.3 },
  { x = 30.1, y = 58.7 },
  { x = 30.8, y = 70.8 },
  { x = 32.3, y = 65.4 },
  { x = 32.3, y = 65.5 },
  { x = 34.3, y = 62.4 },
  { x = 34.4, y = 62.5 },
  { x = 34.4, y = 66.4 },
  { x = 34.5, y = 66.4 },
  { x = 34.5, y = 66.6 },
  { x = 35.4, y = 60.9 },
  { x = 35.5, y = 60.9 },
  { x = 39.2, y = 55.1 },
  { x = 40.7, y = 54.7 },
  { x = 42.8, y = 53.9 },
  { x = 45.0, y = 53.7 },
  { x = 45.4, y = 56.3 },
  { x = 45.4, y = 56.5 },
  { x = 45.8, y = 54.0 },
  { x = 63.2, y = 30.8 },
  { x = 63.2, y = 34.6 },
  { x = 64.4, y = 29.4 },
  { x = 64.4, y = 29.5 },
  { x = 64.5, y = 29.5 },
  { x = 64.6, y = 25.9 },
  { x = 65.6, y = 25.7 },
  { x = 65.8, y = 35.1 },
  { x = 66.1, y = 37.7 },
  { x = 70.0, y = 45.3 },
  { x = 70.3, y = 45.5 },
  { x = 71.2, y = 44.7 },
  { x = 71.3, y = 46.8 },
}

local initializableTogglable = InitializableTogglable.InitializableTogglable:new(function ()
  return Bot.createTogglableFarming(_.retrieveNextDraconicCachePosition, _.findThings)
end)

function Bot.toggleDraconicCacheFarming()
  initializableTogglable:toggle()
end

function _.retrieveAllDraconicCachePositions()
  local positions = Array
    .map(AddOn.draconicCacheCoordinates, function(coordinates)
    return Core.retrieveWorldPositionFromMapPosition(
      { mapID = 2022, x = coordinates.x / 100, y = coordinates.y / 100 },
      Core.retrieveHighestZCoordinate
    )
  end)
    :filter(function(position)
    return position.z ~= nil
  end)

  return positions
end

function _.retrieveNextDraconicCachePosition()
  return Bot.Farming.retrieveNextPosition(_.retrieveAllDraconicCachePositions)
end

function _.findThings()
  return Array.filter(Core.retrieveObjectPointers(), function(pointer)
    return HWT.ObjectId(pointer) == 376580 and Core.retrieveObjectDataDynamicFlags(pointer) == -65536
  end)
end
