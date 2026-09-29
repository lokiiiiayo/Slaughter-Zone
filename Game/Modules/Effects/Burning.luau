local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DamageService = require(ReplicatedStorage.Game.Modules.DamageService)
local DataModule = require(ReplicatedStorage.Game.Data.Effects.Burning)

type Effect = {
	Level: number,
	Name: string,
	Duration: number,
	PlayerEffected: Player,
	Connections: {RBXScriptConnection}
}

return function(Effect: Effect)
	local Character = Effect.PlayerEffected.Character or Effect.PlayerEffected.CharacterAdded:Wait() :: Model
	
	local Damage = DataModule[Effect.Level].BurnPerTick
	local conn
	
	local Elapsed = 0
	local TotalCount = 0
	conn = RunService.Heartbeat:Connect(function(DT)
		Elapsed += DT
		TotalCount += DT
		
		if TotalCount >= Effect.Duration then conn:Disconnect() return end
		
		if Elapsed >= DataModule.TickRate then
			Elapsed = 0
			
			DamageService:DamagePlayer(Effect.PlayerEffected,Damage,DataModule.Lethal)
		end
	end) 
	
	return conn
end