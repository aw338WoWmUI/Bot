Unlocker = {}

Unlocker.QuestGiverStatuses = {
  Quest = 10
}

function Unlocker.retrieveQuestGiverStatus(object)
  return HWT.ObjectQuestGiverStatus(object)
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
  elseif objectID == 209463 then
    -- Calling HWT.ObjectQuests with a pointer to an object with this object ID seems to crash the game.
    if GMR.IsQuestActive(29627) and not GMR.Questing.IsObjectiveCompleted(29627, 1) then
      return { 29627 }
    else
      return {}
    end
  else
    return HWT.ObjectQuests(object)
  end
end
