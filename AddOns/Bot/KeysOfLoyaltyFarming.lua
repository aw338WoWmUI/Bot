Bot = Bot or {}
Bot.KeysOfLoyalty = {}

local KEY_FRAMING_ITEM_ID = 193201
local KEY_FRAGMENTS_ITEM_ID = 191251
local ASSEMBLING_SPELL_ID = 370298
local SABELLIAN_OBJECT_ID = 187447
local RESTORED_OBSIDIAN_KEY_ITEM_ID = 191264
local OBSIDIAN_STRONGBOX_ITEM_ID = 200070
local OBSIDIAN_CACHE_ITEM_ID = 200069

-- /dump Bot.KeysOfLoyalty.handleCompletion()

local mobsWhoDropKeyIngredients = Set.create({
  187602,
  196336,
  187867,
  187599
})

-- /dump Bot.KeysOfLoyalty.farm()

function Bot.KeysOfLoyalty.farm()
  Coroutine.runAsCoroutine(function()
    while true do
      local mobs = Array.filter(Core.retrieveObjectPointers(), function(object)
        return Core.isAlive(object) and Set.contains(mobsWhoDropKeyIngredients,
          HWT.ObjectId(object)) and Core.calculateDistanceFromCharacterToObject(object) <= 40
      end)

      Core.tagMobs(mobs)

      mobs = Array.filter(Core.retrieveObjectPointers(), function(object)
        return Core.isAlive(object) and Set.contains(mobsWhoDropKeyIngredients,
          HWT.ObjectId(object)) and Core.calculateDistanceFromCharacterToObject(object) <= 40
      end)

      Core.doMobs(mobs)

      Coroutine.yieldAndResume()
    end
  end)
end

function Bot.KeysOfLoyalty.handleCompletion()
  Coroutine.runAsCoroutine(function()
    Bot.KeysOfLoyalty.createKeys()
    Bot.KeysOfLoyalty.turnKeysIn()
    Bot.KeysOfLoyalty.openObsidianContainers()
  end)
end

function Bot.KeysOfLoyalty.createKeys()
  -- FIXME: There seems to be another event after the cast success event, which seems to be required to wait for before the item counts in the bags have been updated.
  while Bot.KeysOfLoyalty.canCreateKey() do
    Bot.KeysOfLoyalty.createKey()
  end
end

function Bot.KeysOfLoyalty.turnKeysIn()
  if Bags.hasItem(RESTORED_OBSIDIAN_KEY_ITEM_ID) then
    local sabellian = Core.findClosestObjectToCharacterWithOneOfObjectIDs(SABELLIAN_OBJECT_ID)
    if sabellian then
      repeat
        Core.interactWithObject(sabellian)
        Events.waitForEvent('QUEST_FINISHED')
      until not Bags.hasItem(RESTORED_OBSIDIAN_KEY_ITEM_ID)
    end
  end
end

function Bot.KeysOfLoyalty.openObsidianContainers()
  local itemIDs = { OBSIDIAN_STRONGBOX_ITEM_ID, OBSIDIAN_CACHE_ITEM_ID }
  local function findItem()
    return Bags.findItem(itemIDs)
  end

  local containerIndex, slotIndex = findItem()
  while containerIndex and slotIndex do
    SpellCasting.useContainerItem(containerIndex, slotIndex)
    Events.waitForEvent('BAG_UPDATE_DELAYED')

    containerIndex, slotIndex = findItem()
  end
end

function Bot.KeysOfLoyalty.canCreateKey()
  return Bags.countItem(KEY_FRAMING_ITEM_ID) >= 3 and Bags.countItem(KEY_FRAGMENTS_ITEM_ID) >= 30
end

function Bot.KeysOfLoyalty.createKey()
  local containerIndex, slotIndex = Bags.findItem(KEY_FRAMING_ITEM_ID)
  if containerIndex and slotIndex then
    SpellCasting.useContainerItem(containerIndex, slotIndex)
    SpellCasting.waitForSpellCastSucceeded(ASSEMBLING_SPELL_ID)
  end
end
