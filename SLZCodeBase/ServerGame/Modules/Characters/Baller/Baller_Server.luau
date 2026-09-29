local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local EffectService = require(ServerScriptService.ServerGame.Modules.EffectService)
local DamageService = require(ServerScriptService.ServerGame.Modules.DamageService)
local CooldownService = require(ServerScriptService.ServerGame.Modules.CooldownService)

local VfxReplicationPacket = require(ReplicatedStorage.Game.Packets.ClientReplication.VfxReplicationPacket)


local Baller_Server = {}

function Baller_Server.init(self: Baller_Server)
	self._initialized = true
	self.PlayersUsing = {}
	
	
end

function Baller_Server.SetupPlayer(self: Baller_Server, Player: Player)
	self.PlayersUsing[Player.UserId] = {
		AbilitiesOnCooldowns = {},
		AbilitiesUsing = {},
	}
end

function Baller_Server.RicochetEffect(self: Baller_Server,Player: Player)
	if CooldownService:IsPlayerOnCooldown(Player,"Ricochet Effect") then return end
	
	
end

function Baller_Server.Bomball(self: Baller_Server,Player: Player)
	if CooldownService:IsPlayerOnCooldown(Player,"Bomball") then return end
	if EffectService:PlayerHasEffect(Player,"Stunned") then return end
	
	self.PlayersUsing[Player.UserId].AbilitiesUsing["Bomball"] = {Cancellable = true, Using = true}
	
	local Charging = true
	local ChargeLevel = 0
	
	local function Bomball()
		--Put here what happens when it's done charging
	end
	
	
	local Elapsed = 0
	
	RunService.RenderStepped:Connect(function(DT)
		--Finish up uh er
		--The uh
		--Whatever lets you cancel it during windup or wtv
		--Replicate animations and stuff too ig
		Elapsed += 1
		
		
		if ChargeLevel >= 3 then
			
		else
			ChargeLevel += 1
			
		end
		
	end)
	
end

function Baller_Server.Skid(self: Baller_Server,Player: Player)
	if CooldownService:IsPlayerOnCooldown(Player,"Skid") then return end
	
	
end






type Baller_Server = typeof(Baller_Server)&{
	_initialized: boolean,
	PlayersUsing: {}
}

return Baller_Server :: Baller_Server