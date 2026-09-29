local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterServiceClientPacket = require(ReplicatedStorage.Game.Packets.CharacterServiceClientPacketWIP)

local Player = Players.LocalPlayer

local CharacterServiceClient = {}

function CharacterServiceClient.Init(self: CharacterServiceClient)
	self._Initialized = true
end


type CharacterServiceClient = typeof(CharacterServiceClient)&{
	_Initialized: boolean,
}

return CharacterServiceClient :: CharacterServiceClient