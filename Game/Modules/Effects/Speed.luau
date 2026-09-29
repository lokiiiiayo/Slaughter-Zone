local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local DataModule = require(ReplicatedStorage.Game.Data.Effects.Speed)

type Effect = {
	Level: number,
	Name: string,
	PlayerEffected: Player,
	Duration: number,
	EffectedEnded: BindableEvent,
	Connections: {RBXScriptConnection},
}

return function(Effect: Effect)
	local Character = Effect.PlayerEffected.Character or Effect.PlayerEffected.CharacterAdded:Wait() :: Model
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

	local SpeedIncrease = DataModule[Effect.Level].SpeedIncrease
	local conn
	local conn2
	
	local TotalCount = 0
	local Elapsed = 0

	local OriginalSpeed = Humanoid.WalkSpeed
	
	conn2 = Effect.EffectedEnded:Connect(function()
		Effect.PlayerEffected:SetAttribute("SpeedIncrease",1)
	end)
	
	conn = RunService.Heartbeat:Connect(function(DT)
		TotalCount += DT

		if TotalCount >= Effect.Duration then conn:Disconnect() Effect.PlayerEffected:SetAttribute("SpeedIncrease",1) return end
		
		Effect.PlayerEffected:SetAttribute("SpeedIncrease",SpeedIncrease)
	end)
	
	table.insert(Effect.Connections,conn2)
	return conn
end