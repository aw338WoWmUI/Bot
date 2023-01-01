function Bot.assist(characterName)
	Coroutine.runAsCoroutine(function ()
    while true do
      local target = HWT.UnitTarget(characterName)
      if Core.isUnitInCombat(characterName) and Core.canUnitAttackOtherUnit('player', target) then
        await(Core.doMob(target))
      else
        await(Core.moveToObject('party1'))
      end

      Coroutine.yieldAndResume()
    end
  end)
end
