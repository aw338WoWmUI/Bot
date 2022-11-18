GMR.DefineProfileName('Questing')
GMR.DefineProfileType('Custom')

-- General
GMR.DefineSetting('Disable', 'GryphonMaster')
GMR.DefineSetting('Disable', 'LootARang')
GMR.DefineSetting('Enable', 'CombatRoutine')
GMR.DefineSetting('Disable', 'FightOnTravels')
GMR.DefineSetting('Enable', 'AutoGear')
GMR.DefineSetting('Disable', 'Randomization')
GMR.SetScanRadius(250)

-- Grinding
GMR.DefineSetting('Disable', 'Grinding')
GMR.DefineSetting('Disable', 'Looting')
GMR.DefineSetting('Disable', 'MassLooting')

-- Mounting
GMR.DefineSetting('Enable', 'Mount')
GMR.DefineSetting('Enable', 'FlyingMount')

-- Vendoring
GMR.DefineSetting('Disable', 'Sell')
GMR.DefineSetting('Disable', 'Repair')
GMR.DefineSetting('Disable', 'FoodDrink')
GMR.DefineSetting('Disable', 'MountVendoring')
GMR.DefineSetting('Disable', 'Hearthstone')

-- Navigation
GMR.DefineSetting('Disable', 'AvoidWater')

-- CVars
SetCVar('nameplateShowFriendlyNPCs', 1)
-- SetCVar('cameraSmoothStyle', 2)
SetCVar('SoftTargetInteract', 3)
SetCVar('SoftTargetIconInteract', 1)
SetCVar('SoftTargetIconGameObject', 1)
SetCVar('SoftTargetIconInteract', 1)
SetCVar('SoftTargetLowPriorityIcons', 1)
SetCVar('TargetEnemyAttacker', 1)
SetCVar('SoftTargetInteractRange', 1000)
SetCVar('SoftTargetTooltipDurationMs', 99999999)
SetCVar('SoftTargetTooltipEnemy', 1)
SetCVar('SoftTargetTooltipFriend', 1)
SetCVar('SoftTargetTooltipInteract', 1)
SetCVar('SoftTargetTooltipLocked', 1)
-- SetCVar('SoftTargetFriend', 1)
