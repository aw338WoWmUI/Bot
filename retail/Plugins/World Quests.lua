-- Dependencies: Set, Array, Object, Movement, Core, Questing

local Quester = {}

local function goTo(position)
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end
  GMR.MeshTo(position.x, position.y, position.z)
end

local ZERETH_MORTIS_MAP_ID = 1970
local BASTION_MAP_ID = 1533
local REVENDRETH_MAP_ID = 1525
local MALDRAXXUS_MAP_ID = 1536
local ARDENWEALD_MAP_ID = 1565

local zoneMapIDs = Set.create({
  ZERETH_MORTIS_MAP_ID,
  BASTION_MAP_ID,
  REVENDRETH_MAP_ID,
  MALDRAXXUS_MAP_ID,
  ARDENWEALD_MAP_ID
})

local function distance2d(a, b)
  return math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2))
end

local function determineZoneMapID()
  local mapID = MapUtil.GetDisplayableMapForPlayer()
  if mapID == 1700 then
    return REVENDRETH_MAP_ID
  elseif mapID == 1701 then
    return ARDENWEALD_MAP_ID
  else
    return mapID
  end
end

local function addPositionToQuest(quest)
  local x, y, z = GMR.GetWorldPositionFromMap(quest.mapID, quest.x, quest.y)
  quest.position = {
    x = x,
    y = y,
    z = z
  }
  return quest
end

local function addPositionToQuests(quests)
  return Array.map(quests, addPositionToQuest)
end

local function calculateDistance(a, b)
  return math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2) + math.pow(b.z - a.z, 2))
end

local function findClosestQuest(quests)
  local playerPosition = GMR.GetPlayerPosition()
  return Array.min(quests, function(quest)
    return calculateDistance(playerPosition, quest.position)
  end)
end

local function sortQuestsByDistanceAscending(quests)
  local playerPosition = GMR.GetPlayerPosition()
  table.sort(quests, function(a, b)
    local distanceA = calculateDistance(playerPosition, a.position)
    local distanceB = calculateDistance(playerPosition, b.position)
    return distanceA < distanceB
  end)
end

local function hasTagInfo(quest)
  local tagInfo = C_QuestLog.GetQuestTagInfo(quest.questId)
  return tagInfo ~= nil
end

local function isPetBattleWorldQuest(quest)
  local tagInfo = C_QuestLog.GetQuestTagInfo(quest.questId)
  return tagInfo.worldQuestType == Enum.QuestTagType.PetBattle
end

local questIDs = {
  ['Robriar Trouble'] = 59600,
  ['Spriggan Size Me!'] = 60476,
  ['Major Mirror Disruptions'] = 59855,
  ['Soul Snares'] = 58084
}

local questsToDo = Set.create({
  questIDs['Robriar Trouble'],
  questIDs['Spriggan Size Me!'],
})

local function filterQuests(quests)
  return Array.filter(quests, function(quest)
    return questsToDo[quest.questId]
  end)
end

local function retrieveWorldQuestsInZone(mapID)
  local quests = Array.concat(C_QuestLog.GetQuestsOnMap(mapID), C_TaskQuest.GetQuestsForPlayerByMapID(mapID))
  return quests
end

local destination = nil

local function goToNextWorldQuestInZone(mapID)
  local quests = addPositionToQuests(retrieveWorldQuestsInZone(mapID))
  quests = filterQuests(quests)
  local quest = findClosestQuest(quests)
  if quest then
    print('goToNextWorldQuestInZone: ' .. QuestUtils_GetQuestName(quest.questId))
    goTo(quest.position)
    destination = quest.position
  end
end

local function isMoving()
  return destination ~= nil and GMR.IsMoving()
end

function Quester.defineQuestMuckItUp()
  local questID = 59808
  GMR.DefineQuest(
    { 'Alliance', 'Horde' },
    nil,
    questID,
    'Muck It Up',
    'Custom',
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    {
      function()
        if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
          GMR.Questing.UseItemOnPosition(
            -1551.3829345703,
            7426.8286132812,
            3999.8666992188,
            177880,
            3
          )
        elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
          GMR.SetQuestingState('Idle')
        end
      end
    },
    function()
      GMR.SkipTurnIn(true)
      GMR.DefineProfileCenter(-1551.3829345703,
        7426.8286132812,
        3999.8666992188)
      GMR.DefineQuestEnemyId(166206)
      GMR.DefineSetting('Disable', 'AvoidWater')
      GMR.DefineSetting('Enable', 'Grinding')
    end
  )
end

function Quester.defineQuestAStolenStoneFiend()
  local questID = 60655
  local LID_1_ID = 353405
  local LID_2_ID = 353410
  local LID_3_ID = 353411
  GMR.DefineQuest(
    { 'Alliance', 'Horde' },
    nil,
    questID,
    'A Stolen Stone Fiend',
    'Custom',
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    {
      function()
        if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
          GMR.Questing.InteractWith(-1835.7985839844, 6196.7622070312, 4175.7373046875, LID_1_ID)
        elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
          GMR.Questing.InteractWith(-1781.8472900391, 6360.8090820312, 4221.5922851562, LID_2_ID)
        elseif not GMR.Questing.IsObjectiveCompleted(questID, 3) then
          GMR.Questing.InteractWith(-2103.9704589844, 6464.796875, 4252.6713867188, LID_3_ID)
        elseif not GMR.Questing.IsObjectiveCompleted(questID, 4) or not GMR.Questing.IsObjectiveCompleted(questID,
          5) then
          GMR.Questing.KillEnemy(-2181.765625, 6824.0434570312, 4259.8017578125, 170079)
        end
      end
    },
    function()
      GMR.SkipTurnIn(true)
    end
  )
end

function Quester.defineQuestRetainingTheCourt()
  local questID = 59599
  GMR.DefineQuest(
    { 'Alliance', 'Horde' },
    nil,
    questID,
    'Retaining the Court',
    'Custom',
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    {
      function()
        if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
          if UnitPower('player', ALTERNATE_POWER_INDEX) < 8 then
            local object = GMR.FindObject({ 348740, 348741 })
            if object then
              local objectID = GMR.ObjectId(object)
              local x, y, z = GMR.ObjectPosition(object)
              GMR.Questing.InteractWith(x, y, z, objectID, nil, 8)
            else
              GMR.SetQuestingState('Idle')
            end
          else
            local object = GMR.FindObject({ 165286, 165301 })
            if object then
              local objectID = GMR.ObjectId(object)
              local x, y, z = GMR.ObjectPosition(object)
              GMR.Questing.InteractWith(x, y, z, objectID, nil, 8)
            else
              GMR.SetQuestingState('Idle')
            end
          end
        elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
          GMR.SetQuestingState('Idle')
        end
      end
    },
    function()
      GMR.SkipTurnIn(true)
      GMR.DefineProfileCenter(-1844.7054443359, 7053.349609375, 4272.7475585938)
      GMR.DefineQuestEnemyId(165266)
      GMR.DefineQuestEnemyId(165270)
      GMR.DefineSetting('Enable', 'Grinding')
    end
  )
end

function Quester.defineQuestRetainingTheCourt()
  local questID = 60601
  GMR.DefineQuest(
    { 'Alliance', 'Horde' },
    nil,
    questID,
    'Darkwing Drills',
    'Custom',
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    {
      function()
        if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
          GMR.SetQuestingState(nil)
          GMR.Questing.GossipWith(-1956.5399169922, 6118.0478515625, 4172.4853515625, 174380)
        elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
          -- FIXME: Make grinding with the Darkwing Aggressor work
          GMR.SetQuestingState('Idle')
        end
      end
    },
    function()
      GMR.SkipTurnIn(true)
      GMR.DefineQuestEnemyId(169362) -- Stone Fiend
      GMR.DefineQuestEnemyId(169365) -- Venerable Denizen
      GMR.DefineQuestEnemyId(169370) -- Merciless Tormentor
      GMR.DefineQuestEnemyId(169364) -- Ardent Loyalist
      -- TODO: There are a few more mob types
      GMR.DefineSetting('Enable', 'Grinding')
    end
  )
end

function Quester.defineQuestACuriousCache()
  local questID = 59905
  GMR.DefineQuest(
    { 'Alliance', 'Horde' },
    nil,
    questID,
    'A Curious Cache',
    'Custom',
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    {
      function()
        print('questInfo')
        if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
          GMR.DefineQuestEnemyId(156636)
          GMR.DefineSetting('Enable', 'Grinding')
          GMR.SetQuestingState('Idle')
        end
      end
    },
    function()
      print('profileData')
      GMR.SkipTurnIn(true)
      GMR.DefineProfileCenter(-2815.7131347656, 6806.6469726562, 3996.9770507812)
    end
  )
end

local tooltip = CreateFrame('GameTooltip', 'QuesterTooltip', UIParent, 'GameTooltipTemplate')
tooltip:SetOwner(UIParent, 'ANCHOR_NONE')

local function addIndexToQuestObjectives(questObjectives)
  for index, questObjective in ipairs(questObjectives) do
    questObjective.index = index
  end
end

function includePointerInObject(objects)
  local result = {}
  for pointer, object in pairs(objects) do
    object.pointer = pointer
    table.insert(result, object)
  end
  return result
end

local function killEnemy(objectGUID)
  local x, y, z = GMR.ObjectPosition(objectGUID)
  local objectID = GMR.ObjectId(objectGUID)
  GMR.Questing.KillEnemy(x, y, z, objectID)
end

local function interactWith(objectGUID, distance)
  local x, y, z = GMR.ObjectPosition(objectGUID)
  local objectID = GMR.ObjectId(objectGUID)
  GMR.Questing.InteractWith(x, y, z, objectID, nil, distance)
end

function defineWorldQuest(questID)
  defineQuest2(questID, nil, nil, nil, nil)
end

function defineQuest2(questID, pickUpX, pickUpY, pickUpZ, pickUpObjectID)
  local function determineObjectiveIndexThatObjectIsObjectiveOf(objectGUID)
    if questID == 58221 then
      local objectID = GMR.ObjectId(objectGUID)
      if objectID == 364988 then
        -- Create of Salvaged Explosives
        return 2
      end
    end

    return nil
  end

  local questName = QuestUtils_GetQuestName(questID)

  print('defineQuest', questName)

  local questObjectiveToObjectIDs = {}

  local race = { 'Alliance', 'Horde' }
  local class = nil

  local objectsThatHasBeenChargedWith = Set.create()

  local defaultInitial = function()
    print('initial')
    GMR.SkipTurnIn(true)
  end

  local defaultDuring = function()
    print('during')

    _G.abc = questObjectiveToObjectIDs

    local questInfo = GMR.Questing.GetQuestInfo(questID)

    for i = 1, 40 do
      local unitID = 'nameplate' .. i
      tooltip:SetUnit(unitID)
      findRelationsToQuest(questID, questObjectiveToObjectIDs, 'QuesterTooltip', unitID)
    end

    local objects = GMR.GetNearbyObjects(250)
    for objectGUID, object in pairs(objects) do
      local objectName = object.Name
      local questObjectiveIndex = determineObjectiveIndexThatObjectIsObjectiveOf(objectGUID)
      if questObjectiveIndex then
        local objectID = GMR.ObjectId(objectGUID)
        addObjectIDToObjective(questObjectiveToObjectIDs, objectID, questObjectiveIndex)
      else
        findObjectiveWhichMatchesAndAddItToTheLookup(questObjectiveToObjectIDs, questInfo, objectGUID, function(questObjective)
          local name = string.match(questObjective.text, '%d+/%d+ (.+) slain')
          if name and name == objectName then
            return true
          end

          local name = string.match(questObjective.text, '%d+/%d+ (.+)')
          if name and name == objectName then
            return true
          end

          local objectiveObjectName = string.match(questObjective.text, '^%d+/%d+ Enter a (.+)$')
          if objectiveObjectName and string.match(objectName, objectiveObjectName) then
            return true
          end

          return false
        end)
      end
    end

    addIndexToQuestObjectives(questInfo)

    local openQuestObjectives = Array.filter(questInfo, function(questObjective)
      return not questObjective.finished
    end)

    local objectIDs = Set.toList(
      Set.union(
        unpack(
          Array.map(
            openQuestObjectives,
            function(questObjective)
              return questObjectiveToObjectIDs[questObjective.index] or {}
            end
          )
        )
      )
    )
    local objects = retrieveObjects()
    objects = Array.filter(objects, function(object)
      return (
        not GMR.IsBlacklistedGUID(object.pointer) and
          not GMR.IsBlacklistedId(object.ID) and
          (Array.includes(objectIDs, object.ID) or
            seemsToBeQuestObject(object.pointer)
          )
      ) and not GMR.UnitIsDead(object.pointer)
    end)
    local playerPosition = GMR.GetPlayerPosition()
    local object = Array.min(objects, function(object)
      local x, y, z = GMR.ObjectPosition(object.pointer)
      local objectPosition = {
        x = x,
        y = y,
        z = z
      }
      return calculateDistance(playerPosition, objectPosition)
    end)
    local objectPointer
    print('object')
    printTable(object)
    if object then
      objectPointer = object.pointer
    else
      objectPointer = nil
    end

    local function findObjectsThatCanBeChargedWith()
      if questID == 62235 and not GMR.Questing.IsObjectiveCompleted(questID, 2) then
        -- Objective text: 0/1 Allaying Crook charged
        -- Item name: Korinna's Allaying Crook
        local range = 20
        local objects = GMR.GetNearbyObjects(range)
        local objectsThatPotentiallyCanBeChargedWith = Array.filter(
          Core.includePointerInObject(objects),
          function(object)
            return (
              questObjectiveToObjectIDs[2][object.ID] and
                GMR.IsDead(object.pointer) and
                not objectsThatHasBeenChargedWith[object.pointer]
            )
          end
        )
        return objectsThatPotentiallyCanBeChargedWith
      end
      return {}
    end

    local function chargeItem(objectsThatPotentiallyCanBeChargedWith)
      local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
      local cooldownStart = GetQuestLogSpecialItemCooldown(logIndex)
      return cooldownStart == 0 and #objectsThatPotentiallyCanBeChargedWith >= 1
    end

    local function addObjectsThatHasBeenChargedWith(objectsThatPotentiallyCanBeChargedWith)
      for _, object in ipairs(objectsThatPotentiallyCanBeChargedWith) do
        objectsThatHasBeenChargedWith[object.pointer] = true
      end
    end

    local function retrieveExtraActionButton1ActionDescriptionText()
      -- FIXME: This seemed to return nil one time. Maybe the action info is first retrieved from the server before it is shown.
      tooltip:SetAction(ExtraActionButton1.action)
      local descriptionText = QuesterTooltipTextLeft4:GetText()
      return descriptionText
    end

    local function doesQuestObjectiveTextContainAnIndicatorThatSomethingIsRequiredToBeActivated(questObjective)
      return string.match(questObjective.text, ' activated$')
    end

    local function doesExtraActionButtonActionContainAnIndicatorThatItActivatesSomething()
      local descriptionText = retrieveExtraActionButton1ActionDescriptionText()
      return descriptionText and string.match(descriptionText, '^Activate the targeted .+ unit.$')
    end

    local function seemsToRequireToBeCloseToQuestMarker()
      if #openQuestObjectives >= 1 then
        local firstOpenQuestObjective = openQuestObjectives[1]
        if (
          doesQuestObjectiveTextContainAnIndicatorThatSomethingIsRequiredToBeActivated(firstOpenQuestObjective) and
            doesExtraActionButtonActionContainAnIndicatorThatItActivatesSomething()
        ) then
          return true
        end
      end
      return false
    end

    local function convertObjectLookupToList(objects)
      return Core.includePointerInObject(objects)
    end

    local function findExtraActionTarget()
      local descriptionText = retrieveExtraActionButton1ActionDescriptionText()
      local targetNamePart = string.match(descriptionText, '^Activate the targeted (.+) unit.$')
      if targetNamePart then
        local objects = convertObjectLookupToList(GMR.GetNearbyObjects(5))
        local target = Array.find(objects, function(object)
          return string.match(object.Name, targetNamePart)
        end)
        if target then
          return target.pointer
        end
      end
      return nil
    end

    local function retrieveObjectPositionAsObject(object)
      local x, y, z = GMR.ObjectPosition(object)
      return {
        x = x,
        y = y,
        z = z
      }
    end

    local function isCloseToRequiredExtraActionTarget()
      local requiredTarget = findExtraActionTarget()
      if requiredTarget then
        local requiredTargetPosition = retrieveObjectPositionAsObject(requiredTarget)
        local playerPosition = GMR.GetPlayerPosition()
        return calculateDistance(requiredTargetPosition, playerPosition) <= 5
      else
        return false
      end
    end

    local objectsThatPotentiallyCanBeChargedWith = findObjectsThatCanBeChargedWith()
    local questPosition = determineQuestPosition(questID)

    local SALVAGED_HAULER_ID = 175990

    local areConditionsForGettinEvenMet = function()

    end

    if C_GossipInfo.GetNumOptions() == 1 then
      C_GossipInfo.SelectOption(1)
    elseif chargeItem(objectsThatPotentiallyCanBeChargedWith) then
      print('GMR.Questing.UseItemOnPosition')
      local playerPosition = GMR.GetPlayerPosition()
      local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
      local itemLink = GetQuestLogSpecialItemInfo(logIndex)
      local itemID = GetItemInfoInstant(itemLink)
      GMR.Questing.UseItemOnPosition(playerPosition.x, playerPosition.y, playerPosition.z, itemID)
      addObjectsThatHasBeenChargedWith(objectsThatPotentiallyCanBeChargedWith)
      elseif objectPointer and Core.hasGossip(objectPointer) then
        print('GMR.Questing.GossipWith')
        local x, y, z = GMR.ObjectPosition(objectPointer)
        local objectID = GMR.ObjectId(objectPointer)
        GMR.Questing.GossipWith(x, y, z, objectID, nil, 4)
    elseif objectPointer and GMR.UnitCanAttack('player', objectPointer) then
      -- FIXME: Only kill mobs which contribute to quest progress (non-gray, not attacked by a character of the other faction)
      print('GMR.Questing.KillEnemy')
      local x, y, z = GMR.ObjectPosition(objectPointer)
      local objectID = GMR.ObjectId(objectPointer)
      GMR.Questing.KillEnemy(x, y, z, objectID)
    elseif (
      ExtraActionBarFrame:IsShown() and
        ExtraActionButton1:IsShown() and
        IsUsableAction(ExtraActionButton1.action) and
        GetActionCooldown(ExtraActionButton1.action) == 0 and
        areConditionsForGettinEvenMet()
      -- (not seemsToRequireToBeCloseToQuestMarker() or isCloseToRequiredExtraActionTarget())
    ) then
      print('GMR.Questing.ExtraActionButton1')

      local function doActionForGettingEven()
        targetMOBNAME()
        GMR.Questing.UseExtraActionButton1()
      end

      if questID == GETTING_EVEN_QUEST_ID then
        doActionForGettingEven()
      else
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

          if seemsToRequireToBeCloseToQuestMarker() then
            local target = findExtraActionTarget()
            if target then
              GMR.TargetObject(target)
            else
              error('Could not find target object.')
              return
            end
          end

          GMR.Questing.ExtraActionButton1(destination.x, destination.y, destination.z)
        else
          GMR.Questing.ExtraActionButton1(playerPosition.x, playerPosition.y, playerPosition.z)
        end
      end
    elseif (
      objectPointer and
        (GMR.IsObjectInteractable(objectPointer) or
          not GMR.UnitCanAttack('player', objectPointer))
    ) then
      -- FIXME: GMR.IsObjectInteractable might be bugged.
      print('GMR.Questing.InteractWith')
      interactWith(objectPointer, 4)
    elseif questPosition and not GMR.IsPlayerPosition(questPosition.x, questPosition.y, questPosition.z, 5) then
      print('GMR.Questing.MoveTo', questPosition.x, questPosition.y, questPosition.z)
      GMR.Questing.MoveTo(questPosition.x, questPosition.y, questPosition.z)
    end
  end

  local questHandlers = {
    [61815] = {
      during = function()
        local ORANOMONOS_ID = 167527
        local oranomonos = GMR.FindObject(ORANOMONOS_ID)
        if oranomonos and GMR.UnitCanAttack('player', oranomonos) then
          killEnemy(oranomonos)
        else
          local WILTING_BUD_ID = 357413
          local wiltingBud = GMR.FindObject(WILTING_BUD_ID)
          if wiltingBud and GMR.IsObjectInteractable(wiltingBud) then
            interactWith(wiltingBud, 3)
          else
            GMR.SetQuestingState('Idle')
          end
        end
      end
    },
    [questIDs['Spriggan Size Me!']] = {
      during = function()
        print('handler: Spriggan Size Me!')
        local SPRIGGANIZE = 347565
        if not GMR.HasBuffId('player', SPRIGGANIZE) then
          Questing.useExtraActionButton1()
        else
          defaultDuring()
        end
      end
    },
    [questIDs['Major Mirror Disruptions']] = function()
      -- TODO: Requires testing.
      local actions = {
        {
          type = 'moveToWithGMR',
          x = -2120.0166015625,
          y = 7625.5375976562,
          z = 4087.685546875
        },
        { type = 'moveTo', x = -2095.3686523438, y = 7625.0366210938, z = 4088.3728027344 },
        { type = 'moveTo', x = -2095.9099121094, y = 7599.015625, z = 4076.5595703125 },
        { type = 'moveTo', x = -2104.4916992188, y = 7599.8017578125, z = 4076.5947265625 },
        { type = 'moveTo', x = -2104.8913574219, y = 7620.25390625, z = 4068.5893554688 },
        { type = 'moveTo', x = -2108.240234375, y = 7626.9892578125, z = 4068.5893554688 },
        { type = 'moveTo', x = -2109.0632324219, y = 7636.2329101562, z = 4064.5607910156 },
        { type = 'moveTo', x = -2096.6430664062, y = 7639.267578125, z = 4060.19921875 },
        { type = 'moveTo', x = -2095.1262207031, y = 7663.4809570312, z = 4060.30859375 },
        { type = 'moveTo', x = -2095.4050292969, y = 7665.6420898438, z = 4061.2409667969 }, -- walk into (to the left on the minimap)
        { type = 'stepIntoPortal' },
        { type = 'moveTo', x = -2152.6611328125, y = 7667.2250976562, z = 4034.4914550781 }, -- walk into (to the right on the minimap)
        { type = 'stepIntoPortal' },
        { type = 'fightMobs' }, -- do mobs
        { type = 'moveTo', x = -2077.0034179688, y = 7677.375, z = 4034.6889648438 }, -- walk into (to the top on the minimap)
        { type = 'stepIntoPortal' },
        { type = 'moveTo', x = -2077.2136230469, y = 7627.330078125, z = 4034.6882324219 }, -- walk into (to the top on the minimap)
        { type = 'stepIntoPortal' },
        { type = 'fightMobs' }, -- do mobs
        { type = 'moveTo', x = -2143.1899414062, y = 7666.9365234375, z = 4015.7270507812 }, -- walk into (to the right on the minimap)
        { type = 'stepIntoPortal' },
        { type = 'moveTo', x = -2133.7893066406, y = 7617.267578125, z = 4015.6765136719 }, -- walk into (to the top right on the minimap)
        { type = 'stepIntoPortal' },
        { type = 'killKrengaath' }, -- do Krengaath (163921)
        -- { type = 'moveTo', x = -2553.2751464844, y = 7925.0341796875, z = 4166.052734375 }, -- walk into (to the left on the minimap). seems optional. it seems the world quest completes before.
        -- { type = 'stepIntoPortal' },
      }
      local nextActionIndex = 1
      local isDone = false
      local mover = nil
      local positionBeforeStartedMovingForward = nil
      local isMovingForward = false

      return {
        initial = function()
          defaultInitial()
        end,
        during = function()
          print('during')
          if not isDone then
            local lastActionIndex = nextActionIndex

            local action = actions[nextActionIndex]

            local function setToNextAction()
              if mover then
                mover.Stop()
                mover = nil
              end

              if isMovingForward then
                GMR.MoveForwardStop()
                isMovingForward = false
                positionBeforeStartedMovingForward = nil
              end

              if nextActionIndex < #actions then
                nextActionIndex = nextActionIndex + 1
                action = actions[nextActionIndex]
              else
                isDone = true
              end
            end

            if action.type == 'moveToWithGMR' then
              if GMR.IsPlayerPosition(action.x, action.y, action.z, 3) then
                setToNextAction()
              end
            elseif action.type == 'moveTo' then
              if GMR.IsPlayerPosition(action.x, action.y, action.z, 0.5) then
                setToNextAction()
              end
            elseif action.type == 'stepIntoPortal' then
              if not GMR.IsPlayerPosition(positionBeforeStartedMovingForward.x, positionBeforeStartedMovingForward.y,
                positionBeforeStartedMovingForward.z, 5) then
                setToNextAction()
              end
            elseif action.type == 'fightMobs' then
              local mob = GMR.GetNearbyEnemy()
              if not mob then
                setToNextAction()
              end
            elseif action.type == 'killKrengaath' then
              if GMR.IsObjectiveCompleted(questID, 2) then
                setToNextAction()
              end
            end

            if not isDone then
              if action.type == 'moveToWithGMR' then
                print('GMR.Questing.MoveTo', nextActionIndex)
                GMR.Questing.MoveTo(action.x, action.y, action.z)
              elseif action.type == 'moveTo' then
                if not mover or nextActionIndex ~= lastActionIndex then
                  print('moveTo', nextActionIndex)
                  mover = moveTo3(action)
                end
              elseif action.type == 'stepIntoPortal' then
                if not isMovingForward then
                  positionBeforeStartedMovingForward = GMR.GetPlayerPosition()
                  GMR.MoveForwardStart()
                  isMovingForward = true
                end
              elseif action.type == 'fightMobs' then
                local mob = GMR.GetNearbyEnemy()
                if mob then
                  killEnemy(mob)
                end
              elseif action.type == 'killKrengaath' then
                local KRENGAATH_ID = 163921
                local krengaath = GMR.FindObject(KRENGAATH_ID)
                if krengaath then
                  killEnemy(krengaath)
                end
              end
            end
          end
        end
      }
    end
  }

  local questHandler
  if questHandlers[questID] and type(questHandlers[questID]) == 'function' then
    questHandler = questHandlers[questID]()
  else
    questHandler = questHandlers[questID]
  end

  GMR.DefineQuest(
    race,
    class,
    questID,
    questName,
    'Custom',
    pickUpX,
    pickUpY,
    pickUpZ,
    pickUpObjectID,
    nil,
    nil,
    nil,
    nil,
    {
      (questHandler and questHandler.during) or
        defaultDuring
    },
    (questHandler and questHandler.initial) or
      defaultInitial
  )
end

GMR.DefineQuester('World Quests', function()
  C_Timer.NewTicker(10, function()
    if GMR.IsExecuting() then
      if isMoving() then
        if GMR.IsPlayerPosition(destination.x, destination.y, destination.z, 5) then
          print('has arrived')
          destination = nil
        end
      else
        local questID = GMR.GetQuestId()
        if questID and GMR.IsQuestActive(questID) then
          destination = nil
        else
          if GMR.InCombat() then
            destination = nil
          else
            local mapID = determineZoneMapID()
            goToNextWorldQuestInZone(mapID)
          end
        end
      end
    else
      destination = nil
    end
  end)

  --Quester.defineQuestMuckItUp()
  --Quester.defineQuestAStolenStoneFiend()
  --Quester.defineQuestRetainingTheCourt()
  -- Quester.defineQuestACuriousCache()

  local mapID = determineZoneMapID()
  local quests = addPositionToQuests(retrieveWorldQuestsInZone(mapID))
  quests = filterQuests(quests)
  sortQuestsByDistanceAscending(quests)
  for _, quest in ipairs(quests) do
    defineQuest2(quest.questId)
  end
end)

function findObjectsByName(name)
  local objectsThatMatch = {}
  local objects = GMR.GetNearbyObjects(100)
  for guid, object in pairs(objects) do
    if object.Name == name then
      objectsThatMatch[guid] = object
    end
  end
  return objectsThatMatch
end

local function findQuestWithID(quests, questID)
  return Array.find(quests, function(quest)
    return quest.questID == questID or quest.questId == questID
  end)
end

function determineQuestPosition(questID)
  local mapID = determineZoneMapID()
  local quests = retrieveWorldQuestsInZone(mapID)
  local quest = findQuestWithID(quests, questID)
  if quest then
    local x, y, z = GMR.GetWorldPositionFromMap(mapID, quest.x, quest.y)
    local position = {
      x = x,
      y = y,
      z = z
    }
    return position
  else
    return nil
  end
end

function test322()
  local objects = findObjectsByName('Crate of Salvaged Explosives')
  printTable(objects)
  local objectGUID = next(objects)
  print('objectGUID', objectGUID)
  if objectGUID then
    tooltip:SetUnit('mouseover')
  end
end

-- /dump test322()
