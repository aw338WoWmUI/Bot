local targetRenownLevel = 20

local majorFactionData = C_MajorFactions.GetMajorFactionData(2503)

local reputationRequiredPerRenownLevel = 2500
local remainingReputationToTargetRenownLevel = math.max((targetRenownLevel - majorFactionData.renownLevel - 1) * reputationRequiredPerRenownLevel + (reputationRequiredPerRenownLevel - majorFactionData.renownReputationEarned), 0)

local reputationPerToken = 15
local numberOfTokensRequiredToReachTheTargetRenownLevel = math.ceil(remainingReputationToTargetRenownLevel / reputationPerToken)

local TOKEN_ID = 200093
-- TODO: Also consider bank
local numberOfTokensCollected = Bags.countItem(TOKEN_ID)
local remainingNumberOfTokensRequiredToReachTheTargetRenownLevel = math.max(numberOfTokensRequiredToReachTheTargetRenownLevel - numberOfTokensCollected, 0)
