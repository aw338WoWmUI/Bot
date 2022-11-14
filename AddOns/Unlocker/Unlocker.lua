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
