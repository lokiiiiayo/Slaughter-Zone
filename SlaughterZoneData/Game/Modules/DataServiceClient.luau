local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ReplicaClient = require(ReplicatedStorage.Packages.ReplicaClient)

local Player = Players.LocalPlayer

local DataServiceClient = {}

function DataServiceClient.Init(self: DataServiceClient)
	self._initialized = true
	
	self:Start()
end

function DataServiceClient.Start(self: DataServiceClient)
	ReplicaClient.OnNew(`PlayerData_{Player.UserId}`, function(replica)
		
		print("recieved")
		self.replica = replica
		print(replica)
	end)
end

function DataServiceClient.GetData(self: DataServiceClient,DataName: string)
	repeat task.wait() until self.replica
	
	
	local Data = self.replica.Data
	
	if not Data then warn(`Local data not found for {Player.Name}`) return end
	
	print(Data)
end

type DataServiceClient = typeof(DataServiceClient)&{
	_initialized: boolean,
	replica: ReplicaClient.Replica
}

return DataServiceClient :: DataServiceClient