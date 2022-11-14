Unlocker = {}

Unlocker.QuestGiverStatuses = {
  Quest = 10
}

function Unlocker.retrieveQuestGiverStatus(object)
  return HWT.ObjectQuestGiverStatus(object)
end
