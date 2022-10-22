local Quester = {}

local function goTo(position)
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end
  GMR.MeshTo(position.x, position.y, position.z)
end

local ZERETH_MORTIS_UI_MAP_ID = 1970
local BASTION_UI_MAP_ID = 1533
local REVENDRETH_UI_MAP_ID = 1525

local zoneMapIDs = Set.create({
  ZERETH_MORTIS_UI_MAP_ID,
  BASTION_UI_MAP_ID,
  REVENDRETH_UI_MAP_ID
})

local function distance2d(a, b)
  return math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2))
end

local function determineZoneMapID()
  local mapID = MapUtil.GetDisplayableMapForPlayer()
  if Set.contains(zoneMapIDs, mapID) then
    return mapID
  elseif mapID == 1700 then
    return REVENDRETH_UI_MAP_ID
  end
end

local function addPositionToQuest(quest)
  local x, y, z = GMR.GetWorldPositionFromMap(quest.mapID, quest.x, quest.y)
  quest.position = {
    x = x,
    y = y,
    z = GMR.GetZCoordinate(x, y, 100000) or 5000
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

local function filterQuests(quests)
  return Array.filter(quests, function(quest)
    return not quest.isDaily and hasTagInfo(quest) and not isPetBattleWorldQuest(quest)
  end)
end

local function retrieveWorldQuestsInZone(mapID)
  local quests = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)
  return quests
end

local destination = nil

local function goToNextWorldQuestInZone(mapID)

  local quests = addPositionToQuests(retrieveWorldQuestsInZone(mapID))
  quests = filterQuests(quests)
  local quest = findClosestQuest(quests)
  print('goToNextWorldQuestInZone: ' .. QuestUtils_GetQuestName(quest.questId))
  goTo(quest.position)
  destination = quest.position
end

local function isMoving()
  return destination ~= nil
end

C_Timer.NewTicker(1, function()
  if GMR.IsExecuting() then
    if isMoving() then
      if GMR.IsPlayerPosition(destination.x, destination.y, destination.z, 5) then
        print('has arrived')
        destination = nil
      end
    else
      if not GMR.IsQuesting() then
        local mapID = determineZoneMapID()
        goToNextWorldQuestInZone(mapID)
      end
    end
  else
    destination = nil
  end
end)

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

function defineQuest(questID)
  local questName = QuestUtils_GetQuestName(questID)

  print('defineQuest', questName)

  local questPosition = determineQuestPosition(questID)

  print('questPosition')
  printTable(questPosition)

  local questObjectiveToObjectIDs = {}

  local function addObjectIDToObjective(objectID, questObjectiveIndex)
    if not questObjectiveToObjectIDs[questObjectiveIndex] then
      questObjectiveToObjectIDs[questObjectiveIndex] = {}
    end
    questObjectiveToObjectIDs[questObjectiveIndex][objectID] = true
  end

  local function findObjectiveWhichMatchesAndAddItToTheLookup(questInfo, objectIdentifier, doesMatch)
    local questObjective, questObjectiveIndex = Array.find(questInfo, doesMatch)
    if questObjective then
      local objectID = GMR.ObjectId(objectIdentifier)
      if objectID then
        addObjectIDToObjective(objectID, questObjectiveIndex)
      end
    end

    return questObjective ~= nil
  end

  local race = { 'Alliance', 'Horde' }
  local class = nil

  if questPosition then
    local objectsThatHasBeenChargedWith = Set.create()

    GMR.DefineQuest(
      race,
      class,
      questID,
      questName,
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

          _G.abc = questObjectiveToObjectIDs

          local questInfo = GMR.Questing.GetQuestInfo(questID)

          for i = 1, 40 do
            local unitID = 'nameplate' .. i
            tooltip:SetUnit(unitID)
            for lineIndex = 1, 18 do
              local textLeft = _G['QuesterTooltipTextLeft' .. lineIndex]
              if textLeft then
                local text = textLeft:GetText()
                if text == questName then
                  for lineIndex2 = lineIndex + 1, 18 do
                    local textLeft = _G['QuesterTooltipTextLeft' .. lineIndex2]
                    if textLeft then
                      local text = textLeft:GetText()
                      local hasFoundQuestObjective = findObjectiveWhichMatchesAndAddItToTheLookup(questInfo, unitID,
                        function(questObjective)
                          return questObjective.text == text
                        end)
                      if not hasFoundQuestObjective then
                        break
                      end
                    end
                  end
                end
              end
            end
          end

          local objects = GMR.GetNearbyObjects(250)
          for objectGUID, object in pairs(objects) do
            local objectName = object.Name
            findObjectiveWhichMatchesAndAddItToTheLookup(questInfo, objectGUID, function(questObjective)
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

          addIndexToQuestObjectives(questInfo)

          local openQuestObjectives = Array.filter(questInfo, function(questObjective)
            return not questObjective.finished
          end)

          local openQuestObjectiveObjectIDs = Set.union(
            unpack(
              Array.filter(
                Array.map(openQuestObjectives, function(questObjective)
                  return questObjectiveToObjectIDs[questObjective.index]
                end),
                Function.isTrue
              )
            )
          )

          local objectIDs = Set.toList(openQuestObjectiveObjectIDs)
          local object = GMR.FindObject(objectIDs)

          local function findObjectsThatCanBeChargedWith()
            if questID == 62235 and not GMR.Questing.IsObjectiveCompleted(questID, 2) then
              -- Objective text: 0/1 Allaying Crook charged
              -- Item name: Korinna's Allaying Crook
              local range = 20
              local objects = GMR.GetNearbyObjects(range)
              local objectsThatPotentiallyCanBeChargedWith = Array.filter(
                includeGUIDInObject(objects),
                function(object)
                  return (
                    questObjectiveToObjectIDs[2][object.ID] and
                      GMR.IsDead(object.GUID) and
                      not objectsThatHasBeenChargedWith[object.GUID]
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
              objectsThatHasBeenChargedWith[object.GUID] = true
            end
          end

          local function retrieveExtraActionButton1ActionDescriptionText()
            tooltip:SetAction(ExtraActionButton1.action)
              local descriptionText = QuesterTooltipTextLeft4:GetText()
            return descriptionText
          end

          local function doesQuestObjectiveTextContainAnIndicatorThatSomethingIsRequiredToBeActivated(questObjective)
            return string.match(questObjective.text, ' activated$')
          end

          local function doesExtraActionButtonActionContainAnIndicatorThatItActivatesSomething()
            local descriptionText = retrieveExtraActionButton1ActionDescriptionText()
            return string.match(descriptionText, '^Activate the targeted .+ unit.$')
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

          local objectsThatPotentiallyCanBeChargedWith = findObjectsThatCanBeChargedWith()
          local questPosition = determineQuestPosition(questID)
          if chargeItem(objectsThatPotentiallyCanBeChargedWith) then
            print('GMR.Questing.UseItemOnPosition')
            local playerPosition = GMR.GetPlayerPosition()
            local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
            local itemLink = GetQuestLogSpecialItemInfo(logIndex)
            local itemID = GetItemInfoInstant(itemLink)
            GMR.Questing.UseItemOnPosition(playerPosition.x, playerPosition.y, playerPosition.z, itemID)
            addObjectsThatHasBeenChargedWith(objectsThatPotentiallyCanBeChargedWith)
            --elseif object and GMR.ObjectHasGossip(object) then
            --  -- FIXME: GMR.ObjectHasGossip seems to also return true for normal mobs.
            --  print('GMR.Questing.GossipWith')
            --  local x, y, z = GMR.ObjectPosition(object)
            --  local objectID = GMR.ObjectId(object)
            --  GMR.Questing.GossipWith(x, y, z, objectID, nil, 5)
          elseif object and GMR.UnitCanAttack('player', object) then
            -- FIXME: Only kill mobs which contribute to quest progress (non-gray, not attacked by a character of the other faction)
            print('GMR.Questing.KillEnemy')
            local x, y, z = GMR.ObjectPosition(object)
            local objectID = GMR.ObjectId(object)
            GMR.Questing.KillEnemy(x, y, z, objectID)
          elseif (
            ExtraActionBarFrame:IsShown() and
              ExtraActionButton1:IsShown() and
              IsUsableAction(ExtraActionButton1.action) and
              GetActionCooldown(ExtraActionButton1.action) == 0 and
              not seemsToRequireToBeCloseToQuestMarker()
          ) then
            print('GMR.Questing.ExtraActionButton1')
            local playerPosition = GMR.GetPlayerPosition()
            if GMR.IsFlyingMount(GMR.GetMount()) then
              local z = GMR.GetZCoordinate(playerPosition.x, playerPosition.y, playerPosition.z)
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
          elseif object then
            -- FIXME: GMR.IsObjectInteractable might be bugged.
            print('GMR.Questing.InteractWith')
            local x, y, z = GMR.ObjectPosition(object)
            local objectID = GMR.ObjectId(object)
            GMR.Questing.InteractWith(x, y, z, objectID, nil, 5)
          elseif not GMR.IsPlayerPosition(questPosition.x, questPosition.y, questPosition.z, 5) then
            GMR.Questing.MoveTo(questPosition.x, questPosition.y, questPosition.z)
          end
        end
      },
      function()
        print('profileData')
        GMR.SkipTurnIn(true)
        GMR.Questing.MoveTo(questPosition.x, questPosition.y, questPosition.z)
      end
    )
  end
end

GMR.DefineQuester('World Quests', function()
  --Quester.defineQuestMuckItUp()
  --Quester.defineQuestAStolenStoneFiend()
  --Quester.defineQuestRetainingTheCourt()
  -- Quester.defineQuestACuriousCache()

  local mapID = determineZoneMapID()
  local quests = addPositionToQuests(retrieveWorldQuestsInZone(mapID))
  quests = filterQuests(quests)
  sortQuestsByDistanceAscending(quests)
  for _, quest in ipairs(quests) do
    defineQuest(quest.questId)
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
    return quest.questId == questID
  end)
end

function determineQuestPosition(questID)
  local mapID = determineZoneMapID()
  local quests = retrieveWorldQuestsInZone(mapID)
  local quest = findQuestWithID(quests, questID)
  if quest then
    local x, y, z = GMR.GetWorldPositionFromMap(quest.mapID, quest.x, quest.y)
    local position = {
      x = x,
      y = y,
      z = nil
    }
    local playerPosition = GMR.GetPlayerPosition()
    if C_Navigation.GetTargetState() ~= Enum.NavigationState.Invalid and distance2d(playerPosition, position) <= 3 and C_Navigation.GetDistance() > 3 then
      -- 1.63     -1.65
      --      -3.11
      position.z = playerPosition.z - C_Navigation.GetDistance()
    else
      position.z = GMR.GetZCoordinate(x, y, 100000) or 6000
    end
    return position
  else
    return nil
  end
end

function includeGUIDInObject(objects)
  local result = {}
  for GUID, object in pairs(objects) do
    object.GUID = GUID
    table.insert(result, object)
  end
  return result
end
