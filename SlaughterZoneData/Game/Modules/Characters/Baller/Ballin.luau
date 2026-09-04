local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HitboxCreator = require(ServerScriptService.Game.Modules.HitboxCreator)
local BallinData = require(ReplicatedStorage.Game.Data.Abilities.Baller.Ballin)

return function(Player: Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local HRP = Character:FindFirstChild("HumanoidRootPart") :: BasePart
	
	local NewHitbox = HitboxCreator.New({
		ObjectFollowing = HRP,
		Offset = CFrame.new(0,0,-4),
		HitboxCount = 15,
		HitboxDuration = 3,
		HitboxLifeTime = 0.1,
		HitboxSize = Vector3.new(4,10,4),
		TimeBetweenHitboxes = 0.07,
	})
	NewHitbox:Activate()
	
	NewHitbox.HitboxTouched:Connect(function(CharacterHit: Model)
		local HumanoidHit = CharacterHit:FindFirstChild("Humanoid") :: Humanoid
		
		HumanoidHit:TakeDamage(BallinData.Damage)
	end)
	
	return true
end