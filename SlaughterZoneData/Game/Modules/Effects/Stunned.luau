local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local EffectService = require(ServerScriptService.Game.Modules.EffectService)

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

	local SpeedDecrease = 0
	local conn
	local conn2

	local TotalCount = 0
	local Elapsed = 0

	local OriginalSpeed = Humanoid.WalkSpeed

	conn2 = Effect.EffectedEnded:Connect(function()
		Effect.PlayerEffected:SetAttribute("SpeedDecrease",1)
	end)

	conn = RunService.Heartbeat:Connect(function(DT)
		TotalCount += DT

		if TotalCount >= Effect.Duration then conn:Disconnect() Effect.PlayerEffected:SetAttribute("SpeedDecrease",1) return end

		Effect.PlayerEffected:SetAttribute("SpeedDecrease",SpeedDecrease)
	end)

	table.insert(Effect.Connections,conn2)
	return conn
end