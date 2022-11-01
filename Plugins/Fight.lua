local run
run = function()
  if GMR.IsExecuting() and GMR.InCombat() and not GMR.IsAttacking() then
    local pointer = GMR.GetAttackingEnemy()
    if pointer then
      local x, y, z = GMR.ObjectPosition(pointer)
      local objectID = GMR.ObjectId(pointer)
      GMR.Questing.KillEnemy(x, y, z, objectID)
    end
  end
  C_Timer.After(1, run)
end

run()
