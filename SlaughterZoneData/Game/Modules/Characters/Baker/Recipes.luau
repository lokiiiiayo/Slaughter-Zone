local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AbilityStateService = require(ServerScriptService.Game.Modules.AbilityStateService)
local UsageService = require(ServerScriptService.Game.Modules.UsageService)
local Recipes = require(ReplicatedStorage.Game.Data.Abilities.Baker.Recipes)

local Recipes = require(ReplicatedStorage.Game.Data.Abilities.Baker.Recipes)

return function(Player: Player)
	local state = AbilityStateService:GetState(Player,"Baker")
	
	AbilityStateService:SetState(Player,"Baker","CurrentRecipeIndex", (state.CurrentRecipeIndex % #Recipes.RecipeOrder) + 1)
	local newRecipe = Recipes.RecipeOrder[AbilityStateService:GetStateWithKey(Player,"Baker","CurrentRecipeIndex")]

	-- TODO: ROBERT - Trigger HUD update for new recipe/quote here
	warn(Player.Name .. " switched to " .. newRecipe)
	
	return true
end