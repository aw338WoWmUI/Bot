Core = {}

--- This list has been based on https://github.com/TrinityCore/TrinityCore/blob/4b06b8ec1e3ccc153a44b3eb2e8487641cfae98d/src/server/game/Entities/Unit/UnitDefines.h#L275-L310
--- which is licensed under the GNU General Public License v2.0 (full license: https://github.com/TrinityCore/TrinityCore/blob/75c06d25da76f0c4f0ea680e6f5ed1bc3bf1d42e/COPYING).
--- By the conditions of the license, this list is also licensed under the same license.
--- Modifications have been made (appropriate structure for LUA, name modifications, and entry selections).
Core.NpcFlags = {
  None = 0x0,
  Gossip = 0x1,
  QuestGiver = 0x2,
  Trainer = 0x10,
  ClassTrainer = 0x20,
  Vendor = 0x80,
  AmmoVendor = 0x100,
  FoodVendor = 0x200,
  PoisonVendor = 0x400,
  ReagentVendor = 0x800,
  Repair = 0x1000,
  FlightMaster = 0x2000,
  Innkeeper = 0x10000,
  Banker = 0x20000,
  Petitioner = 0x40000,
  TabardDesigner = 0x80000,
  BattleMaster = 0x100000,
  Auctioneer = 0x200000,
  StableMaster = 0x400000,
  GuildBanker = 0x800000,
  SpellClick = 0x1000000,
  PlayerVehicle = 0x2000000,
  Mailbox = 0x4000000,
  ArtifactPowerRespec = 0x8000000,
  Transmogrifier = 0x10000000,
  Vaultkeeper = 0x20000000,
  WildBattlePet = 0x40000000,
  BlackMarket = 0x80000000,
}

function Core.isUnit(object)
  return HWT.ObjectIsType(object, HWT.GetObjectTypeFlagsTable().Unit)
end

function Core.isGameObject(object)
  return HWT.ObjectIsType(object, HWT.GetObjectTypeFlagsTable().GameObject)
end

function Core.isItem(object)
  return HWT.ObjectIsType(object, HWT.GetObjectTypeFlagsTable().Item)
end

function Core.areFlagsSet(bitMap, flags)
  return bit.band(bitMap, flags) == flags
end

function Core.areUnitNPCFlagsSet(object, flags)
  local npcFlags = Core.retrieveObjectNPCFlags(object)
  return Core.areFlagsSet(npcFlags, flags)
end

function Core.isUnitNPCType(object, flags)
  return Core.isUnit(object) and Core.areUnitNPCFlagsSet(object, flags)
end

function Core.retrieveObjectNPCFlags(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__npcFlags, HWT.GetValueTypesTable().ULong)
end

function Core.isFoodVendor(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.FoodVendor)
end

function Core.isFoodVendor(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.FoodVendor)
end

function Core.isInnkeeper(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.Innkeeper)
end

function Core.isBanker(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.Banker)
end

function Core.isRepair(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.Repair)
end

function Core.isFlightMaster(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.FlightMaster)
end

function Core.hasGossip(object)
  return Core.isUnitNPCType(object, Core.NpcFlags.Gossip)
end

local sellVendorFlags = {
  Core.NpcFlags.Vendor,
  Core.NpcFlags.AmmoVendor,
  Core.NpcFlags.FoodVendor,
  Core.NpcFlags.PoisonVendor,
  Core.NpcFlags.ReagentVendor,
  Core.NpcFlags.Repair
}

function Core.isSellVendor(object)
  if Core.isUnit(object) then
    local npcFlags = Core.retrieveObjectNPCFlags(object)
    return Array.any(sellVendorFlags, function (flags)
      return Core.areFlagsSet(npcFlags, flags)
    end)
  end

  return false
end

function Core.isFlightMasterDiscoverable(object)
  local value = HWT.ObjectDescriptor(object, 88, HWT.GetValueTypesTable().ULong)
  return Core.areFlagsSet(value, 2)
end

function Core.isDiscoverableFlightMaster(object)
  return Core.isFlightMaster(object) and GMR.UnitReaction('player', object) >= 4 and Core.isFlightMasterDiscoverable(object)
end

function Core.includePointerInObject(objects)
  local result = {}
  for pointer, object in pairs(objects) do
    object.pointer = pointer
    table.insert(result, object)
  end
  return result
end
