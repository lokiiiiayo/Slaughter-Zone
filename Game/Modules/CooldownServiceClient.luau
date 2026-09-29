local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local CooldownServicePacket = require(ReplicatedStorage.Game.Packets.CooldownServicePacket)

local CooldownService = {}

function CooldownService.Init(self: CooldownService)

	self._Initialized = true

	self.PlayerCooldowns = {}
end

function CooldownService.IsPlayerOnCooldown(self: CooldownService,Ability: string)
	if self.PlayerCooldowns[Ability] then
		if self.PlayerCooldowns[Ability] > os.clock() then
			return true
		else
			return false
		end
	end
end

function CooldownService.SetPlayerCooldown(self: CooldownService, Ability: string, Duration: number)
	self.PlayerCooldowns[Ability] = os.clock() + Duration
end

function CooldownService.RemovePlayerCooldown(self: CooldownService, Ability: string)
	self.PlayerCooldowns[Ability] = 0
end

type CooldownService = typeof(CooldownService)&{
	_Initialized: boolean,
	PlayerCooldowns: { {Ability: number}}
}
return CooldownService :: CooldownService