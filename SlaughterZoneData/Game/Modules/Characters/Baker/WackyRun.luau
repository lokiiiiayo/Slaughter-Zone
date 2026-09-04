local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AbilityStateService = require(ServerScriptService.Game.Modules.AbilityStateService)
local UsageService = require(ServerScriptService.Game.Modules.UsageService)
local EffectService = require(ServerScriptService.Game.Modules.EffectService)
local Recipes = require(ReplicatedStorage.Game.Data.Abilities.Baker.Recipes)

return function(Player: Player)
	task.spawn(function()
		EffectService:AddEffectToPlayer(Player,"Speed",3,2)

		task.wait(3)

		EffectService:AddEffectToPlayer(Player,"Slowness",3,2)
	end)
	return true
end