local addOnName, AddOn = ...
--- @class Bot
Bot = Bot or {}
--- @type RecommendedSpellCaster

local isRunning = false

function Bot.isRunning()
  return isRunning
end

function Bot.start()
  if not Bot.isRunning() then
    print('Starting bot...')

    isRunning = true

    Questing.start()
  end
end

function Bot.stop()
  if Bot.isRunning() then
    print('Stopping bot...')
    isRunning = false
    Questing.stop()
  end
end

function Bot.toggle()
  if isRunning then
    Bot.stop()
  else
    Bot.start()
  end
end

function Bot.castCombatRotationSpell()
  local classID = select(2, UnitClassBase('player'))
  if classID == Core.ClassID.Warrior then
    Bot.Warrior.castSpell()
  elseif RecommendedSpellCaster then
    RecommendedSpellCaster.castRecommendedSpell()
  elseif _G.GMR and GMR.ClassRotation then
    GMR.ClassRotation()
  end
end

local button = CreateFrame('Button', nil, nil, 'UIPanelButtonNoTooltipTemplate')
button:SetText('Start')
button:SetSize(130, 20)
button:SetScript('OnClick', Bot.start)
