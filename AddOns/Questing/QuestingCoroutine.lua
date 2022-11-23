Questing = Questing or {}
Questing.Coroutine = {}

local _ = {}

local MAXIMUM_OBJECT_LOAD_DISTANCE = 250

local function moveTo(to, options)
  options = options or {}

  Movement.moveTo(to, {
    stop = function()
      return not Questing.isRunning() or (options.hasArrived and options.hasArrived())
    end,
    toleranceDistance = options.toleranceDistance
  })
end

function Questing.Coroutine.moveTo(point, options)
  options = options or {}
  local additionalStopConditions = options.additionalStopConditions
  local distance = options.distance or 1

  local function hasArrived()
    return GMR.IsPlayerPosition(point.x, point.y, point.z,
      distance) or additionalStopConditions and additionalStopConditions()
  end

  Questing.Coroutine.moveToUntil(point, hasArrived)
end

function Questing.Coroutine.moveToUntil(point, stopCondition)
  if Movement.isPositionInTheAir(point) and not Movement.canCharacterFly() then
    point = createPoint(
      point.x,
      point.y,
      Movement.retrieveGroundZ(point) or point.z
    )
  end

  while Questing.isRunning() and not stopCondition() do
    if isIdle() then
      moveTo(point, {
        hasArrived = stopCondition
      })
      waitFor(function()
        return stopCondition() or isIdle()
      end)
    else
      yieldAndResume()
    end
  end

  if Questing.isRunning() then
    Movement.stopMoving()
  end
end

function Questing.Coroutine.moveToObject(pointer, distance)
  distance = distance or INTERACT_DISTANCE

  local function retrievePosition()
    local position = createPoint(GMR.ObjectPosition(pointer))

    if Movement.isPositionInTheAir(position) and not Movement.canCharacterFly() then
      position = createPoint(
        position.x,
        position.y,
        Movement.retrieveGroundZ(position) or position.z
      )
    end

    return position
  end

  local function isJobDone()
    if not GMR.ObjectExists(pointer) then
      return true
    else
      local position = retrievePosition()
      return GMR.IsPlayerPosition(position.x, position.y, position.z, distance)
    end
  end

  while Questing.isRunning() and not isJobDone() do
    if isIdle() then
      local position = retrievePosition()
      moveTo(position, {
        toleranceDistance = distance
      })
      waitFor(function()
        return isJobDone() or isIdle()
      end)
    else
      yieldAndResume()
    end
  end

  if Questing.isRunning() then
    Movement.stopMoving()
  end
end

function Questing.Coroutine.interactWithAt(point, objectID, distance, delay)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, {
      distance = distance
    })
  end

  if Questing.isRunning() then
    local pointer = GMR.FindObject(objectID)
    if pointer then
      --if IsMounted() then
      --  print('GMR.Dismount()')
      --  GMR.Dismount()
      --  Movement.waitForDismounted()
      --end
      GMR.InteractObject(pointer)
      waitForDuration(2)
    end
  end
end

function Questing.Coroutine.interactWithObjectWithObjectID(objectID, options)
  options = options or {}

  local pointer = GMR.FindObject(objectID)

  if not pointer then
    Questing.Coroutine.moveTo(options.fallbackPosition, {
      distance = MAXIMUM_OBJECT_LOAD_DISTANCE,
      additionalStopConditions = function()
        return GMR.FindObject(objectID)
      end
    })
  end

  pointer = GMR.FindObject(objectID)
  print('pointer', pointer)
  if pointer then
    Questing.Coroutine.interactWithObject(pointer, options.distance, options.delay)
  end
end

function Questing.Coroutine.interactWithObject(pointer, distance, delay)
  distance = distance or INTERACT_DISTANCE

  local position = createPoint(GMR.ObjectPosition(pointer))
  if not GMR.IsPlayerPosition(position.x, position.y, position.z, distance) then
    Questing.Coroutine.moveToObject(pointer, distance)
  end

  if Questing.isRunning() and GMR.ObjectExists(pointer) then
    --if IsMounted() then
    --  GMR.Dismount()
    --  Movement.waitForDismounted()
    --end
    print(GMR.ObjectDynamicFlags(pointer), GMR.ObjectFlags(pointer), GMR.ObjectFlags2(pointer))
    GMR.InteractObject(pointer)
    waitFor(function()
      return not UnitCastingInfo('player')
    end)
    print(GMR.ObjectDynamicFlags(pointer), GMR.ObjectFlags(pointer), GMR.ObjectFlags2(pointer))
    return true
  else
    return false
  end
end

function Questing.Coroutine.lootObject(pointer, distance)
  if Questing.Coroutine.interactWithObject(pointer, distance) then
    -- after all items have been looted that can be looted
    if _.thereAreMoreItemsThatCanBeLootedThanThereIsSpaceInBags() then
      _.destroyItemsForLootThatSeemsToMakeMoreSenseToPutInBagInstead()
    end
    local wasSuccessful = Events.waitForEvent('LOOT_CLOSED', 3)
    print('LOOT_CLOSED', wasSuccessful)
    return wasSuccessful
  else
    return false
  end
end

function _.thereAreMoreItemsThatCanBeLootedThanThereIsSpaceInBags()
  return GetNumLootItems() >= 1
end

function _.destroyItemsForLootThatSeemsToMakeMoreSenseToPutInBagInstead()
  -- canBeSoldForMoreGold or quest item > gray item with sell value <= X
  -- GetLootInfo (https://wowpedia.fandom.com/wiki/API_GetLootInfo)
  --   isQuestItem
  --   quantity
  -- GetLootRollItemLink (https://wowpedia.fandom.com/wiki/API_GetLootRollItemLink)
end

function Questing.Coroutine.useItemOnNPC(point, objectID, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, {
      distance = distance
    })
  end

  if Questing.isRunning() then
    GMR.Questing.UseItemOnNpc(point.x, point.y, point.z, objectID, itemID, distance)
  end
end

function Questing.Coroutine.useItemOnGround(point, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(point.x, point.y, point.z, distance) then
    Questing.Coroutine.moveTo(point, {
      distance = distance
    })
  end

  if Questing.isRunning() then
    GMR.Questing.UseItemOnGround(point.x, point.y, point.z, itemID, distance)
  end
end

function Questing.Coroutine.useItemOnPosition(position, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not GMR.IsPlayerPosition(position.x, position.y, position.z, distance) then
    Questing.Coroutine.moveTo(position, {
      distance = distance
    })
  end

  Questing.Coroutine.useItem(itemID)
end

function Questing.Coroutine.useItem(itemID)
  if Questing.isRunning() then
    local playerPosition = Movement.retrievePlayerPosition()
    GMR.Questing.UseItemOnPosition(playerPosition.x, playerPosition.y, playerPosition.z, itemID)
  end
end

local function selectOption(optionToSelect)
  if Questing.isRunning() then
    C_GossipInfo.SelectOption(optionToSelect)
  end
end

local function gossipWithObject(pointer, chooseOption)
  local name = GMR.ObjectName(pointer)
  print(name)
  while Questing.isRunning() and GMR.ObjectExists(pointer) and GMR.ObjectPointer('npc') ~= pointer do
    Questing.Coroutine.interactWithObject(pointer)
    Events.waitForEvent('GOSSIP_SHOW', 2)
    yieldAndResume()
  end
  if Questing.isRunning() then
    local gossipOptionID = chooseOption()
    if gossipOptionID then
      selectOption(gossipOptionID)
    end
  end
end

function Questing.Coroutine.gossipWithObject(pointer, gossipOptionID)
  return gossipWithObject(pointer, Function.returnValue(gossipOptionID))
end

local function gossipWithObjectWithObjectID(objectID, chooseOption)
  local objectPointer = GMR.FindObject(objectID)

  print('objectPointer', objectPointer, objectID)

  if objectPointer then
    gossipWithObject(objectPointer, chooseOption)
  else
    local npc = Questing.Database.retrieveNPC(objectID)
    if npc and npc.coordinates and next(npc.coordinates) then
      local positions = Array.map(npc.coordinates, function(coordinates)
        return Questing.convertMapPositionToWorldPosition(coordinates)
      end)
      local continentID = select(8, GetInstanceInfo())
      local positionsOnContinent = Array.filter(positions, function(position)
        return position.continentID == continentID
      end)
      local visitedPositions = Set.create()

      local function findClosestPositionThatCanStillBeVisited()
        local positionsThatCanStillBeVisited = Array.filter(positionsOnContinent, function(position)
          return not visitedPositions[position]
        end)
        return Array.min(positionsThatCanStillBeVisited, function(position)
          return GMR.GetDistanceToPosition(position.x, position.y, position.z)
        end)
      end

      local closestPosition = findClosestPositionThatCanStillBeVisited()
      while closestPosition do
        Questing.Coroutine.moveTo(closestPosition)
        visitedPositions:add(closestPosition)
        local objectPointer = GMR.FindObject(objectID)
        if objectPointer then
          gossipWithObject(objectPointer, chooseOption)
          break
        else
          closestPosition = findClosestPositionThatCanStillBeVisited()
        end
      end
    end
  end
end

function Questing.Coroutine.gossipWith(objectID, optionToSelect)
  gossipWithObjectWithObjectID(objectID, Function.returnValue(optionToSelect))
end

function Questing.Coroutine.gossipWithAndSelectOneOfOptions(objectID, options)
  options = Set.create(options)
  gossipWithObjectWithObjectID(objectID, function()
    local availableOptions = C_GossipInfo.GetOptions()
    local option = Array.find(availableOptions, function(option)
      return options[option.gossipOptionID]
    end)
    if option then
      return option.gossipOptionID
    else
      return nil
    end
  end)
end

function Questing.Coroutine.gossipWithAt(point, objectID, optionToSelect)
  Questing.Coroutine.interactWithAt(point, objectID)
  Events.waitForEvent('GOSSIP_SHOW', 2)
  yieldAndResume()
  if Questing.isRunning() then
    selectOption(optionToSelect)
  end
end

function Questing.Coroutine.doMob(pointer, options)
  -- FIXME: Mobs which are in the air.
  print('Questing.Coroutine.doMob')
  options = options or {}

  local distance = GMR.GetCombatRange()
  local objectID = GMR.ObjectId(pointer)

  local function isJobDone()
    return not GMR.ObjectExists(pointer) or GMR.IsDead(pointer) or options.additionalStopConditions and options.additionalStopConditions()
  end

  local position = createPoint(GMR.ObjectPosition(pointer))
  if not GMR.IsPlayerPosition(position.x, position.y, position.z, distance) then
    Questing.Coroutine.moveToObject(pointer, distance)
  end

  if IsMounted() then
    Movement.dismount()
  end

  print('targeting', GMR.ObjectName(pointer))
  GMR.TargetObject(pointer)
  local targetObject = GMR.TargetObject
  GMR.TargetObject = Function.noOperation
  GMR.StartAttack()

  while Questing.isRunning() and not isJobDone() do
    local position = createPoint(GMR.ObjectPosition(pointer))
    if not GMR.IsPlayerPosition(position.x, position.y, position.z, distance) then
      Questing.Coroutine.moveToObject(pointer, distance)
    end
    yieldAndResume()
  end

  if not GMR.InCombat() then
    local x, y, z = GMR.ObjectPosition(pointer)
    if GMR.IsPlayerPosition(x, y, z, INTERACT_DISTANCE) then
      Questing.Coroutine.lootObject(pointer)
    end
  end

  GMR.TargetObject = targetObject

  print('--- Questing.Coroutine.doMob')
end
