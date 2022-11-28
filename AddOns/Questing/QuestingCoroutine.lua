local addOnName, AddOn = ...
--- @class Questing
Questing = Questing or {}
--- @type Bot
--- @type Stoppable

--- @class Questing.Coroutine
Questing.Coroutine = {}

local _ = {}

local function moveTo(to, options)
  options = options or {}

  local stoppable = Stoppable.Stoppable:new()

  Movement.moveTo(to, {
    stop = function()
      return not Questing.isRunning() or (options.stop and options.stop()) or stoppable.isStopped
    end,
    toleranceDistance = options.toleranceDistance,
    continueMoving = options.continueMoving
  })

  return stoppable
end

function Questing.Coroutine.moveTo(point, options)
  options = options or {}
  local additionalStopConditions = options.additionalStopConditions
  local distance = options.distance or 1

  local function hasArrived()
    return Core.isCharacterCloseToPosition(point, distance) or additionalStopConditions and additionalStopConditions()
  end

  return Questing.Coroutine.moveToUntil(point, {
    toleranceDistance = distance,
    stopCondition = hasArrived
  })
end

function Questing.Coroutine.moveToUntil(point, options)
  options = options or {}

  local stopCondition = options.stopCondition

  if Movement.isPositionInTheAir(point) and not Movement.canCharacterFly() then
    point = Movement.createPoint(
      point.x,
      point.y,
      Core.retrieveZCoordinate(point) or point.z
    )
  end

  while Questing.isRunning() and not stopCondition() do
    moveTo(point, {
      toleranceDistance = options.toleranceDistance,
      stop = stopCondition
    })
    Yielder.yieldAndResume()
  end
end

function Questing.Coroutine.moveToObject(pointer, options)
  options = options or {}

  local distance = options.distance or INTERACT_DISTANCE
  local stop = options.stop or Function.alwaysFalse

  local function retrievePosition()
    local position = Core.retrieveObjectPosition(pointer)

    if Movement.isPositionInTheAir(position) and not Movement.canCharacterFly() then
      position = Core.createWorldPosition(
        position.continentID,
        position.x,
        position.y,
        Movement.retrieveGroundZ(position) or position.z
      )
    end

    position = Core.retrieveClosestPositionWithPathTo(position, distance)

    return position
  end

  local function isJobDone(position)
    return (
      not position or
      not HWT.ObjectExists(pointer) or
        (stop and stop()) or
        Core.isCharacterCloseToPosition(position, distance)
    )
  end

  local lastMoveToPosition

  local function isObjectUnreachableOrHasMoveToPositionChanged()
    local moveToPostion = retrievePosition()
    return not moveToPostion or moveToPostion:isDifferent(lastMoveToPosition)
  end

  local position = retrievePosition()
  while Questing.isRunning() and not isJobDone(position) do
    lastMoveToPosition = position
    moveTo(position, {
      toleranceDistance = distance,
      stop = function()
        return isJobDone(position) or isObjectUnreachableOrHasMoveToPositionChanged()
      end,
      continueMoving = true
    })
    position = retrievePosition()
  end

  Core.stopMoving()
end

function Questing.Coroutine.interactWithAt(point, objectID, distance, delay)
  distance = distance or INTERACT_DISTANCE

  if not Core.isCharacterCloseToPosition(point, distance) then
    Questing.Coroutine.moveTo(point, {
      distance = distance
    })
  end

  if Questing.isRunning() then
    local pointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)
    if pointer then
      Core.interactWithObject(pointer)
      Coroutine.waitForDuration(2)
    end
  end
end

function Questing.Coroutine.interactWithObjectWithObjectID(objectID, options)
  options = options or {}

  local pointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)

  if not pointer and options.fallbackPosition then
    Questing.Coroutine.moveTo(options.fallbackPosition, {
      distance = Core.RANGE_IN_WHICH_OBJECTS_SEEM_TO_BE_SHOWN,
      additionalStopConditions = function()
        return Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)
      end
    })
  end

  if not pointer then
    pointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)
  end

  if pointer then
    Questing.Coroutine.interactWithObject(pointer, options.distance, options.delay)
  end
end

function Questing.Coroutine.interactWithObject(pointer, distance, delay)
  distance = distance or INTERACT_DISTANCE

  local position = Core.retrieveObjectPosition(pointer)
  if not Core.isCharacterCloseToPosition(position, distance) then
    Questing.Coroutine.moveToObject(pointer, {
      distance = distance
    })
  end

  if Questing.isRunning() and HWT.ObjectExists(pointer) and Core.isCharacterCloseToPosition(position, distance) then
    Core.interactWithObject(pointer)
    Coroutine.waitForDuration(1)
    Coroutine.waitFor(function()
      return not Core.isCharacterCasting()
    end)
    if GetNumLootItems() >= 1 then
      Events.waitForEvent('LOOT_CLOSED')
    end
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

  if not Core.isCharacterCloseToPosition(point, distance) then
    Questing.Coroutine.moveTo(point, {
      distance = distance
    })
  end

  if Questing.isRunning() then
    local pointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)
    Core.useItemByID(itemID, pointer)
  end
end

function Questing.Coroutine.useItemOnGround(point, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not Core.isCharacterCloseToPosition(point, distance) then
    Questing.Coroutine.moveTo(point, {
      distance = distance
    })
  end

  if Questing.isRunning() then
    Core.useItemByID(itemID)
    Core.clickPosition(point)
  end
end

function Questing.Coroutine.useItemOnPosition(position, itemID, distance)
  distance = distance or INTERACT_DISTANCE

  if not Core.isCharacterCloseToPosition(position, distance) then
    Questing.Coroutine.moveTo(position, {
      distance = distance
    })
  end

  Questing.Coroutine.useItem(itemID)
end

function Questing.Coroutine.useItem(itemID)
  if Questing.isRunning() then
    Core.useItemByID(itemID)
  end
end

function Questing.Coroutine.waitForItemReady(itemID)
  local startTime, duration = C_Container.GetItemCooldown(itemID)
  if startTime > 0 and duration > 0 then
    local remainingCooldownTime = duration - (GetTime() - startTime)
    Coroutine.waitForDuration(remainingCooldownTime)
  end
end

local function selectOption(optionToSelect)
  if Questing.isRunning() then
    C_GossipInfo.SelectOption(optionToSelect)
  end
end

local function gossipWithObject(pointer, chooseOption)
  local name = Core.retrieveObjectName(pointer)
  print(name)
  while Questing.isRunning() and HWT.ObjectExists(pointer) and Core.retrieveObjectPointer('npc') ~= pointer do
    Questing.Coroutine.interactWithObject(pointer)
    Events.waitForEvent('GOSSIP_SHOW', 2)
    Yielder.yieldAndResume()
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
  local objectPointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)

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
          return Core.calculateDistanceFromCharacterToPosition(position)
        end)
      end

      local closestPosition = findClosestPositionThatCanStillBeVisited()
      while closestPosition do
        Questing.Coroutine.moveTo(closestPosition)
        visitedPositions:add(closestPosition)
        local objectPointer = Core.findClosestObjectToCharacterWithOneOfObjectIDs(objectID)
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
  Yielder.yieldAndResume()
  if Questing.isRunning() and optionToSelect then
    selectOption(optionToSelect)
  end
end

function Questing.Coroutine.doMob(pointer, options)
  -- FIXME: Mobs which are in the air.
  print('Questing.Coroutine.doMob')
  options = options or {}

  local distance = Core.retrieveCharacterCombatRange()
  local objectID = HWT.ObjectId(pointer)

  local function isJobDone()
    return not HWT.ObjectExists(pointer) or Core.isDead(pointer) or options.additionalStopConditions and options.additionalStopConditions()
  end

  local position = Core.retrieveObjectPosition(pointer)
  if not Core.isCharacterCloseToPosition(position, distance) then
    Questing.Coroutine.moveToObject(pointer, {
      distance = distance
    })
  end

  if IsMounted() then
    Movement.dismount()
  end

  print('targeting', Core.retrieveObjectName(pointer))
  Core.targetUnit(pointer)
  Core.startAttacking()

  while Questing.isRunning() and not isJobDone() do
    local position = Core.retrieveObjectPosition(pointer)
    if not Core.isCharacterCloseToPosition(position, distance) then
      Questing.Coroutine.moveToObject(pointer, {
        distance = distance
      })
    end
    Bot.castCombatRotationSpell()
    Yielder.yieldAndResume()
  end

  if not Core.isCharacterInCombat() then
    local position = Core.retrieveObjectPosition(pointer)
    if Core.isCharacterCloseToPosition(position, INTERACT_DISTANCE) then
      Questing.Coroutine.lootObject(pointer)
    end
  end

  print('--- Questing.Coroutine.doMob')
end
