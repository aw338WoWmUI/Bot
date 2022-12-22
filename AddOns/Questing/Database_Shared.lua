Questing = Questing or {}
Questing.Database = Questing.Database or {}

function Questing.Database.receiveQuestsOnMapThatCanBeAccepted(mapID)
  local availableQuests = Questing.Database.retrieveQuestsThatShouldBeAvailable(mapID)
  return Array.filter(availableQuests, function (quest)
    return AddOn.isNotOnQuest(quest.id)
  end)
end
