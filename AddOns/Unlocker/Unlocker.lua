Unlocker = {}

Unlocker.QuestGiverStatuses = {
  Quest = 10
}

function Unlocker.retrieveQuestGiverStatus(object)
  return HWT.ObjectQuestGiverStatus(object)
end

-- Calling HWT.ObjectQuests with a pointer to an object with this object IDs seems to crash the game.
local objectIDsToQuests = {
  [209436] = {
    [29619] = {
      [1] = true
    }
  },
  [209463] = {
    [29627] = {
      [1] = true
    }
  },
  [203972] = {
    [26230] = {
      [2] = true
    }
  }
}

function Unlocker.ObjectQuests(object)
  local gameObjectType, gameObjectTypeText = HWT.GameObjectType(object)
  if gameObjectType == 4 or gameObjectTypeText == 'chest' then
    log('game object', gameObjectType, gameObjectTypeText, GMR.ObjectName(object))
  end

  local objectID = HWT.ObjectId(object)
  local quests = objectIDsToQuests[objectID]
  if quests then
    local questIDs = Set.create()
    for questID, objectives in ipairs(quests) do
      if GMR.IsQuestActive(questID) then
        for objectiveIndex in pairs(objectives) do
          if GMR.Questing.IsObjectiveCompleted(questIDs, objectiveIndex) then
            Set.add(questIDs, questID)
            break
          end
        end
      end
    end
    return Set.toList(questIDs)
  else
    return { HWT.ObjectQuests(object) }
  end
end
