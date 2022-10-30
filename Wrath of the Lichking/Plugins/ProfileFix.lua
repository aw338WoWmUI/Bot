local defineQuest = GMR.DefineQuest
GMR.DefineQuest = function (...)
  if ({...})[3] ~= 1598 then
    return defineQuest(...)
  end
end
