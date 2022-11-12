doWhenGMRIsFullyLoaded(function ()
  local yielder = createYielder()
  while true do
    if GMR.InCombat() then

      -- Heroic Leap
    end
    yielder.yield()
  end
end)
