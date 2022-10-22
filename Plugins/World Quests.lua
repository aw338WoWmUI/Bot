local Quester = {}

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
  print('questName', questName)

  local questPosition = determineQuestPosition(questID)
  local lastQuestPosition = questPosition

  print('questPosition')
  printTable(questPosition)

  local questObjectiveToObjectIDs = {}
  _G.abc = questObjectiveToObjectIDs

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

          local questPosition = determineQuestPosition(questID)
          if lastQuestPosition.x ~= questPosition.x or lastQuestPosition.y ~= questPosition.y or lastQuestPosition.z ~= questPosition.z then
            lastQuestPosition = questPosition
            GMR.Questing.MoveTo(questPosition.x, questPosition.y, questPosition.z)
            return
          end

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
              return name == text
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

          if ExtraActionButton1:IsShown() then
            print('GMR.Questing.ExtraActionButton1')
            local playerPosition = GMR.GetPlayerPosition()
            GMR.Questing.ExtraActionButton1(playerPosition.x, playerPosition.y, playerPosition.z)
          else
            local objectIDs = Set.toList(openQuestObjectiveObjectIDs)
            local object = GMR.FindObject(objectIDs)
            if object then
              local x, y, z = GMR.ObjectPosition(object)
              local objectID = GMR.ObjectId(object)

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

              local objectsThatPotentiallyCanBeChargedWith = findObjectsThatCanBeChargedWith()
              if chargeItem(objectsThatPotentiallyCanBeChargedWith) then
                print('GMR.Questing.UseItemOnPosition')
                local playerPosition = GMR.GetPlayerPosition()
                local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
                local itemLink = GetQuestLogSpecialItemInfo(logIndex)
                local itemID = GetItemInfoInstant(itemLink)
                GMR.Questing.UseItemOnPosition(playerPosition.x, playerPosition.y, playerPosition.z, itemID)
                addObjectsThatHasBeenChargedWith(objectsThatPotentiallyCanBeChargedWith)
              elseif GMR.ObjectHasGossip(object) then
                print('GMR.Questing.GossipWith')
                GMR.Questing.GossipWith(x, y, z, objectID)
              elseif GMR.IsObjectInteractable(object) then
                -- FIXME: GMR.IsObjectInteractable might be bugged.
                print('GMR.Questing.InteractWith')
                GMR.Questing.InteractWith(x, y, z, objectID)
              else
                print('GMR.Questing.KillEnemy')
                GMR.Questing.KillEnemy(x, y, z, objectID)
              end
            else
              GMR.Questing.MoveTo(questPosition.x, questPosition.y, questPosition.z)
            end
          end
        end
      },
      function()
        print('profileData')
        GMR.SkipTurnIn(true)
        GMR.DefineProfileCenter(questPosition.x, questPosition.y, questPosition.z)
        GMR.Questing.MoveTo(questPosition.x, questPosition.y, questPosition.z)
      end
    )
  end
end

GMR.DefineQuester('World Quests', function()
  Quester.defineQuestMuckItUp()
  Quester.defineQuestAStolenStoneFiend()
  Quester.defineQuestRetainingTheCourt()
  -- Quester.defineQuestACuriousCache()
  defineQuest(59905)
  defineQuest(59578)
  defineQuest(62235)
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

local function retrieveWorldQuestsInZone(uiMapID)
  local quests = C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID)
  return quests
end

local ZERETH_MORTIS_UI_MAP_ID = 1970
local BASTION_UI_MAP_ID = 1533
local REVENDRETH_UI_MAP_ID = 1525

local zoneMapIDs = Set.create({
  ZERETH_MORTIS_UI_MAP_ID,
  BASTION_UI_MAP_ID,
  REVENDRETH_UI_MAP_ID
})

local function determineZoneMapID()
  local mapID = MapUtil.GetDisplayableMapForPlayer()
  if Set.contains(zoneMapIDs, mapID) then
    return mapID
  elseif mapID == 1700 then
    return REVENDRETH_UI_MAP_ID
  end
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
      z = GMR.GetZCoordinate(x, y, 100000) or 10000
    }
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
