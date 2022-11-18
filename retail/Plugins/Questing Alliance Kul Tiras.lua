-- Dependencies: Array, Set, Object, ActionSequenceDoer
-- Dependencies: Questing

GMR.DefineQuester(
  'Questing Alliance Kul Tiras',
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
      local wasSettingEnabled = {}

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
          end,
          function()
            wasSettingEnabled.Sell = GMR_SavedVariablesPerCharacter.Sell
            wasSettingEnabled.Repair = GMR_SavedVariablesPerCharacter.Repair
            wasSettingEnabled.Goods = GMR_SavedVariablesPerCharacter.Goods
            GMR.DefineSettings('Disable', {
              'Sell',
              'Repair',
              'FoodDrink'
            })
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
        end,
        function()
          if wasSettingEnabled.Sell then
            GMR.DefineSetting('Enable', 'Sell')
          end
          if wasSettingEnabled.Repair then
            GMR.DefineSetting('Enable', 'Repair')
          end
          if wasSettingEnabled.Goods then
            GMR.DefineSetting('Enable', 'FoodDrink')
          end
        end
      )
    end

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
          -- FIXME: When the specialization has already been selected before the quest it seems required to close the gossip dialog before the quest can be completed.
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
            C_Timer.NewTimer(1, function()
              if StaticPopup1Button1:IsShown() then
                StaticPopup1Button1:Click()
              end
            end)
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
    end

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
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            gossipWithAt(
              1138.2951660156,
              -535.38366699219,
              17.53302192688,
              137066
            )
          else
            toTurnInNPCWalker.run()
          end
        end,
        function()
          local offMeshHandler = GMR.OffMeshHandler
          GMR.OffMeshHandler = function(x, y, z)
            if x == 1070.4080810547 and y == -489.30151367188 and z == 9.7000856399536 then
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
            Questing.useExtraActionButton1()
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

    do
      local questID = 47487
      defineQuest(
        questID,
        'Labor Dispute',
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            local objectGUID = GMR.GetObjectWithInfo({
              id = { 122454, 133399, 133327 }
            })
            local x, y, z = GMR.ObjectPosition(objectGUID)
            local objectID = GMR.ObjectId(objectGUID)
            GMR.Questing.KillEnemy(x, y, z, objectID)
          end
        end,
        function()
          GMR.SkipTurnIn(true)
        end
      )
    end

    defineQuestsMassTurnIn({
      { 47486, -58.725696563721, -806.01214599609, 16.699214935303, 121239 },
      { 47488, -58.725696563721, -806.01214599609, 16.699214935303, 121239 },
      { 50573, -58.725696563721, -806.01214599609, 16.699214935303, 121239 },
      { 47487, -53.810764312744, -805.52429199219, 16.191980361938, 122671 }
    })

    do
      local questID = 50531
      defineQuest(
        questID,
        'Under Their Noses',
        -58.725696563721,
        -806.01214599609,
        16.699214935303,
        121239,
        -118.07118225098,
        -637.80383300781,
        6.3759903907776,
        134166
      )
    end

    defineQuestsMassPickUp({
      { 53041, -118.07118225098, -637.80383300781, 6.3759903907776, 134166 },
      { 50544, -157.24655151367, -616.75109863281, 1.5645854473114, 281551 },
      { 51149, -146.36111450195, -580.59375, 4.0662741661072, 136576 },
      { 50349, -191.46701049805, -627.11981201172, 1.6111487150192, 133550 }
    }, function()
      --GMR.DefineGryphonMaster(
      --  -90.868057250976,
      --  -633.96527099609,
      --  6.0453381538391,
      --  134226
      --)
    end)

    do
      local questID = 53041
      defineQuest(
        questID,
        'Sampling the Goods',
        nil,
        nil,
        nil,
        nil,
        -118.07118225098,
        -637.80383300781,
        6.3759903907776,
        134166,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            if next(C_GossipInfo.GetOptions()) then
              local options = C_GossipInfo:GetOptions()
              local option = options[1]
              C_GossipInfo.SelectOption(option.gossipOptionID)
            else
              interactWithAt(
                -197.78472900391,
                -588.24652099609,
                2.93039894104,
                142581
              )
            end
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
            interactWithAt(
              -166.6875,
              -557.37329101562,
              3.8276138305664,
              294542
            )
          end
        end
      )
    end

    do
      local questID = 47489

      local onBoatMover = createActionSequenceDoer(
        {
          createQuestingMoveToAction(
            -95.288856506348,
            -604.81573486328,
            3.0722851753235
          ),
          createMoveToAction(
            -82.664131164551,
            -598.83465576172,
            3.482914686203
          )
        }
      )

      local inBarrelHider = createActionSequenceDoer(
        {
          createMoveToAction(
            -75.358352661133,
            -607.17694091797,
            8.9734001159668
          ),
          {
            run = function()
              interactWithAt(
                -67.149772644043,
                -610.82556152344,
                10.07427406311,
                272475
              )
            end,
            isDone = function()
              return GMR.Questing.IsObjectiveCompleted(questID, 3)
            end
          }
        }
      )

      defineQuest(
        questID,
        'Stow and Go',
        -118.07118225098,
        -637.80383300781,
        6.3759903907776,
        134166,
        -1819.8026123047,
        -1363.9334716797,
        -0.35926878452301,
        128377,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            gossipWithAt(
              -118.07118225098,
              -637.80383300781,
              6.3759903907776,
              134166
            )
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 2) then
            onBoatMover.run()
          elseif not GMR.Questing.IsObjectiveCompleted(questID, 3) then
            inBarrelHider.run()
          end
        end
      )
    end

    defineQuestsMassPickUp({
      { 49218, -1819.8026123047, -1363.9334716797, -0.35926878452301, 128377 },
      { 48419, -1819.8026123047, -1363.9334716797, -0.35926878452301, 128377 }
    })

    do
      local questID = 49218
      defineQuest(
        questID,
        'The Castaways',
        -1819.8026123047,
        -1363.9334716797,
        -0.35926878452301,
        128377,
        -1683.21875,
        -1351.5798339844,
        32.000205993652,
        128229
      )
    end

    do
      local questID = 48419
      defineQuest(
        questID,
        'Lured and Allured',
        -1819.8026123047,
        -1363.9334716797,
        -0.35926878452301,
        128377,
        nil,
        nil,
        nil,
        nil,
        function()
          if not GMR.Questing.IsObjectiveCompleted(questID, 1) then
            gossipWithAt(
              -1683.21875,
              -1351.5798339844,
              32.000205993652,
              128229
            )
          end
        end,
        function()

        end
      )
    end
  end
)
