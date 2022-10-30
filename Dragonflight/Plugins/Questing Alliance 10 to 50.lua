-- Dependencies: Array, Set, Object

local ALLIANCE = 'Alliance'
local INTERACT_DISTANCE = 4

local function defineQuest(questID, questName, pickUpX, pickUpY, pickUpZ, pickUpObjectID, turnInX,
  turnInY, turnInZ, turnInObjectID, questInfo, profileInfo, ...)
  GMR.DefineQuest(
    ALLIANCE,
    nil,
    questID,
    questName,
    'Custom',
    pickUpX,
    pickUpY,
    pickUpZ,
    pickUpObjectID,
    turnInX,
    turnInY,
    turnInZ,
    turnInObjectID,
    { questInfo },
    profileInfo,
    ...
  )
end

local function defineQuestsMassPickUp(quests)
  GMR.DefineQuest(
    ALLIANCE,
    nil,
    nil,
    '',
    'MassPickUp',
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    quests
  )
end

function gossipWithAt(x, y, z, objectID, optionToSelect)
  GMR.Questing.GossipWith(
    x,
    y,
    z,
    objectID,
    nil,
    INTERACT_DISTANCE,
    optionToSelect or 1
  )
end

local function gossipWith(objectID, optionToSelect)
  local objectGUID = GMR.FindObject(objectID)
  if objectGUID then
    local x, y, z = GMR.ObjectPosition(objectGUID)
    gossipWithAt(x, y, z, objectID, optionToSelect)
  end
end

local function followNPC(objectID, distance)
  GMR.Questing.FollowNpc(objectID, distance or 5)
end

function interactWithAt(x, y, z, objectID, distance, delay)
  GMR.Questing.InteractWith(
    x,
    y,
    z,
    objectID,
    delay or nil,
    distance or INTERACT_DISTANCE
  )
end

local function interactWith(objectID, distance, dynamicFlag)
  local objectGUID = GMR.GetObjectWithInfo({
    id = objectID,
    dynamicFlag = dynamicFlag
  })
  if objectGUID then
    local x, y, z = GMR.ObjectPosition(objectGUID)
    interactWithAt(x, y, z, objectID, distance)
  end
end

local function areSameGossipOptions(optionsA, optionsB)
  return Array.equals(optionsA, optionsB, function(option)
    return option.name
  end)
end

local function createGossiper(x, y, z, objectID, optionsToSelect)
  local previousOptions = nil
  local optionsIndex = 1

  local function hasFinishedGossiping()
    return optionsIndex > #optionsToSelect
  end

  return {
    gossip = function()
      local numberOfOptions = C_GossipInfo.GetNumOptions()
      if numberOfOptions == 0 then
        GMR.Questing.GossipWith(
          x,
          y,
          z,
          objectID,
          nil,
          INTERACT_DISTANCE
        )
      elseif not hasFinishedGossiping() then
        local options = C_GossipInfo.GetOptions()
        if previousOptions and not areSameGossipOptions(options, previousOptions) then
          optionsIndex = optionsIndex + 1
        end

        GMR.Questing.GossipWith(
          x,
          y,
          z,
          objectID,
          nil,
          INTERACT_DISTANCE,
          optionsToSelect[optionsIndex]
        )

        previousOptions = options
      end
    end,

    hasFinishedGossiping = hasFinishedGossiping
  }
end

local function setSpecializationToPreferredOrFirstDamagerSpecialization()
  local specializationNameSetting = GMR.GetSelectedSpecializationValue()
  local numberOfSpecializations = GetNumSpecializations(false, false)
  for index = 1, numberOfSpecializations do
    local name, _, _, role = select(
      2,
      GetSpecializationInfo(index, false, false, nil, UnitSex('player'))
    )
    if (
      (specializationNameSetting and name == specializationNameSetting) or
        (not specializationNameSetting and role == 'DAMAGER')
    ) then
      SetSpecialization(index, false)
      break
    end
  end
end

local function createActionSequenceDoer(actions)
  local index = 1

  return {
    run = function()
      while index <= #actions do
        local action = actions[index]
        if action.isDone() then
          if action.whenIsDone then
            action.whenIsDone()
          end
          index = index + 1
        else
          break
        end
      end

      print('index', index, #actions)

      if index <= #actions then
        local action = actions[index]
        print('run ' .. index)
        action.run()
      end
    end
  }
end

local function moveToWhenNotMoving(x, y, z)
  if not GMR.IsMoving() then
    GMR.MoveTo(x, y, z)
  end
end

local function createMoveToAction(x, y, z)
  local stopMoving = nil
  local firstRun = true
  return {
    run = function()
      if firstRun then
        stopMoving = GMR.StopMoving
        GMR.StopMoving = function()
        end
      end
      moveToWhenNotMoving(x, y, z)
    end,
    isDone = function()
      return GMR.IsPlayerPosition(x, y, z, 1)
    end,
    whenIsDone = function()
      if stopMoving then
        GMR.StopMoving = stopMoving
      end
    end
  }
end

local function createQuestingMoveToAction(x, y, z, distance)
  return {
    run = function()
      GMR.Questing.MoveTo(x, y, z)
    end,
    isDone = function()
      return GMR.IsPlayerPosition(x, y, z, distance or 1)
    end
  }
end

GMR.DefineQuester(
  'Questing Alliance 10 to 50',
  function()
    defineQuest(
      55991,
      'An End to Beginnings',
      nil,
      nil,
      nil,
      nil,
      -9053.4150390625,
      442.52258300781,
      93.058059692383,
      154169
    )

    defineQuest(
      59583,
      'Welcome to Stormwind',
      -9053.4150390625,
      442.52258300781,
      93.058059692383,
      154169,
      -8983.95703125,
      504.03472900391,
      96.677909851074,
      163095
    )

    do
      local questID = 58908
      local gossiper = createGossiper(
        -8964.1318359375,
        501.609375,
        96.589340209961,
        186180,
        { 15, 1 }
      )
      defineQuest(
        questID,
        'Finding Your Way',
        -8983.95703125,
        504.03472900391,
        96.677909851074,
        163095,
        -8771.3544921875,
        380.14758300781,
        101.12975311279,
        163007,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            gossiper.gossip()
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
            gossipWithAt(
              -8966.716796875,
              510.30557250976,
              96.353286743164,
              163095
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 3) then
            followNPC(165548)
          end
        end
      )
    end

    defineQuest(
      58909,
      'License to Ride',
      -8771.3544921875,
      380.14758300781,
      101.12975311279,
      163007,
      -8771.3544921875,
      380.14758300781,
      101.12973022461,
      163007,
      function()
        if not GMR.IsTrainerFrameShown() then
          local npcID = 43693
          local objectGUID = GMR.FindObject(npcID)
          local x, y, z = GMR.ObjectPosition(objectGUID)
          interactWithAt(x, y, z, npcID)
        elseif GMR.IsTrainerFrameShown() then
          BuyTrainerService(1)
        end
      end
    )

    do
      local questID = 59594
      defineQuest(
        questID,
        "What's Your Speciality?",
        nil,
        nil,
        nil,
        163097,
        -8814.6806640625,
        332.64584350586,
        107.04860687256,
        164940,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            gossipWithAt(
              -8814.6806640625,
              332.64584350586,
              107.04860687256,
              164940
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
            setSpecializationToPreferredOrFirstDamagerSpecialization()
          end
        end,
        function()
          local BLACK_STALLION = 470
          GMR_SavedVariablesPerCharacter.SelectedMount = GetSpellInfo(BLACK_STALLION)
          GMR.DefineSetting('Enable', 'Mount')
        end
      )
    end

    do
      local questID = 58911
      defineQuest(
        questID,
        'Home Is Where the Hearth Is',
        nil,
        nil,
        nil,
        163097,
        -8622.4697265625,
        407.78298950195,
        102.92445373535,
        44237,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            gossipWithAt(
              -8622.4697265625,
              407.78298950195,
              102.92445373535,
              44237,
              1
            )
          end
        end
      )
    end

    do
      local questID = 58912
      defineQuest(
        questID,
        'An Urgent Meeting',
        -8625,
        415.61633300781,
        103.7035369873,
        163211,
        -8367.1630859375,
        242.25,
        155.31031799316,
        163219,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            GMR.Questing.MoveTo(
              -8367.1630859375,
              242.25,
              155.31031799316
            )
          end
        end,
        function()
          if StaticPopup1Button1:IsShown() then
            StaticPopup1Button1:Click()
          end
        end
      )
    end

    defineQuest(
      58983,
      'Battle for Azeroth: Tides of War',
      -8367.1630859375,
      242.25,
      155.30989074707,
      163219,
      -8361.392578125,
      230.06423950195,
      157.9143371582,
      165395,
      function()
      end
    )

    do
      local questID = 59641
      defineQuest(
        questID,
        'The Nation of Kul Tiras',
        -8361.392578125,
        230.06423950195,
        157.9143371582,
        165395,
        726.54864501953,
        -442.84375,
        14.917701721191,
        120922,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            gossipWithAt(
              -8367.1630859375,
              242.25,
              155.30989074707,
              163219
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
            gossipWithAt(
              -8450.576171875,
              372.78994750976,
              135.70956420898,
              165505
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 3) then
            gossipWithAt(
              -8281.763671875,
              1326.8629150391,
              5.2397694587708,
              120590
            )
          end
        end
      )
    end

    local function goToFlynn()
      local x = 139.42579650879
      local y = -2712.1262207031
      local z = 29.187238693237
      local ticker
      ticker = C_Timer.NewTicker(0,
        function()
          if GMR.IsPlayerPosition(x, y, z, 1) then
            ticker:Cancel()
          else
            GMR.MoveTo(
              x,
              y,
              z
            )
          end
        end)
    end

    do
      local questID = 51341
      defineQuest(
        51341,
        'Daughter of the Sea',
        726.54864501953,
        -442.84375,
        14.917701721191,
        120922,
        140.93229675293,
        -2716.5383300781,
        30.350156784058,
        121239,
        function()
        end,
        function()
          if not C_QuestLog.IsOnQuest(questID) then
            goToFlynn()
          end
        end
      )
    end

    do
      local questID = 47098

      local toBoatWalker = createActionSequenceDoer(
        {
          createMoveToAction(
            194.88122558594,
            -2691.7739257812,
            29.18949508667
          ),
          createMoveToAction(
            165.09448242188,
            -2733.3508300781,
            18.963714599609
          ),
          createMoveToAction(
            149.28617858887,
            -2722.3767089844,
            13.921509742737

          ),
          createMoveToAction(
            171.12617492676,
            -2694.65625,
            13.646925926208
          ),
          createMoveToAction(
            103.12325286865,
            -2647.0852050781,
            11.633148193359
          ),
          createMoveToAction(
            78.815528869629,
            -2680.2758789062,
            5.6769328117371

          ),
          createMoveToAction(
            146.943359375,
            -2726.9682617188,
            4.9246678352356

          ),
          createMoveToAction(
            131.62480163574,
            -2748.419921875,
            3.2554287910461
          ),
          {
            run = function()
              interactWithAt(
                240.65104675293,
                -2812.9497070312,
                -0.052746556699276,
                124030
              )
            end,
            isDone = function()
              return GMR.Questing.IsObjectiveCompleted(questID, 8)
            end
          }
        }
      )

      defineQuest(
        questID,
        'Out Like Flynn',
        140.93229675293,
        -2716.5383300781,
        30.350156784058,
        121239,
        1051.3264160156,
        -624.94616699219,
        0.52023792266846,
        121235,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            interactWithAt(
              144.60417175293,
              -2710.9965820312,
              29.188508987427,
              121239
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
            interactWithAt(
              167.07118225098,
              -2711.5400390625,
              31.387538909912,
              271938
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 3) then
            interactWithAt(
              148.67881774902,
              -2712.6198730469,
              28.123090744019,
              290827
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 4) then
            GMR.Questing.KillEnemy(
              99.831596374512,
              -2664.7465820312,
              29.18962097168,
              124024
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 5) then
            interactWithAt(
              103.07290649414,
              -2688.7846679688,
              30.037179946899,
              290126
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 6) then
            interactWithAt(
              186.55381774902,
              -2685.7221679688,
              28.867448806763,
              281902
            )
          elseif (
            not GMR.Questing.IsObjectiveCompleted(questID, 7) or
              not GMR.Questing.IsObjectiveCompleted(questID, 8)
          ) then
            toBoatWalker.run()
          end
        end,
        function()
          if not C_QuestLog.IsOnQuest(questID) then
            goToFlynn()
          end
        end
      )

      do
        local questID = 47099

        defineQuest(
          questID,
          'Get Your Bearings',
          1051.3264160156,
          -624.94616699219,
          0.52023792266846,
          121235,
          nil,
          nil,
          nil,
          124630,
          function()
            if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
              interactWithAt(
                1036.8646240234,
                -597.04864501953,
                1.362363576889,
                135064
              )
            elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
              GMR.Questing.MoveTo(
                1114.5687255859,
                -620.80346679688,
                17.533224105835
              )
            elseif not GMR.Questing.IsObjectiveCompleted(questID, 3) then
              GMR.Questing.MoveTo(
                1173.3037109375,
                -586.23785400391,
                31.502172470093
              )
            elseif not GMR.Questing.IsObjectiveCompleted(questID, 4) then
              interactWithAt(
                1153.8646240234,
                -467.99478149414,
                31.292324066162,
                124725
              )
            end
          end
        )
      end

      do
        local questID = 46729
        defineQuest(
          questID,
          'The Old Knight',
          1149.8199462891,
          -471.0710144043,
          30.41823387146,
          124630,
          1070.4080810547,
          -489.30151367188,
          9.7000856399536,
          121235,
          function()
            if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
              GMR.Questing.MoveTo(
                1059.0281982422,
                -479.19418334961,
                9.8979616165161
              )
            elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
              gossipWithAt(
                1071.4249267578,
                -486.3076171875,
                9.700216293335,
                122370
              )
            end
          end
        )
      end

      do
        local questID = 52128
        defineQuest(
          questID,
          'Ferry Pass',
          1071.4288330078,
          -486.3125,
          9.7001171112061,
          122370,
          1071.4288330078,
          -486.3125,
          9.7001171112061,
          122370
        )
      end

      --defineQuest2(
      --  47186,
      --  1070.4080810547,
      --  -489.30151367188,
      --  9.7000856399536,
      --  121235
      --)

      do
        local questID = 47186

        local toTurnInNPCWalker = createActionSequenceDoer(
          {
            {
              run = function()
                GMR.Questing.MoveTo(
                  1075.8001708984,
                  -475.646484375,
                  20.657657623291
                )
              end,
              isDone = function()
                return GMR.IsPlayerPosition(
                  1075.8001708984,
                  -475.646484375,
                  20.657657623291,
                  3
                )
              end
            },
            createMoveToAction(
              1060.3134765625,
              -471.68408203125,
              11.651566505432
            ),
            createMoveToAction(
              1058.8143310547,
              -479.13681030273,
              9.8977861404419
            ),
            {
              run = function()
                GMR.Questing.InteractWith(
                  1070.4045410156,
                  -489.32119750976,
                  9.7001161575317,
                  121235
                )
              end,
              isDone = function()
                return #C_GossipInfo.GetActiveQuests() >= 1
              end
            },
            {
              run = function()
                local activeQuests = C_GossipInfo.GetActiveQuests()
                local quest = Array.find(activeQuests, function(quest)
                  return quest.questID == questID
                end)
                if quest then
                  C_GossipInfo.SelectActiveQuest(quest.questID)
                end
              end,
              isDone = function()
                return QuestFrameRewardPanel:IsShown()
              end
            },
            {
              run = function()
                CompleteQuest()
              end,
              isDone = function()
                return GMR.IsQuestCompleted(questID)
              end
            },
          }
        )

        defineQuest(
          questID,
          'Sanctum of the Sages',
          1070.4080810547,
          -489.30151367188,
          9.7000856399536,
          121235,
          1070.4080810547,
          -489.30151367188,
          9.7000856399536,
          121235,
          function()
            print('questinfo')
            if GMR.Questing.IsObjectiveCompleted(questID, 1) then
              toTurnInNPCWalker.run()
            end
          end,
          function()
            print('profile info')

            local offMeshHandler = GMR.OffMeshHandler
            GMR.OffMeshHandler = function(x, y, z)
              if x == 1070.4080810547 and y == -489.30151367188 and z == 9.7000856399536 then
                print('sdhasdkjsa')
                toTurnInNPCWalker.run()
              else
                return offMeshHandler(x, y, z)
              end
            end
          end
        )
      end

      do
        local questID = 47189
        defineQuest(
          questID,
          'A Nation Divided',
          1070.4045410156,
          -489.32119750976,
          9.7001075744629,
          121235,
          1070.4045410156,
          -489.32119750976,
          9.7001075744629,
          121235,
          function()
            if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
              interactWithAt(
                1069.2083740234,
                -493.76910400391,
                13.055233001709,
                139522,
                7.3687648766664
              )
            end
          end,
          function()
            GMR.AddOffmeshConnection(
              1161,
              1069.8162841797,
              -491.92059326172,
              9.7003402709961,
              1069.2083740234,
              -493.76910400391,
              13.055233001709,
              true
            )
          end
        )
      end

      do
        local questID = 47960
        defineQuest(
          questID,
          'Tiragarde Sound',
          1069.2083740234,
          -493.76910400391,
          13.055233001709,
          139522,
          1070.4045410156,
          -489.32119750976,
          9.7001075744629,
          121235,
          function()

          end,
          function()
            local frame

            local function onAdventureMapOpen()
              C_AdventureMap.StartQuest(47960)
              frame:SetScript('OnEvent', nil)
            end

            local function onEvent(self, event, ...)
              if event == 'ADVENTURE_MAP_OPEN' then
                onAdventureMapOpen(...)
              end
            end

            frame = CreateFrame('Frame')
            frame:SetScript('OnEvent', onEvent)
            frame:RegisterEvent('ADVENTURE_MAP_OPEN')

            interactWithAt(
              1069.2083740234,
              -493.76910400391,
              13.055233001709,
              139522,
              7.3687648766664
            )
          end
        )
      end

      do
        local questID = 47181
        defineQuest(
          questID,
          'The Smoking Gun',
          1067.8819580078,
          -478.79165649414,
          9.7834596633911,
          121239,
          1067.8819580078,
          -478.79165649414,
          9.7834596633911,
          121239,
          function()
            if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
              useExtraActionButton1()
            end
          end
        )
      end

      do
        local questID = 47485

        local mover = createActionSequenceDoer(
          {
            createQuestingMoveToAction(
              1058.796875,
              -479.12399291992,
              9.8980073928833
            ),
            createMoveToAction(
              1060.404296875,
              -471.97653198242,
              11.650757789612
            ),
            createMoveToAction(
              1067.7041015625,
              -473.64971923828,
              15.208990097046
            ),
            {
              run = function()
                interactWithAt(
                  1036.8646240234,
                  -597.04864501953,
                  1.3624578714371,
                  135064
                )
              end,
              isDone = function()
                return GMR.Questing.IsObjectiveCompleted(questID, 1)
              end
            }
          }
        )

        defineQuest(
          questID,
          'The Ashvane Trading Company',
          1071.4288330078,
          -486.3125,
          9.7003087997437,
          122370,
          164.22917175293,
          -711.69964599609,
          42.609508514404,
          122671,
          function()
            if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
              mover.run()
            end
          end,
          function()
            local offMeshHandler = GMR.OffMeshHandler
            GMR.OffMeshHandler = function(x, y, z)
              if x == 164.22917175293 and y == -711.69964599609 and z == 42.609508514404 then
                print('b')
                if _G.FlightMapFrame and FlightMapFrame:IsShown() then
                  local EASTPOINT_STATION_TIRAGARDE_SOUND = 28
                  TakeTaxiNode(EASTPOINT_STATION_TIRAGARDE_SOUND)
                else
                  local objectGUID = GMR.FindObject(135064)
                  if objectGUID then
                    GMR.InteractObject(objectGUID)
                  end
                end
              else
                return offMeshHandler(x, y, z)
              end
            end
          end
        )
      end

      defineQuestsMassPickUp({
        { 47486, 164.22917175293, -711.69964599609, 42.609519958496, 122671 },
        { 47487, 164.22917175293, -711.69964599609, 42.609519958496, 122671 },
        { 47488, 161.41319274902, -710.22393798828, 42.636142730713, 122672 },
        { 50573, 48.684028625488, -873.89581298828, 31.606134414673, 281647 }
      })

      do
        local questID = 50573
        defineQuest(
          questID,
          'Message from the Management',
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          function()
            if not GMR.Questing.IsObjectiveCompleted(questID, 2) then
              GMR.Questing.KillEnemy(
                -14.793313980103,
                -876.92706298828,
                31.603130340576,
                123264
              )
            elseif not GMR.Questing.IsObjectiveCompleted(questID, 1) then
              GMR.Questing.KillEnemy(
                -93.993240356445,
                -1108.5428466797,
                63.185768127441,
                134328
              )
            end
          end,
          function()
            GMR.SkipTurnIn(true)
          end
        )
      end

      do
        local questID = 47486
        defineQuest(
          questID,
          'Suspicious Shipments',
          164.22917175293,
          -711.69964599609,
          42.609519958496,
          122671,
          nil,
          nil,
          nil,
          nil,
          function()
            if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
              interactWith(271616, nil, -65020)
            end
          end,
          function()
            GMR.SkipTurnIn(true)
          end
        )
      end

      do
        local questID = 47488
        defineQuest(
          questID,
          'Small Haulers',
          164.22917175293,
          -711.69964599609,
          42.609519958496,
          122671,
          nil,
          nil,
          nil,
          nil,
          function()
            if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
              gossipWith(122681, 1)
            end
          end,
          function()
            GMR.SkipTurnIn(true)
          end
        )
      end
    end
  end
)
