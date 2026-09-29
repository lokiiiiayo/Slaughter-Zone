local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterServicePacket = require(ReplicatedStorage.Game.Packets.CharacterServicePacketWIP)
local DataService = require(ServerScriptService.ServerGame.Modules.DataService)
local AbilityStateService = require(ServerScriptService.ServerGame.Modules.AbilityStateService)

local CharacterStates = ReplicatedStorage.Game.Data.States

local CharacterService = {}

function CharacterService.Init(self: CharacterService)
	self._initialized = true
	self.players = {}
	
end

function CharacterService.UpdateCharacter(self: CharacterService)
	
end

function CharacterService.EquipCharacter(self: CharacterService)
	
end

function CharacterService.GiveCharacter(self: CharacterService, Player: Player, Character: string)
	
end

function CharacterService.GetEquippedCharacters(self: CharacterService, Player: Player)
	
end

function CharacterService.SyncClient(self: CharacterService, Player: Player)
	
end


type CharacterService = typeof(CharacterService)&{
	_initialized: boolean,
	players: {Player: {}}
}

return CharacterService :: CharacterService