--local i = 1
--local ticker
--ticker = C_Timer.NewTicker(0, function ()
--  print('ticker')
--  i = i + 1
--  if i == 3 then
--    print('last')
--    ticker:Cancel()
--  end
--end)

function test332(...)
  for index, value in pairs({...}) do
    print(index, value)
  end
end

function moveToTarget()
  local x = -8364.900390625
  local y = 662.98004150391
  local z = 97.363922119141

  if x then
    local function hasPlayerArrived()
      return GMR.IsPlayerPosition(x, y, z, 5)
    end

    local function moveToDestination()
      GMR.Questing.MoveTo(x, y, z)
    end

    if not hasPlayerArrived() then
      moveToDestination()
    end
    local ticker
    ticker = C_Timer.NewTicker(0, function ()
      if hasPlayerArrived() then
        ticker:Cancel()
      else
        moveToDestination()
      end
    end)
  end
end

--local ticker
--ticker = C_Timer.NewTicker(5, function ()
--  print('GMR.IsLoSMeshing', GMR.IsLoSMeshing())
--end)

-- /dump moveToTarget()
