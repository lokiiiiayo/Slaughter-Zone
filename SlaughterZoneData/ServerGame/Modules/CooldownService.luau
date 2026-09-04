local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local CooldownServicePacket = require(ReplicatedStorage.Game.Packets.CooldownServicePacket)

local CooldownService = {}

function CooldownService.Init(self: CooldownService)

	self._Initialized = true

	self.PlayersOnCooldown = {}
end

function CooldownService.IsPlayerOnCooldown(self: CooldownService,Player: Player,Ability: string)
	if self.PlayersOnCooldown[Player] and self.PlayersOnCooldown[Player][Ability] then
		if self.PlayersOnCooldown[Player][Ability] > os.clock() then
			Player:SetAttribute(Ability,nil)
			return true
		else
			return false
		end
	end
end

function CooldownService.SetPlayerCooldown(self: CooldownService, Player: Player, Ability: string, Duration: number)
	if not self.PlayersOnCooldown[Player] then
		self.PlayersOnCooldown[Player] = {}
	end
	self.PlayersOnCooldown[Player][Ability] = os.clock() + Duration
	Player:SetAttribute(Ability,Duration)
	CooldownServicePacket.NewCooldown.sendTo({Ability = Ability,Duration = Duration},Player)
end

function CooldownService.RemovePlayerCooldown(self: CooldownService, Player: Player, Ability: string)
	self.PlayersOnCooldown[Player][Ability] = 0
end

type CooldownService = typeof(CooldownService)&{
	_Initialized: boolean,
	PlayersOnCooldown: {Player: {Ability: number}}
}
return CooldownService :: CooldownService