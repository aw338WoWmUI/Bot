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
      SpellCasting.handleAOE()
    else
      _.castSpell(ability, recommendation)
    end
  end
end

function Bot.castSpell(spell)
  local spellName, __, __, __, __, __, spellID = GetSpellInfo(spell)
  _.castSpell({
    id = spellID,
    name = spellName
  }, {
    empower_to = nil
  })
end

function _.castSpell(ability, recommendation)
  SpellCasting.castSpell(ability.id, {
    empowermentLevel = recommendation.empower_to
  })
end

local farmedThings = {}

local positions = nil

function Bot.findCaches()
  positions = Array
    .map(AddOn.draconicCacheCoordinates, function(coordinates)
    return Core.retrieveWorldPositionFromMapPosition(
      { mapID = 2022, x = coordinates.x / 100, y = coordinates.y / 100 },
      Core.retrieveHighestZCoordinate
    )
  end)
    :filter(function(position)
    return position.z ~= nil
  end)

  Draw.Sync(function()
    local characterPosition = Core.retrieveCharacterPosition()
    if characterPosition then
      Array.forEach(positions, function(position)
        local distance = Core.calculateDistanceBetweenPositions(characterPosition, position)
        if distance <= 184 then
          Draw.SetColorRaw(0, 1, 0, 1)
        else
          Draw.SetColorRaw(0, 0, 1, 1)
        end
        Draw.Circle(position.x, position.y, position.z, 10)
      end)

      Draw.SetColorRaw(0, 1, 0, 1)
      Array.forEach(farmedThings, function(cache)
        local position = Core.retrieveObjectPosition(cache)
        if position then
          Draw.Circle(position.x, position.y, position.z, 1)
          Draw.Line(characterPosition.x, characterPosition.y, characterPosition.z, position.x, position.y, position.z)
        end
      end)
    end
  end)

  C_Timer.NewTicker(1, function()
    farmedThings = Array.filter(Core.retrieveObjectPointers(), function(pointer)
      return HWT.ObjectId(pointer) == 376580 and Core.retrieveObjectDataDynamicFlags(pointer) == -65536
      -- open: -65520
    end)
  end)
end

local button = CreateFrame('Button', nil, nil, 'UIPanelButtonNoTooltipTemplate')
button:SetText('Start')
button:SetSize(130, 20)
button:SetScript('OnClick', Bot.start)
