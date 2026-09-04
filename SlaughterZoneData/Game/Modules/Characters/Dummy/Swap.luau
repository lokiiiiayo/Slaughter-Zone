local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SwapData = require(ReplicatedStorage.Game.Data.Abilities.Dummy.Swap)
local UsageService = require(ServerScriptService.Game.Modules.UsageService)

return function(Player: Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	
	if not workspace.Dummies:FindFirstChild(Character.Name..Player.Name) then return false end
	
	if not UsageService:GetUsages(Player,"Swap") then
		UsageService:AddUsageLimit(Player,"Swap",SwapData.UsageStart,0)
	end
	
	if not UsageService:CanUseAbility(Player,"Swap") then warn("Usage limit reached") return false end
	
	local DummyToSwap = workspace.Dummies:FindFirstChild(Character.Name..Player.Name) :: Model
	
	local DummyCF = DummyToSwap.HumanoidRootPart.CFrame :: CFrame
	local CharacterCF = Character.HumanoidRootPart.CFrame :: CFrame
	
	local DummyHumanoid = DummyToSwap:FindFirstChild("Humanoid") :: Humanoid
	local PlayerHumanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	
	local TargetHP = DummyHumanoid.Health
	
	Character:PivotTo(DummyCF)
	DummyToSwap:PivotTo(CharacterCF)
	
	UsageService:AddUsageToAbility(Player,"Swap")
	
	PlayerHumanoid.Health = TargetHP
	
	return true
end