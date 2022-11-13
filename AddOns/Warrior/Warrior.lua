function doWhenInCombat(fn)
  doWhenGMRIsFullyLoaded(function()
    local yielder = createYielder()
    while true do
      if GMR.InCombat() then
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
