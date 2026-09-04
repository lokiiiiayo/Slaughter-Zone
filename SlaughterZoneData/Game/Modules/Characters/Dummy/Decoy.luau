local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local UsageService = require(ServerScriptService.Game.Modules.UsageService)
local SwapData = require(ReplicatedStorage.Game.Data.Abilities.Dummy.Swap)
local DecoyData = require(ReplicatedStorage.Game.Data.Abilities.Dummy.Decoy)

return function(Player: Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	
	if workspace.Dummies:FindFirstChild(Character.Name..Player.Name) then return false end
	
	if not UsageService:GetUsages(Player,"Swap") then
		UsageService:AddUsageLimit(Player,"Swap",SwapData.UsageStart,0)
	end
	
	Character.Archivable = true
	
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	
	Humanoid:TakeDamage(DecoyData.HpCost)
	
	local NewDummy = Character:Clone()
	NewDummy.Name = Character.Name..Player.Name
	local DummyHumanoid = NewDummy:FindFirstChild("Humanoid") :: Humanoid
	
	DummyHumanoid.MaxHealth = DecoyData.DummyHP
	DummyHumanoid.Health = DecoyData.DummyHP
	
	DummyHumanoid.HealthChanged:Connect(function()
		if UsageService:GetMaxUsage(Player,"Swap") < SwapData.UsageMax then
			UsageService:AddToMaxUsages(Player,"Swap",1)
		end
	end)
	
	NewDummy.Parent = workspace.Dummies
	
	game.Debris:AddItem(NewDummy,DecoyData.DummyLifetime)
	
	return true
end