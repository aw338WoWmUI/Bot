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
                elseif not GMR.Questing.IsObjectiveCompleted(questID, 4) or not GMR.Questing.IsObjectiveCompleted(questID, 5) then
                    GMR.Questing.KillEnemy(-2181.765625, 6824.0434570312, 4259.8017578125, 170079)
                end
            end
        },
        function()
            GMR.SkipTurnIn(true)
        end
    )
end

GMR.DefineQuester('World Quests', function()
    Quester.defineQuestMuckItUp()
    Quester.defineQuestAStolenStoneFiend()
end)

function findObjectsByName(name)
    local objectsThatMatch = {}
    local objects = GMR.GetNearbyObjects(100)
    for guid, object in pairs(objects) do
        if object.Name == name then
            table.insert(objectsThatMatch, object)
        end
    end
    return objectsThatMatch
end
