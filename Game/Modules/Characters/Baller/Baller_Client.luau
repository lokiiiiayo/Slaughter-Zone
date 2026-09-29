local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CooldownServiceClient = require(ReplicatedStorage.Game.Modules.CooldownServiceClient)

local Baller_Client = {}

function Baller_Client.init(self: Baller_Client)
	self._initialized = true
	
end

function Baller_Client.RicochetEffect(self: Baller_Client,PlayerUsing: Player)
	
end

function Baller_Client.Bomball(self: Baller_Client,PlayerUsing: Player)
	
end

function Baller_Client.Skid(self: Baller_Client,PlayerUsing: Player)
	
end



type Baller_Client = typeof(Baller_Client)&{
	_initialized: boolean
}

return Baller_Client :: Baller_Client