local addOnName, AddOn = ...

-- Requires in-game language: English

-- /dump C_AreaPoiInfo.GetAreaPOIForMap(w)

local function retrieveQuestLogQuests()
  local questIDs = retrieveQuestLogQuestIDs()
  return Array.map(questIDs, function(questID)
    return QuestieDB:GetQuest(questID)
  end)
end

local questGivers = {
  {
    objectID = 128229,
    continentID = 1643,
    x = -1683.21875,
    y = -1351.5798339844,
    z = 32.000263214111,
    questIDs = {
      49178,
      49226,
    }
  },
  {
    objectID = 128228,
    continentID = 1643,
    x = -1678.6076660156,
    y = -1351.6735839844,
    z = 31.664106369019,
    questIDs = {
      49230,
    }
  }
}

local function retrieveQuestStartPoints()
  local continentID = select(8, GetInstanceInfo())
  local mapID = GMR.GetMapId()
  local questLines = retrieveAvailableQuestLines()
  local points1 = Array.selectTrue(Array.map(questLines, function(questLine)
    local questIDs = C_QuestLine.GetQuestLineQuests(questLine.questLineID)
    local questID = Array.find(questIDs, function(questID)
      return not GMR.IsQuestCompleted(questID)
    end)
    if not GMR.IsQuestActive(questID) then
      local questInfo = C_QuestLine.GetQuestLineInfo(questID, mapID)
      local x, y, z = GMR.GetWorldPositionFromMap(mapID, questInfo.x, questInfo.y)
      return {
        objectID = nil,
        continentID = continentID,
        x = x,
        y = y,
        z = z,
        type = 'acceptQuest',
        questIDs = {
          questID
        }
      }
    else
      return nil
    end
  end))

  local points2 = Array.map(
    Array.filter(questGivers, function(questGiver)
      return Array.any(questGiver.questIDs, function(questID)
        return not GMR.IsQuestCompleted(questID)
      end)
    end),
    function(questGiver)
      local point = Object.copy(questGiver)
      point.type = 'acceptQuest'
    end
  )

  return Array.concat(points1, points2)
end

function retrieveObjectivePoints()
  local mapID = GMR.GetMapId()
  local quests = C_QuestLog.GetQuestsOnMap(mapID)
  return Array.map(quests, function(quest)
    local x, y, z = GMR.GetWorldPositionFromMap(mapID, quest.x, quest.y)
    return {
      x = x,
      y = y,
      z = z,
      type = 'objective',
      questID = quest.questID
    }
  end)
end

--C_AreaPoiInfo.GetAreaPOIForMap(GMR.GetMapId())
--C_QuestLine.GetAvailableQuestLines(GMR.GetMapId())
--C_QuestLine.GetQuestLineInfo(48421, GMR.GetMapId())
--C_QuestLine.GetQuestLineQuests(586)
--C_QuestLine.GetQuestLineInfo(49178, GMR.GetMapId())

function retrieveAvailableQuestLines()
  local mapID = GMR.GetMapId()
  local questLines = C_QuestLine.GetAvailableQuestLines(mapID)
  print('D1')
  if #questLines == 0 then
    print('D2')
    local wasSuccessful, event, requestRequired = Events.waitForEvent('QUESTLINE_UPDATE', 1)
    print('D3')
    if wasSuccessful and requestRequired then
      print('D4')
      C_QuestLine.RequestQuestLinesForMap(mapID)
      print('D5')
      local wasSuccessful2, event2, requestRequired2 = Events.waitForEvent('QUESTLINE_UPDATE')
      print('D6')
      questLines = C_QuestLine.GetAvailableQuestLines(mapID)
      print('D7')
    end
    print('D8')
  end
  print('D9')
  return questLines
end

function toBoolean(value)
  return not not value
end

local isObjectRelatedToActiveQuestLookup = {}

local objectIDQuestRelations = {}

function isObjectRelatedToAnyActiveQuest(object)
  local objectID = GMR.ObjectId(object)
  if isObjectRelatedToActiveQuestLookup[objectID] then
    return toBoolean(isObjectRelatedToActiveQuestLookup[objectID])
  elseif UnitName('softtarget') == GameTooltipTextLeft1:GetText() then
    local relations = findRelationsToQuests('GameTooltip', 'softinteract')
    objectIDQuestRelations[objectID] = relations
    return Array.any(Object.entries(relations), function(entry)
      local questID = entry.key
      local objectiveIndexesThatObjectIsRelatedTo = entry.value
      return (
        not GMR.IsQuestActive(questID) and
          Set.containsWhichFulfillsCondition(objectiveIndexesThatObjectIsRelatedTo, function(objectiveIndex)
            return not GMR.Questing.IsObjectiveCompleted(questID, objectiveIndex)
          end)
      )
    end)
  end
end

function updateIsObjectRelatedToActiveQuestLookup()
  local unitTokens = {
    'target',
    'softenemy',
    'softfriend',
    'softinteract'
  }
  for i = 1, 40 do
    local unitToken = 'nameplate' .. i
    table.insert(unitTokens, unitToken)
  end
  Array.forEach(unitTokens, function(unitToken)
    local objectID = GMR.ObjectId(unitToken)
    if objectID then
      if C_QuestLog.UnitIsRelatedToActiveQuest(unitToken) then
        isObjectRelatedToActiveQuestLookup[objectID] = true
      else
        isObjectRelatedToActiveQuestLookup[objectID] = nil
      end
    end
  end)
  if GMR.IsQuestActive(48505) then
    isObjectRelatedToActiveQuestLookup[126158] = true
    isObjectRelatedToActiveQuestLookup[126490] = true
  end
end

function convertObjectPointersToObjectPoints(objectPointers, type)
  return Array.selectTrue(
    Array.map(objectPointers, function(pointer)
      local pointer = GMR.ObjectPointer(pointer)
      if pointer then
        local x, y, z = GMR.ObjectPosition(pointer)
        return {
          name = GMR.ObjectName(pointer),
          x = x,
          y = y,
          z = z,
          type = type,
          pointer = pointer,
          objectID = GMR.ObjectId(pointer)
        }
      else
        return nil
      end
    end)
  )
end

function isQuestRelatedObject(object)
  local objectID = GMR.ObjectId(object)
  if objectID then
    local exploredObject = exploredObjects[objectID]
    if exploredObject then
      return exploredObject.isQuestGiver
    end
  end

  return false
end

function retrieveObjectPoints()
  local objects = includeGUIDInObject(GMR.GetNearbyObjects(250))
  objects = Array.filter(objects, function(object)
    return (isObjectRelatedToAnyActiveQuest(object.GUID) or seemsToBeQuestObject(object.GUID)) and not GMR.IsDead(object.GUID) and
      isQuestRelatedObject(object.GUID)
  end)
  local objectPointers = Array.map(objects, function(object)
    return object.GUID
  end)

  return convertObjectPointersToObjectPoints(objectPointers, 'object')
end

function retrieveExplorationPoints()
  local objects = includeGUIDInObject(GMR.GetNearbyObjects(250))
  objects = Array.filter(objects, function(object)
    return not exploredObjects[object.ID] and not (isObjectRelatedToAnyActiveQuest(object.GUID) or seemsToBeQuestObject(object.GUID)) and not GMR.IsDead(object.GUID) and isInteractable(object.GUID)
  end)
  local objectPointers = Array.map(objects, function(object)
    return object.GUID
  end)

  local points = convertObjectPointersToObjectPoints(objectPointers, 'exploration')

  return points
end

local function retrievePoints()
  return {
    questStartPoints = retrieveQuestStartPoints(),
    objectivePoints = retrieveObjectivePoints(),
    objectPoints = retrieveObjectPoints(),
    explorationPoints = retrieveExplorationPoints()
  }
end

function calculatePathLength(path)
  local previousPoint = path[1]
  return Array.reduce(Array.slice(path, 2), function(length, point)
    length = length + GMR.GetDistanceBetweenPositions(
      previousPoint[1],
      previousPoint[2],
      previousPoint[3],
      point[1],
      point[2],
      point[3]
    )
    previousPoint = point
    return length
  end, 0)
end

function determineMeshDistance(point)
  local path = GMR.GetPath(point.x, point.y, point.z)
  if path then
    return calculatePathLength(path)
  else
    return nil
  end
end

local function determineClosestPoint(points)
  local playerPosition = GMR.GetPlayerPosition()
  return Array.min(points, function(point)
    if point then
      local distance = GMR.GetDistanceBetweenPositions(
        playerPosition.x,
        playerPosition.y,
        playerPosition.z,
        point.x,
        point.y,
        point.z
      )

      return distance
    else
      return 99999999999
    end
  end)
end

local function determinePointToGo(points)
  local closeQuestStartPoints = Array.filter(points.questStartPoints, function(point)
    return GMR.GetDistanceToPosition(point.x, point.y, point.z) <= 50
  end)
  if next(closeQuestStartPoints) then
    return determineClosestPoint(closeQuestStartPoints)
  elseif next(points.objectPoints) then
    return determineClosestPoint(points.objectPoints)
  else
    print(1)
    if next(points.explorationPoints) then
      print(3)
      return determineClosestPoint(points.explorationPoints)
    else
      local points2 = Array.concat(points.questStartPoints, points.objectivePoints)
      if next(points2) then
        print(2)
        return determineClosestPoint(points2)
      else
        return nil
      end
    end
    print(4)
  end
end

local function moveToPoint(point)
  print(tableToString(point, 1))
  if point.type == 'acceptQuest' then
    print('acceptQuest', point.x, point.y, point.z, point.objectID)
    if point.objectID then
      GMR.Questing.InteractWith(point.x, point.y, point.z, point.objectID)
    else
      GMR.Questing.MoveTo(point.x, point.y, point.z)
    end
  elseif point.type == 'object' then
    print('object', point.x, point.y, point.z, point.objectID)
    if GMR.UnitCanAttack('player', point.pointer) then
      GMR.Questing.KillEnemy(point.x, point.y, point.z, point.objectID)
    elseif GMR.ObjectHasGossip(point.pointer) or next(C_GossipInfo.GetOptions()) then
      print('GossipWith')
      gossipWithAt(point.x, point.y, point.z, point.objectID)
    elseif isInteractable(point.pointer) then
      print('InteractWith')
      interactWithAt(point.x, point.y, point.z, point.objectID)
    else
      print('move to', point.x, point.y, point.z, point.objectID)
      GMR.Questing.MoveTo(point.x, point.y, point.z)
    end
  elseif point.type == 'exploration' then
    local name = GMR.ObjectName(point.pointer)
    print('explore object', name)
    exploreObject(point.pointer)
  else
    print('moveToPoint', point.x, point.y, point.z)
    GMR.Questing.MoveTo(point.x, point.y, point.z)
  end
end

local pointToMove = nil

local ticker
ticker = C_Timer.NewTicker(0, function()
  if _G.GMR and GMR.LibDraw and GMR.LibDraw.clearCanvas then
    ticker:Cancel()
    hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
      if pointToMove then
        GMR.LibDraw.GroundCircle(pointToMove.x, pointToMove.y, pointToMove.z, 3)
      end
    end)
  end
end)

local previousPointToGo = nil

function isDifferentPointThanPrevious(point)
  if point.pointer and previousPointToGo and previousPointToGo.pointer then
    return point.pointer ~= previousPointToGo.pointer
  else
    return true
  end
end

function moveToClosestPoint()
  local points = retrievePoints()
  local pointToGo = determinePointToGo(points)
  if pointToGo then
    if isDifferentPointThanPrevious(pointToGo) then
      previousPointToGo = pointToGo
    else
      pointToGo = previousPointToGo
    end
    moveToPoint(pointToGo)
  end
  pointToMove = pointToGo
end

function canInteractWithQuestGiver()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      local texture = icon:GetTexture()
      if texture == 'Cursor Quest' then
        return true
      end
    end
  end

  return false
end

function interactWithQuestGiver()
  local unitToken = 'softinteract'
  GMR.Interact(unitToken)
end

function canInteractWithObject()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      local texture = icon:GetTexture()
      if texture == 4675650 then
        return true
      end
    end
  end

  return false
end

function interactWithObject()
  local unitToken = 'softinteract'
  GMR.Interact(unitToken)
end

function canGossipWithObject()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      local texture = icon:GetTexture()
      if texture == 'Cursor Speak' then
        return true
      end
    end
  end

  return false
end

function gossipWithObject()
  local unitToken = 'softinteract'
  GMR.Interact(unitToken)
end

function canTurnInQuest()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      local texture = icon:GetTexture()
      if texture == 'Cursor QuestTurnIn' then
        return true
      end
    end
  end

  return false
end

function turnInQuest()
  local unitToken = 'softinteract'
  GMR.Interact(unitToken)
end

function canExploreSoftInteractObject()
  local objectID = GMR.ObjectId('softinteract')
  if objectID then
    return not exploredObjects[objectID]
  else
    return false
  end
end

function waitForGossipDialog()
  Events.waitForEvent('GOSSIP_SHOW')
end

function exploreObject(object)
  local maxDistance = math.min(
    tonumber(GetCVar('SoftTargetInteractRange'), 10),
    15.5
  )
  local pointer = GMR.ObjectPointer(object)
  local x, y, z = GMR.ObjectPosition(pointer)
  local distanceToObject = GMR.GetDistanceBetweenObjects('player', object)
  if distanceToObject <= maxDistance then
    GMR.FaceDirection(x, y, z)
    if pointer ~= GMR.ObjectPointer('softinteract') then
      GMR.TargetObject(pointer)
    end
    local skipSaving = false
    local softInteractPointer = GMR.ObjectPointer('softinteract')
    local objectID = GMR.ObjectId(pointer)
    local softInteractObjectID = GMR.ObjectId(softInteractPointer)
    if softInteractPointer and objectID == softInteractObjectID then
      local softInteractX, softInteractY, softInteractZ = GMR.ObjectPosition(softInteractPointer)
      local exploredObject = {
        positions = {
          {
            x = softInteractX,
            y = softInteractY,
            z = softInteractZ
          }
        }
      }

      local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
      if namePlate then
        local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
        if icon:IsShown() then
          local texture = icon:GetTexture()
          if texture == 'Cursor UnableInnkeeper' then
            GMR.Questing.MoveTo(x, y, z)
            skipSaving = true
          elseif texture == 'Cursor Quest' or texture == 'Cursor UnableQuest' then
            exploredObject.isQuestGiver = true
          elseif texture == 4675702 or -- Inactive hand
            texture == 4675650 then
            -- Active hand
            exploredObject.isInteractable = true
          elseif texture == 'Cursor Innkeeper' then
            exploredObject.isInnkeeper = true
            local objectID = GMR.ObjectId(pointer)
            GMR.DefineHearthstoneBindLocation(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
            GMR.Interact(softInteractPointer)
            waitForGossipDialog()
            local options = C_GossipInfo.GetOptions()
            local canVendor = Array.any(options, function(option)
              return option.icon == 132060
            end)
            if canVendor then
              exploredObject.isGoodsVendor = true
              GMR.DefineGoodsVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
              exploredObject.isSellVendor = true
              GMR.DefineSellVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
            end
          elseif texture == 'Cursor RepairNPC' or texture == 'Cursor UnableRepairNPC' then
            exploredObject.isSellVendor = true
            GMR.DefineSellVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
            exploredObject.isRepairVendor = true
            GMR.DefineRepairVendor(softInteractX, softInteractY, softInteractZ, softInteractObjectID)
          end
        end
      end

      if not skipSaving then
        exploredObjects[softInteractObjectID] = exploredObject
      end
    elseif distanceToObject <= 4 then
      local exploredObject = {
        positions = {
          {
            x = x,
            y = y,
            z = z
          }
        }
      }
      exploredObjects[objectID] = exploredObject
    else
      print('move to')
      GMR.Questing.MoveTo(x, y, z)
    end
  else
    GMR.Questing.MoveTo(x, y, z)
  end
end

function exploreSoftInteractObject()
  exploreObject('softinteract')
end

local isRunning = false

function isIdle()
  local questID = GMR.GetQuestId()
  return (
    not GMR.InCombat() and
      not (questID and GMR.IsQuestActive(questID) and not GMR.IsQuestCompletable(questID)) and
      not GMR.IsQuesting() and
      not GMR.IsCasting() and
      not GMR.IsSelling() and
      not GMR.IsAttacking() and
      (not GMR.IsClassTrainerNeeded or not GMR.IsClassTrainerNeeded()) and
      not GMR.IsDead() and
      not GMR.IsDrinking() and
      not GMR.IsEating() and
      not GMR.IsFishing() and
      not GMR.IsLooting() and
      not GMR.IsMailing() and
      not seemsThatIsGoingToCreateHealthstone() and
      not GMR.IsUnstuckEnabled() and
      not GMR.IsPreparing() and
      not GMR.IsGhost('player') and
      not GMR.IsRepairing()
  )
end

function seemsThatIsGoingToRepair()
  return GMR_SavedVariablesPerCharacter.Repair and GMR.GetRepairStatus() <= GMR.GetRepairValue()
end

function efficientlyLevelToMaximumLevel()
  if not isRunning then
    isRunning = true

    for objectID, object in pairs(exploredObjects) do
      if object.isInnkeeper then
        GMR.DefineHearthstoneBindLocation(object.x, object.y, object.z, objectID)
      end
      if object.isGoodsVendor then
        GMR.DefineGoodsVendor(object.x, object.y, object.z, objectID)
      end
      if object.isSellVendor then
        GMR.DefineSellVendor(object.x, object.y, object.z, objectID)
      end
      if object.isRepairVendor then
        GMR.DefineRepairVendor(object.x, object.y, object.z, objectID)
      end
    end

    local run
    run = function()
      local thread = coroutine.create(function()
        if GMR.IsExecuting() and GMR.InCombat() and not GMR.IsAttacking() then
          local pointer = GMR.GetAttackingEnemy()
          if pointer then
            local x, y, z = GMR.ObjectPosition(pointer)
            local objectID = GMR.ObjectId(pointer)
            GMR.Questing.KillEnemy(x, y, z, objectID)
          end
        end
        if GMR.IsExecuting() and isIdle() then
          pointToMove = nil
          if QuestFrameProgressPanel:IsShown() and IsQuestCompletable() then
            CompleteQuest()
          elseif QuestFrameRewardPanel:IsShown() then
            GetQuestReward(1)
          elseif QuestFrameDetailPanel:IsShown() then
            AcceptQuest()
          elseif GossipFrame:IsShown() and C_GossipInfo.GetNumActiveQuests() >= 1 then
            local activeQuests = C_GossipInfo.GetActiveQuests()
            local activeQuest = activeQuests[1]
            C_GossipInfo.SelectActiveQuest(activeQuest.questID)
          elseif GossipFrame:IsShown() and C_GossipInfo.GetNumAvailableQuests() >= 1 then
            local availableQuests = C_GossipInfo.GetAvailableQuests()
            local availableQuest = availableQuests[1]
            C_GossipInfo.SelectAvailableQuest(availableQuest.questID)
          elseif GossipFrame:IsShown() and #C_GossipInfo.GetOptions() >= 1 then
            local options = C_GossipInfo.GetOptions()
            local option = options[1]
            C_GossipInfo.SelectOption(option.gossipOptionID)
          elseif canInteractWithQuestGiver() then
            interactWithQuestGiver()
          elseif canInteractWithObject() then
            interactWithObject()
          elseif canGossipWithObject() then
            gossipWithObject()
          elseif canTurnInQuest() then
            turnInQuest()
          elseif canExploreSoftInteractObject() then
            exploreSoftInteractObject()
          else
            print('D1')
            local questIDs = retrieveQuestLogQuestIDs()

            Array.forEach(questIDs, function(questID)
              if C_QuestLog.IsFailed(questID) then
                GMR.AbandonQuest(questID)
              end
            end)

            local itemID = Array.find(questIDs, function(questID)
              local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
              if logIndex then
                local itemLink = GetQuestLogSpecialItemInfo(logIndex)
                if itemLink then
                  local itemID = GetItemInfoInstant(itemLink)
                  local startTime, _, enable = GetItemCooldown(itemID)
                  return startTime == 0 and enable == 1
                end
              end

              return false
            end)
            print('D2')

            if itemID then
              local itemLink = select(2, GetItemInfo(itemID))
              print('use item', itemLink)
              local x, y, z = GMR.GetPlayerPosition()
              GMR.Questing.UseItemOnPosition(x, y, z, itemID)
            end

            print('A1')
            updateIsObjectRelatedToActiveQuestLookup()
            print('A3')
            moveToClosestPoint()
            print('A2')
          end
        end
        C_Timer.After(1, run)
      end)
      local wasSuccessful, errorMessage = coroutine.resume(thread)
      if not wasSuccessful then
        error(errorMessage .. '\n' .. debugstack(thread), 0)
      end
    end

    run()
  end
end

-- Cursor Quest
-- Cursor UnableQuest
-- 5, friendly
function aaaaaaa()
  local namePlate = C_NamePlate.GetNamePlateForUnit('softinteract', issecure())
  if namePlate then
    local icon = namePlate.UnitFrame.SoftTargetFrame.Icon
    if icon:IsShown() then
      logToFile('icon: ' .. icon:GetTexture())
    end
  end
end

--GMR.ObjectDynamicFlags('target')
--GMR.ObjectRawType('target')

-- C_QuestItemUse.CanUseQuestItemOnObject(ItemLocation:CreateFromBagAndSlot(0, 1), 'target', false)
-- C_QuestItemUse.CanUseQuestItemOnObject(ItemLocation:CreateFromBagAndSlot(0, 1), 'target', true)
-- C_Item.GetItemName(ItemLocation:CreateFromBagAndSlot(0, 1))

local function initializeSavedVariables()
  if exploredObjects == nil then
    -- objectID to flags
    exploredObjects = {}
  end
end

local function onAddonLoaded(name)
  if name == 'Questing' then
    initializeSavedVariables()
  end
end

local function onEvent(self, event, ...)
  if event == 'ADDON_LOADED' then
    onAddonLoaded(...)
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', onEvent)
