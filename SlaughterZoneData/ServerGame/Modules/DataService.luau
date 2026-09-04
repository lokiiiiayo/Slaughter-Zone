local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileStore = require(ReplicatedStorage.Packages.ProfileStore)
local ReplicaServer = require(ReplicatedStorage.Packages.ReplicaServer)

local DefaultData = require(ReplicatedStorage.Game.Data.DefaultPlayerData)

local DataService = {}

function DataService.Init(self: DataService)

	self._Initialized = true
	self.PlayerDatas = {}
	self.replicas = {}
	self.NewStore = ProfileStore.New("Test20",DefaultData)
	self.DefaultErrorMsg = "Data error occured"


	self:Start()
end

function DataService.Start(self: DataService)
	Players.PlayerAdded:Connect(function(Player: Player)
		local NewProfile = self.NewStore:StartSessionAsync("PlayerID_"..Player.UserId,{
			Cancel = function()
				return Player.Parent ~= Players
			end,
		})
		if NewProfile == nil then Player:Kick(self.DefaultErrorMsg) self.PlayerDatas[Player] = nil return end
		NewProfile:AddUserId(Player.UserId)
		NewProfile:Reconcile()
		
		NewProfile.OnSessionEnd:Connect(function()
			Player:Kick(self.DefaultErrorMsg)
		end)
		
		if Player.Parent ~= Players then NewProfile:EndSession() Player:Kick(self.DefaultErrorMsg) self.PlayerDatas[Player] = nil end
		
		self.PlayerDatas[Player] = NewProfile
		
		
		local playerReplica = ReplicaServer.New({
			Token = ReplicaServer.Token(`PlayerData_{Player.UserId}`),
			Data = {
				PlayerData = NewProfile.Data
			}
		})
		
		self.replicas[Player.UserId] = playerReplica
	end)
	
	ReplicaServer.NewReadyPlayer:Connect(function(Player)
		if self.replicas[Player.UserId] then
			self.replicas[Player.UserId]:Subscribe(Player)
		end
	end)
end

function DataService.UpdateData(self: DataService,Player: Player,DataName: string,UpdatedValue: number?)
	local Store = self.PlayerDatas[Player]:: typeof(ProfileStore.New("Test",DefaultData):StartSessionAsync("PlayerID_"))
	
	if not Store then warn("Player data store not found") return end
	
	Store.Data[DataName] = UpdatedValue
	
	Store:Save()
	
	
	print(Store.Data)
	self.replicas[Player.UserId]:Set({"PlayerData"},Store.Data)
end

function DataService.UpdateTableWithKey(self: DataService,Player: Player,DataName: string,Key: string,Value: string)
	local Store = self.PlayerDatas[Player]:: typeof(ProfileStore.New("Test",DefaultData):StartSessionAsync("PlayerID_"))
	if not Store then warn("Player data store not found") return end
	
	Store.Data[DataName][Key] = Value
	
	print(Store.Data)
	
	Store:Save()
	self.replicas[Player.UserId]:Set({"PlayerData"},Store.Data)
end

function DataService.RemoveDataFromTable(self: DataService,Player: Player,DataName: string,ValueKey: {},NewValue)
	local Store = self.PlayerDatas[Player]:: typeof(ProfileStore.New("Test",DefaultData):StartSessionAsync("PlayerID_"))
	if not Store then warn("Player data store not found") return end

	Store.Data[DataName][ValueKey] = NewValue
	Store:Save()
end

function DataService.GetData(self: DataService,Player: Player,DataName: string)
	local Store = self.PlayerDatas[Player]
	if not Store then warn("Player data store not found") return false end
	
	local DataToReturn = Store.Data[DataName]
	
	return DataToReturn
end


type DataService = typeof(DataService)&{
	_Initialized: boolean,
	PlayerDatas: {},
	NewStore: typeof(ProfileStore.New("Test",DefaultData)),
	DefaultErrorMsg: string,
	replicas: {Player: ReplicaServer.Replica}
}


return DataService:: DataService