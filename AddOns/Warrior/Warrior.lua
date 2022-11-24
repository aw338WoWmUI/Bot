function doWhenInCombat(fn)
  doWhenGMRIsFullyLoaded(function()
    local yielder = createYielder()
    while true do
      if Bot.isCharacterInCombat() then
        fn()
      end
      yielder.yield()
    end
  end)
end

doWhenInCombat(function()
  -- local spellReflection =

  -- Heroic Leap
end)
