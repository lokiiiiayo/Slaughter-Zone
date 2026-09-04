local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AbilityStateService = require(ServerScriptService.Game.Modules.AbilityStateService)
local UsageService = require(ServerScriptService.Game.Modules.UsageService)
local MakeCake = require(ReplicatedStorage.Game.Data.Abilities.Baker.MakeCake)
local Recipes = require(ReplicatedStorage.Game.Data.Abilities.Baker.Recipes)

local EffectService = require(ServerScriptService.Game.Modules.EffectService)

local cakeModel = workspace.Baker.Assets:WaitForChild("CakeModel")

return function(Player: Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	
	local state = AbilityStateService:GetState(Player,"Baker")
	local hum = Character:FindFirstChild("Humanoid")
	
	AbilityStateService:SetState(Player,"Baker","IsBaking",true)

	EffectService:AddEffectToPlayer(Player,"Stunned",MakeCake.BakeTime,1)
	
	task.wait(MakeCake.BakeTime)
	
	if not hum.Parent or hum.Health <= 0 then 
		state.IsBaking = false
		state.OnCooldown.MakeCake = false
		return 
	end
	
	AbilityStateService:SetState(Player,"Baker","IsBaking",false)
	
	local flavor = Recipes.RecipeOrder[state.CurrentRecipeIndex]
	
	local newCake = cakeModel:Clone()
	newCake.Parent = workspace
	newCake:PivotTo(Character.PrimaryPart.CFrame * CFrame.new(0, -2, -3))
	
	newCake:SetAttribute("Flavor", flavor)
	newCake:SetAttribute("BakerId", Player.UserId)
	newCake:SetAttribute("Servings", 4)
	
	if not state.IsBookmarked then
		local nextIndex
		repeat nextIndex = math.random(1, #Recipes.RecipeOrder) until nextIndex ~= state.CurrentRecipeIndex
		state.CurrentRecipeIndex = nextIndex
	end
	
	return true
end