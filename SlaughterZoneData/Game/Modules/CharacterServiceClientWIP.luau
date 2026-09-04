local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterServicePacket = require(ReplicatedStorage.Game.Packets.CharacterServicePacketWIP)

local Player = Players.LocalPlayer

local CharacterService = {}

function CharacterService.Init(self: CharacterService)
	self._Initialized = true
end


type CharacterService = typeof(CharacterService)&{
	_Initialized: boolean,
}

return CharacterService :: CharacterService