local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AbilityStateService = require(ServerScriptService.Game.Modules.AbilityStateService)
local UsageService = require(ServerScriptService.Game.Modules.UsageService)
local Bookmark = require(ReplicatedStorage.Game.Data.Abilities.Baker.Bookmark)

return function(Player: Player)
	if AbilityStateService:GetStateWithKey(Player,"Baker","IsBookmarked") == true then return false end
	
	AbilityStateService:SetState(Player,"Baker","IsBookmarked",true)
	return true
end