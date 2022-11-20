local run
run = function()
  if GMR.IsExecuting() and GMR.InCombat() and not GMR.IsAttacking() and not GMR.IsMoving() then
    local pointer = GMR.GetAttackingEnemy()
    if pointer then
      if IsMounted() then
        GMR.Dismount()
      end
      GMR.TargetObject(pointer)
      GMR.StartAttack()
    end
  end
  C_Timer.After(1, run)
end

run()
