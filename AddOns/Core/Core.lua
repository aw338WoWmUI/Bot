Core = {}

Core.NpcFlags = {
  FoodVendor = 0x200,
  Repair = 0x1000,
  FlightMaster = 0x2000,
  Innkeeper = 0x10000,
  Banker = 0x20000,
}

function Core.areFlagsSet(bitMap, flags)
  return bit.band(bitMap, flags) == flags
end

function Core.retrieveObjectNPCFlags(object)
  return HWT.ObjectDescriptor(object, HWT.GetObjectDescriptorsTable().CGUnitData__npcFlags, HWT.GetValueTypesTable().ULong)
end

function Core.isFoodVendor(object)
  local npcFlags = Core.retrieveObjectNPCFlags(object)
  return Core.areFlagsSet(npcFlags, Core.NpcFlags.FoodVendor)
end

function Core.isInnkeeper(object)
  local npcFlags = Core.retrieveObjectNPCFlags(object)
  return Core.areFlagsSet(npcFlags, Core.NpcFlags.Innkeeper)
end

function Core.isBanker(object)
  local npcFlags = Core.retrieveObjectNPCFlags(object)
  return Core.areFlagsSet(npcFlags, Core.NpcFlags.Banker)
end

function Core.isRepair(object)
  local npcFlags = Core.retrieveObjectNPCFlags(object)
  return Core.areFlagsSet(npcFlags, Core.NpcFlags.Repair)
end

function Core.isFlightMaster(object)
  local npcFlags = Core.retrieveObjectNPCFlags(object)
  return Core.areFlagsSet(npcFlags, Core.NpcFlags.FlightMaster)
end

function Core.isFlightMasterDiscoverable(object)
  local value = HWT.ObjectDescriptor(object, 88, HWT.GetValueTypesTable().ULong)
  return Core.areFlagsSet(value, 2)
end

function Core.isDiscoverableFlightMaster(object)
  return false
  -- return Core.isFlightMaster(object) and GMR.UnitReaction('player', object) >= 4 and Core.isFlightMasterDiscoverable(object)
end
