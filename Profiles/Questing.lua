GMR.DefineSetting('Disable', 'AvoidWater')
GMR.DefineSetting('Enable', 'FightOnTravels')
GMR.DefineSellVendor(
  -1707.3454589844,
  -1423.5191650391,
  34.289108276367,
  128227
)
GMR.DefineRepairVendor(
  -1707.3454589844,
  -1423.5191650391,
  34.289108276367,
  128227
)
SetCVar('SoftTargetInteract', 3)
SetCVar('SoftTargetIconInteract', 1)
SetCVar('SoftTargetIconGameObject', 1)
SetCVar('SoftTargetIconInteract', 1)
SetCVar('SoftTargetLowPriorityIcons', 1)
SetCVar('TargetEnemyAttacker', 1)
SetCVar('SoftTargetInteractRange', 1000)
-- /dump GetCVar('SoftTargetInteractRange')
-- /dump SetCVar('SoftTargetInteractRange', 50)
SetCVar('SoftTargetTooltipDurationMs', 99999999)
SetCVar('SoftTargetTooltipEnemy', 1)
SetCVar('SoftTargetTooltipFriend', 1)
SetCVar('SoftTargetTooltipInteract', 1)
SetCVar('SoftTargetTooltipLocked', 1)
-- /dump GetCVar('SoftTargetFriend')
-- SetCVar('SoftTargetFriend', 1)
