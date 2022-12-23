local addOnName, AddOn = ...
local _ = {}
--- @class Bot
Bot = Bot or {}

local isRunning = false

function Bot.isRunning()
  return isRunning
end

function Bot.start(options)
  if not Bot.isRunning() then
    print('Starting bot...')

    isRunning = true

    if _G.Questing then
      Questing.start(options)
    end
  end
end

function Bot.stop()
  if Bot.isRunning() then
    print('Stopping bot...')
    isRunning = false

    if _G.Questing then
      Questing.stop()
    end
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
  elseif classID == Core.ClassID.DeathKnight then
    Bot.DeathKnight.castSpell()
  elseif _G.RecommendedSpellCaster then
    AddOn.castRecommendedSpell()
  elseif _G.GMR and GMR.ClassRotation then
    GMR.ClassRotation()
  end
end

function AddOn.castRecommendedSpell()
  local ability, recommendation = RecommendedSpellCaster.retrieveNextAbility()
  if ability then
    if RecommendedSpellCaster.isItem(ability) then
      RecommendedSpellCaster.castItem(ability)
    else
      _.castSpell(ability, recommendation)
    end

    if HWT.IsAoEPending() then
      local position
      local targetPosition = Core.retrieveObjectPosition('target')
      if targetPosition then
        position = targetPosition
      else
        position = Core.retrieveCharacterPosition()
      end
      local angle = math.rad(math.random() * 360)
      local radius = math.random() * 2
      position.x = position.x + radius * math.cos(angle)
      position.y = position.y + radius * math.sin(angle)
      Core.clickPosition(position)
    end
  end
end

function _.castSpell(ability, recommendation)
  if (
    not IsCurrentSpell(ability.id) and
      RecommendedSpellCaster.canBeCasted(ability.id) and
      IsSpellInRange(ability.name, 'target') ~= 0
  ) then
    SpellCasting.castSpellByID(ability.id, {
      empowermentLevel = recommendation.empower_to
    })
  end
end

local button = CreateFrame('Button', nil, nil, 'UIPanelButtonNoTooltipTemplate')
button:SetText('Start')
button:SetSize(130, 20)
button:SetScript('OnClick', Bot.start)
