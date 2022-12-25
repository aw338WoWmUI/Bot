-- FIXME: Seems to fail to loot units which are out of interact range.
-- FIXME: Seems to fail to continue after having looted an object (seems to have to do with double loot and probably that the function waits for an event very long.). Eventually (after ~ 30 seconds) the character seems to continue.
-- TODO: Maybe looting of objects that are still lootable.
-- TODO: Also combat with mobs who attack the character.
-- TODO: Avoid that the character dies from the lava damage.

Bot = Bot or {}
Bot.DragonbaneKeep = {}
local addOnName, AddOn = ...
local _ = {}

local KEY_FRAMING_ITEM_ID = 193201
local KEY_FRAGMENTS_ITEM_ID = 191251
local ASSEMBLING_SPELL_ID = 370298
local SABELLIAN_OBJECT_ID = 187447
local RESTORED_OBSIDIAN_KEY_ITEM_ID = 191264
local OBSIDIAN_STRONGBOX_ITEM_ID = 200070
local OBSIDIAN_CACHE_ITEM_ID = 200069

-- /dump Bot.KeysOfLoyalty.handleCompletion()

-- /dump Bot.KeysOfLoyalty.farm()

local isRunning = false

function Bot.DragonbaneKeep.toggleFarming()
  if not isRunning then
    isRunning = true
    print('Starting farming...')
    Coroutine.runAsCoroutine(function()
      while isRunning do
        Core.handleDeath()

        local mobsWhoDropKeyIngredients = Set.union(AddOn.mobsWhoDropKeyFraming, AddOn.mobsWhoDropKeyFragments)

        local mobsToFarm = Set.union(AddOn.rareObjectIDs, mobsWhoDropKeyIngredients)

        local rareMobs = Array.filter(Core.retrieveObjectPointers(), function(object)
          local objectID = HWT.ObjectId(object)
          return (
            (Core.isAlive(object) and Set.contains(AddOn.rareObjectIDs, objectID))
          )
        end)

        local closestRareMob = Core.findClosestObject(rareMobs)

        local closestObject

        if closestRareMob then
          closestObject = closestRareMob
        else
          local objects = Array.filter(Core.retrieveObjectPointers(), function(object)
            local objectID = HWT.ObjectId(object)
            return (
              (Core.isLootable(object) and Set.contains(AddOn.objectsWhoContainKeyFragments, objectID)) or
                (Core.isAlive(object) and Set.contains(mobsToFarm, objectID))
            )
          end)

          closestObject = Core.findClosestObject(objects)
        end

        if closestObject then
          if _.isObjectToInteractWith(closestObject) then
            -- FIXME: Seems to try to loot a second time.
            Resolvable.await(Core.moveToAndInteractWithObject(closestObject))
          else
            -- is mob
            Resolvable.await(Core.doMob(closestObject, {
              additionalStopConditions = function ()
                return not isRunning
              end
            }))
          end
        end

        Coroutine.yieldAndResume()
      end
    end)
  else
    isRunning = false
  end
end

function _.isObjectToInteractWith(object)
  return Set.contains(AddOn.objectsWhoContainKeyFragments, HWT.ObjectId(object))
end

function Bot.DragonbaneKeep.handleCompletion()
  Coroutine.runAsCoroutine(function()
    Bot.DragonbaneKeep.createKeys()
    Bot.DragonbaneKeep.turnKeysIn()
    Bot.DragonbaneKeep.openObsidianContainers()
  end)
end

function Bot.DragonbaneKeep.createKeys()
  -- FIXME: There seems to be another event after the cast success event, which seems to be required to wait for before the item counts in the bags have been updated.
  while Bot.DragonbaneKeep.canCreateKey() do
    Bot.DragonbaneKeep.createKey()
  end
end

function Bot.DragonbaneKeep.turnKeysIn()
  if Bags.hasItem(RESTORED_OBSIDIAN_KEY_ITEM_ID) then
    local sabellian = Core.findClosestObjectToCharacterWithObjectID(SABELLIAN_OBJECT_ID)
    if sabellian then
      repeat
        Core.interactWithObject(sabellian)
        Events.waitForEvent('QUEST_FINISHED')
      until not Bags.hasItem(RESTORED_OBSIDIAN_KEY_ITEM_ID)
    end
  end
end

function Bot.DragonbaneKeep.openObsidianContainers()
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

function Bot.DragonbaneKeep.canCreateKey()
  return Bags.countItem(KEY_FRAMING_ITEM_ID) >= 3 and Bags.countItem(KEY_FRAGMENTS_ITEM_ID) >= 30
end

function Bot.DragonbaneKeep.createKey()
  local containerIndex, slotIndex = Bags.findItem(KEY_FRAMING_ITEM_ID)
  if containerIndex and slotIndex then
    SpellCasting.useContainerItem(containerIndex, slotIndex)
    SpellCasting.waitForSpellCastSucceeded(ASSEMBLING_SPELL_ID)
    Events.waitForEvent('BAG_UPDATE_DELAYED')
  end
end
