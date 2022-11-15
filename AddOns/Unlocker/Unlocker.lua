Unlocker = {}

Unlocker.QuestGiverStatuses = {
  Quest = 10
}

function Unlocker.retrieveQuestGiverStatus(object)
  print('object', object, GMR.ObjectExists(object))
  local result = HWT.ObjectQuestGiverStatus(object)
  print(2)
  return result
end

function Unlocker.ObjectQuests(object)
  local objectID = HWT.ObjectId(object)
  if objectID == 209436 then
    -- Calling HWT.ObjectQuests with a pointer to an object with this object ID seems to crash the game.
    if GMR.IsQuestActive(29619) and not GMR.Questing.IsObjectiveCompleted(29619, 1) then
      return { 29619 }
    else
      return {}
    end
  else
    return { HWT.ObjectQuests(object) }
  end
end
