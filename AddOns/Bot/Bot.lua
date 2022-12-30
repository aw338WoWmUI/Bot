local addOnName, AddOn = ...
local _ = {}
--- @class Bot
Bot = Bot or {}

local isRunning = false

function Bot.isRunning()
  return isRunning
end

function Bot.start(options)
  if not Bot.isRunning() then
    print('Starting bot...')

    isRunning = true

    if _G.Questing then
      Questing.start(options)
    end
  end
end

function Bot.stop()
  if Bot.isRunning() then
    print('Stopping bot...')
    isRunning = false

    if _G.Questing then
      Questing.stop()
    end
  end
end

function Bot.toggle()
  if isRunning then
    Bot.stop()
  else
    Bot.start()
  end
end

function Bot.castCombatRotationSpell()
  local classID = select(2, UnitClassBase('player'))
  if classID == Core.ClassID.Warrior then
    Bot.Warrior.castSpell()
  elseif classID == Core.ClassID.DeathKnight then
    Bot.DeathKnight.castSpell()
  elseif _G.RecommendedSpellCaster then
    AddOn.castRecommendedSpell()
  elseif _G.GMR and GMR.ClassRotation then
    GMR.ClassRotation()
  end
end

function AddOn.castRecommendedSpell()
  local ability, recommendation = RecommendedSpellCaster.retrieveNextAbility()
  if ability then
    if RecommendedSpellCaster.isItem(ability) then
      RecommendedSpellCaster.castItem(ability)
      SpellCasting.handleAOE()
    else
      _.castSpell(ability, recommendation)
    end
  end
end

function Bot.castSpell(spell)
  local spellName, __, __, __, __, __, spellID = GetSpellInfo(spell)
  _.castSpell({
    id = spellID,
    name = spellName
  }, {
    empower_to = nil
  })
end

function _.castSpell(ability, recommendation)
  SpellCasting.castSpell(ability.id, {
    empowermentLevel = recommendation.empower_to
  })
end

local caches = {}

local coordinates = {
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

local positions = nil

function Bot.findCaches()
  positions = Array
    .map(coordinates, function(coordinates)
    return Core.retrieveWorldPositionFromMapPosition(
      { mapID = 2022, x = coordinates.x / 100, y = coordinates.y / 100 },
      Core.retrieveHighestZCoordinate
    )
  end)
    :filter(function(position)
    return position.z ~= nil
  end)

  Draw.Sync(function()
    local characterPosition = Core.retrieveCharacterPosition()
    if characterPosition then
      Array.forEach(positions, function(position)
        local distance = Core.calculateDistanceBetweenPositions(characterPosition, position)
        if distance <= 184 then
          Draw.SetColorRaw(0, 1, 0, 1)
        else
          Draw.SetColorRaw(0, 0, 1, 1)
        end
        Draw.Circle(position.x, position.y, position.z, 10)
      end)

      Draw.SetColorRaw(0, 1, 0, 1)
      Array.forEach(caches, function(cache)
        local position = Core.retrieveObjectPosition(cache)
        if position then
          Draw.Circle(position.x, position.y, position.z, 1)
          Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
        end
      end)
    end
  end)

  C_Timer.NewTicker(1, function()
    caches = Array.filter(Core.retrieveObjectPointers(), function(pointer)
      return HWT.ObjectId(pointer) == 376580 and Core.retrieveObjectDataDynamicFlags(pointer) == -65536
      -- open: -65520
    end)
  end)
end

function Bot.lootCaches()
  positions = Array
    .map(coordinates, function(coordinates)
    return Core.retrieveWorldPositionFromMapPosition(
      { mapID = 2022, x = coordinates.x / 100, y = coordinates.y / 100 },
      Core.retrieveHighestZCoordinate
    )
  end)
    :filter(function(position)
    return position.z ~= nil
  end)

  Draw.Sync(function()
    local characterPosition = Core.retrieveCharacterPosition()
    if characterPosition then
      Array.forEach(positions, function(position)
        local distance = Core.calculateDistanceBetweenPositions(characterPosition, position)
        if distance <= 184 - 50 then
          Draw.SetColorRaw(0, 1, 0, 1)
        else
          Draw.SetColorRaw(0, 0, 1, 1)
        end
        Draw.Circle(position.x, position.y, position.z, 10)
      end)

      Draw.SetColorRaw(0, 1, 0, 1)
      Array.forEach(caches, function(cache)
        local position = Core.retrieveObjectPosition(cache)
        if position then
          Draw.Circle(position.x, position.y, position.z, 1)
          Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
        end
      end)
    end
  end)

  local moveToNextNode = nil
  local isVisitingNodesEnabled = false

  local lookForCache
  local visitNodes

  local function doLookForCaches()
    local pausable, pausableInternal = Pausable.Pausable:new()

    Coroutine.runAsCoroutine(function()
      while true do
        caches = Array.filter(Core.retrieveObjectPointers(), function(pointer)
          return HWT.ObjectId(pointer) == 376580 and Core.retrieveObjectDataDynamicFlags(pointer) == -65536
          -- open: -65520
        end)
        if #caches >= 1 then
          print('Found cache(s).')

          local characterPosition = Core.retrieveCharacterPosition()
          local closestCache = Array.min(caches, function(cache)
            local cachePosition = Core.retrieveObjectPosition(cache)
            return Core.calculateDistanceBetweenPositions(characterPosition, cachePosition)
          end)

          local function doLootCache()
            return Core.moveToAndInteractWithObject(closestCache)
          end

          await(visitNodes:pause())
          local lootCache = doLootCache()
          pausable:alsoPause(lootCache)
          await(lootCache)
          visitNodes:resume()
        end

        Coroutine.waitForDuration(1)
      end
    end)

    return pausable
  end

  local visitedNodes
  local nodes = positions

  local function determineNodesStillToVisit()
    return Array.filter(nodes, function(node)
      return not visitedNodes:contains(node)
    end)
  end

  local HOW_TO_CLOSE_TO_FLY_TO_NODE = 40

  local function doVisitNodes()
    local pausable, pausableInternal = Pausable.Pausable:new()

    Coroutine.runAsCoroutine(function()
      while true do
        visitedNodes = Set:new()
        local nodesStillToVisit = determineNodesStillToVisit()
        while Array.hasElements(nodesStillToVisit) do
          local characterPosition = Core.retrieveCharacterPosition()
          local closestNode = Array.min(nodesStillToVisit, function(node)
            return Core.calculateDistanceBetweenPositions(characterPosition, node)
          end)
          moveToNextNode = Core.moveTo(closestNode, {
            distance = HOW_TO_CLOSE_TO_FLY_TO_NODE,
            additionalStopConditions = function()
              return pausable:hasBeenRequestedToPause() or pausable:isPaused() or pausable:hasStopped()
            end
          })
          await(moveToNextNode)
          if _.hasVisitedNode(closestNode) then
            visitedNodes:add(closestNode)
          end

          pausableInternal:pauseIfHasBeenRequestedToPause()

          nodesStillToVisit = determineNodesStillToVisit()

          Coroutine.yieldAndResume()
        end

        Coroutine.yieldAndResume()
      end
    end)

    return pausable
  end

  function _.doHandleEventOfCharacterBeingAttacked()
    Coroutine.runAsCoroutine(function()
      while true do
        local attackers = Array.filter(Core.retrieveObjectPointers(), Core.isUnitAttackingTheCharacter)
        local isThereAnAttacker = Array.hasElements(attackers)
        if isThereAnAttacker then
          await(Resolvable.all(
            {
              lookForCache:pause(),
              visitNodes:pause()
            }
          ))
          await(_.handleAttackers())
          lookForCache:resume()
          visitNodes:resume()
        end

        Coroutine.yieldAndResume()
      end
    end)
  end

  function _.hasVisitedNode(node)
    local characterPosition = Core.retrieveCharacterPosition()
    return Core.calculateDistanceBetweenPositions(characterPosition, node) <= HOW_TO_CLOSE_TO_FLY_TO_NODE
  end

  function _.retrieveAttackers()
    return Array.filter(Core.retrieveObjectPointers(), Core.isUnitAttackingTheCharacter)
  end

  function _.retrieveClosestAttacker()
    return Array.min(_.retrieveAttackers(), Core.calculateDistanceFromCharacterToObject)
  end

  function _.handleAttackers()
    local resolvable, resolvableInternal = Resolvable.Resolvable:new()

    Coroutine.runAsCoroutine(function()
      local closestAttacker = _.retrieveClosestAttacker()
      while closestAttacker do
        await(Core.doMob(closestAttacker))

        Coroutine.yieldAndResume()

        closestAttacker = _.retrieveClosestAttacker()
      end
      resolvableInternal:resolve()
    end)

    return resolvable
  end

  lookForCache = doLookForCaches()
  visitNodes = doVisitNodes()
  _.doHandleEventOfCharacterBeingAttacked()
end

local objectsWhoDrop = {}

local CHEST_OPEN = -65520
local CHEST_CLOSED = -65536

local unitClassesWhichSeemToDropDragonShardOfKnowledge = Set.create({
  'worldboss',
  'rareelite',
  'rare'
})

function Bot.findThingsThatDropDragonShardOfKnowledge()
  Draw.Sync(function()
    local characterPosition = Core.retrieveCharacterPosition()
    if characterPosition then
      --local closestPositionOnMesh = Core.retrieveClosestPositionOnMesh(characterPosition)
      Array.forEach(objectsWhoDrop, function(object)
        local position = Core.retrieveObjectPosition(object)
        if position then
          Draw.SetColorRaw(0, 1, 0, 1)
          Draw.Circle(position.x, position.y, position.z, 1)
          --local hasDrawnPathToObject = false
          --if closestPositionOnMesh then
          --  local path = Core.findPath(closestPositionOnMesh, position)
          --  if path then
          --    Core.drawPath(path)
          --    hasDrawnPathToObject = true
          --  end
          --end
          --if not hasDrawnPathToObject then
          Draw.SetColorRaw(0, 1, 0, 1)
          Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
          --end
        end
      end)
    end
  end)

  C_Timer.NewTicker(1, function()
    local objects = Core.retrieveObjectPointers()
    objectsWhoDrop = Array.filter(objects, function(object)
      local objectID = HWT.ObjectId(object)
      return (
        (
          (
            Set.contains(unitClassesWhichSeemToDropDragonShardOfKnowledge, UnitClassification(object)) or
              Set.contains(AddOn.droppedBy, objectID)
          ) and
            Core.isAlive(object)
        ) or
          (Set.contains(AddOn.containedIn1, objectID) or Set.contains(AddOn.containedIn2,
            objectID) or Set.contains(AddOn.containedIn3,
            objectID)) and Core.retrieveObjectDataDynamicFlags(object) == CHEST_CLOSED
      )
    end)
  end)
end

local button = CreateFrame('Button', nil, nil, 'UIPanelButtonNoTooltipTemplate')
button:SetText('Start')
button:SetSize(130, 20)
button:SetScript('OnClick', Bot.start)
