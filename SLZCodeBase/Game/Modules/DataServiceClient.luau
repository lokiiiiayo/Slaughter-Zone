local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ReplicaClient = require(ReplicatedStorage.Packages.ReplicaClient)

local Player = Players.LocalPlayer

local DataServiceClient = {}

function DataServiceClient.Init(self: DataServiceClient)
	self._initialized = true
	self.replica = nil
	self.Data = {}
	
	self:Start()
end

function DataServiceClient.Start(self: DataServiceClient)
	ReplicaClient.OnNew(`PlayerData_{Player.UserId}`, function(replica)
		
		self.replica = replica
	end)
end

function DataServiceClient.GetData(self: DataServiceClient,DataName: string)
	repeat task.wait() until self.replica
	
	
	local Data = self.replica.Data
	
	if not Data then warn(`Local data not found for {Player.Name}`) return end
	
	self.Data = Data.PlayerData
end

type DataServiceClient = typeof(DataServiceClient)&{
	_initialized: boolean,
	replica: ReplicaClient.Replica,
	Data: {
		Tix: number,
		Survivor: string,
		Killer: string,
		OwnedCharacters: {killers: {}, Survivors: {}},
		OwnedSkins: {Skin: boolean},
		EquippedSkins: {string: {Skin: string, Variant: string?}},
	}
}

return DataServiceClient :: DataServiceClient