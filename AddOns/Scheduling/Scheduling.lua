Scheduling = {}

local _ = {}

local frame = nil
local functionsToDoEachFrame = {}

function Scheduling.doEachFrame(fn)
  -- We wrap the function so that each function in functionsToDoEachFrame has a different reference.
  -- The ensures that when `Cancel` is called that the instance of the function is canceled for that
  -- the handle (the returned object) has been created.
  local wrappedFn = function ()
    return fn()
  end
  table.insert(functionsToDoEachFrame, wrappedFn)
  if not frame then
    frame = CreateFrame('Frame')
    frame:SetScript('OnUpdate', _.runFunctions)
  end
  return {
    Cancel = function ()
      Array.removeFirstOccurence(functionsToDoEachFrame, wrappedFn)
    end
  }
end

function _.runFunctions()
  for _, fn in ipairs(functionsToDoEachFrame) do
    fn()
  end
end
