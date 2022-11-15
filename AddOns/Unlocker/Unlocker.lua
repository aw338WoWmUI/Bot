Unlocker = {}

Unlocker.QuestGiverStatuses = {
  Quest = 10
}

function Unlocker.retrieveQuestGiverStatus(object)
  print('HWT.ObjectQuestGiverStatus A')
  local result = { pcall(HWT.ObjectQuestGiverStatus, object) }
  print('HWT.ObjectQuestGiverStatus B')
  local wasSuccessful = result[1]
  if wasSuccessful then
    return result[2]
  else
    print('error with HWT.ObjectQuestGiverStatus')
    DevTools_Dump(result)
    return 0
  end
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
    print('HWT.ObjectQuests A')
    local result = { pcall(HWT.ObjectQuests, object) }
    print('HWT.ObjectQuests B')
    local wasSuccessful = result[1]
    if wasSuccessful then
      return Array.slice(result, 2)
    else
      print('error with HWT.ObjectQuests')
      DevTools_Dump(result)
    end
  end
end
