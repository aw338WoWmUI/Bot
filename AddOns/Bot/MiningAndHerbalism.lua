Bot = Bot or {}
local __, AddOn = ...
local _ = {}

AA = _

-- /script Bot.toggleAssistedMiningAndHerbalism()

-- /script AA.retrieveAllPositions()

local initializableTogglable2 = InitializableTogglable.InitializableTogglable:new(function()
  return Bot.createTogglableAssistedFarming(_.retrieveNextPosition, _.findThings)
end)

function Bot.toggleAssistedMiningAndHerbalism()
  initializableTogglable2:toggle()
end

function _.retrieveNextPosition()
  return Bot.Farming.retrieveNextPosition(_.retrieveAllPositions)
end

function _.retrieveAllPositions()
  local positions = {}

  if _G.miningAndHerbalismPositions then
    for positionString in pairs(_G.miningAndHerbalismPositions) do
      table.insert(positions, Core.WorldPosition.fromString(positionString))
    end
  end

  --local mapIDs = {
  --  2022,
  --  2023,
  --  2024,
  --  2025
  --}
  --local professions = { 'Mining', 'Herbalism' }
  --
  --local yielder = Yielder.createYielderWithTimeTracking()
  --
  --Array.forEach(mapIDs, function(mapID)
  --  Array.forEach(professions, function(profession)
  --    Array.append(positions, _.retrieveGatherMateData(mapID, profession))
  --    yielder:yieldAndResumeWhenHasRunOutOfTime()
  --  end)
  --end)

  if miningAndHerbalismSkipSet then
    positions = Array.filter(positions, function(position)
      return not miningAndHerbalismSkipSet[position:toString()]
    end)
  end

  return positions
end

function _.retrieveGatherMateData(mapID, profession)
  local positions = {}

  for node in GatherMate2:GetNodesForZone(mapID, profession) do
    local x, y = GatherMate2:DecodeLoc(node)
    local position = Core.retrieveWorldPositionFromMapPosition({ mapID = mapID, x = x, y = y })
    table.insert(positions, position)
  end

  return positions
end

local CHEST_CLOSED = -65536

function _.findThings()
  local objects = Core.retrieveObjectPointers()
  return Array.filter(objects, function(object)
    local objectID = HWT.ObjectId(object)
    return (
      Set.contains(AddOn.miningObjects, objectID) or
        Set.contains(AddOn.herbalismObjects, objectID)
    ) and Core.retrieveObjectDataDynamicFlags(object) == CHEST_CLOSED and (not miningAndHerbalismSkipSet or not miningAndHerbalismSkipSet[Core.retrieveObjectPosition(object):toString()])
  end)
end

local MAXIMUM_FOLLOW_DISTANCE = 30

function Bot.farmAlong()
  if not BotOptions.mainCharacter then
    error("Please set the main character via: `/script BotOptions.mainCharacter = '<main character name>'`")
  end

  local isAutoFollowing = false

  Events.listenForEvent('AUTOFOLLOW_BEGIN', function()
    isAutoFollowing = true
  end)

  Events.listenForEvent('AUTOFOLLOW_END', function()
    isAutoFollowing = false
  end)

  Coroutine.runAsCoroutineImmediately(function()
    while true do
      if not UnitInVehicle('player') then
        local thing = nil
        repeat
          local things = _.findThings()
          thing = Array.find(things, function(thing)
            return Core.calculateDistanceFromCharacterToObject(thing) <= Core.INTERACT_DISTANCE
          end)
          if thing then
            print(3)
            await(Core.moveToAndInteractWithObject(thing))
            Coroutine.waitForDuration(1)
          end
        until not thing

        if Core.isAlive(BotOptions.mainCharacter) then
          if HWT.UnitIsMounted(BotOptions.mainCharacter) and not Core.isCharacterInCombat() then
            print(1)
            await(Core.moveToAndInteractWithObject(BotOptions.mainCharacter))
          else
            if not isAutoFollowing then
              print(2)
              if Core.calculateDistanceFromCharacterToObject(BotOptions.mainCharacter) <= MAXIMUM_FOLLOW_DISTANCE then
                FollowUnit(BotOptions.mainCharacter)
              else
                -- FIXME
                -- await(Core.moveToObject(Core.retrieveObjectPointer(BotOptions.mainCharacter)))
              end
            end
          end
        end
      end

      Coroutine.yieldAndResume()
    end
  end)
end
