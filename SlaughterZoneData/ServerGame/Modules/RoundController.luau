local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local MapService = require(ServerScriptService.Game.Modules.MapService)
local CharacterService = require(ServerScriptService.Game.Modules.CharacterService)
local DamageService = require(ServerScriptService.Game.Modules.DamageService)

local TimerPacket = require(ReplicatedStorage.Game.Packets.UpdateTimer)

local IntermissionTime = 10
local RoundTime = 20
local MINIMUM_PLAYERS = 3
local IncrementRate = 1
local Killers = 1

local RoundController =	 {}

function RoundController.Init(self: RoundController)
	
	self._initialized = true
	self.RoundRunning = false
	self.IntermissionRunning = true
	self.RoundPossible = false
	self.RoundTime = IntermissionTime
	self.PlayersInLobby = {}
	self.PlayersInRound = {}
	self.Survivors = {}
	self.Killers = {}
	self.PlayersAvailable = {}
	self.Connections = {}
	
	self:Start()
	self:RoundLoop()
end

function RoundController.MonitorPlayers(self: RoundController,PlayerGroup: {Player})
	for _, Player: Player in PlayerGroup do
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
		
		if not Character or not Humanoid then continue end
		
		local Humdiedconn
		local CharacterDestructionconn
		
		Humdiedconn = Humanoid.Died:Connect(function()
			self:RemovePlayerFromRound(Player)
		end)
		
		CharacterDestructionconn = Character.Destroying:Connect(function()
			self:RemovePlayerFromRound(Player)
		end)
		
		self.Connections[Humdiedconn] = Humdiedconn
		self.Connections[CharacterDestructionconn] = CharacterDestructionconn
	end
	
	local PlayerLeavingconn
	local Diedconn
	
	PlayerLeavingconn = Players.PlayerRemoving:Connect(function(Player)
		self:RemovePlayerFromRound(Player)
	end)
	
	Diedconn = DamageService.PlayerDied:Connect(function(PlayerWhoDied)
		self:RemovePlayerFromRound(PlayerWhoDied)
	end)
	
	self.Connections[Diedconn] = Diedconn
	self.Connections[PlayerLeavingconn] = PlayerLeavingconn
end

function RoundController.RemovePlayerFromRound(self: RoundController,Player: Player)
	print("Removed", Player.Name)
	
	self.Survivors[Player] = nil
	self.PlayersInRound[Player] = nil
	self.Killers[Player] = nil
end

function RoundController.PickRandom(self: RoundController,Group: {})
	local NewTable = {}
	for _, Value in Group do
		table.insert(NewTable,Value)
	end
	
	if not NewTable then warn("Table doesnt exist") return end
	if not #NewTable then warn("Table not full of anyone") return end
	
	return NewTable[math.random(1,#NewTable)]
end

function RoundController.SelectKiller(self: RoundController)
	for i = 1, Killers do
		local ChosenKiller = self:PickRandom(self.PlayersAvailable)
		
		
		self.Killers[ChosenKiller] = ChosenKiller
		self.PlayersInRound[ChosenKiller] = ChosenKiller
		self.PlayersInLobby[ChosenKiller] = nil
	end
end

function RoundController.SelectSurvivors(self: RoundController)
	for _, Survivor in self.PlayersInLobby do
		self.Survivors[Survivor] = Survivor
		self.PlayersInRound[Survivor] = Survivor
		self.PlayersInLobby[Survivor] = nil
	end
end


function RoundController.RoundLoop(self: RoundController)
	task.spawn(function()
		while task.wait(1) do
			if not self.RoundPossible then continue end
			
			if self.IntermissionRunning or self.RoundRunning then
				self.RoundTime -= IncrementRate
				
				if (self.RoundTime - IncrementRate) <= 0 then
					print("Round starting")
					self.IntermissionRunning = not self.IntermissionRunning
					self.RoundRunning = not self.RoundRunning
					
					if self.RoundRunning then
						self:StartRound()
					else
						self:EndRound()
					end
				end
			end
			
			if self.RoundRunning and self:GetRoundPlayerCount() <= 0 then
				self.RoundRunning = false
				self.IntermissionRunning = true
				self.RoundTime = 0
				self:EndRound()
			end
			
			TimerPacket.newtimervalue.sendToAll({
				message = self.RoundTime
			})
		end
	end)
end

function RoundController.StartRound(self: RoundController)
	print("Started round")
	self.RoundTime = RoundTime
	
	
	self:SelectKiller()
	self:SelectSurvivors()
	
	self.PlayersInLobby = {}
	
	CharacterService:LoadCharacterForGroup(self.Survivors,"Survivor")
	CharacterService:LoadCharacterForGroup(self.Killers,"Killer")
	
	MapService:LoadRandomMap()
	MapService:TeleportPlayersToMap(self.Killers)
	MapService:TeleportPlayersToMap(self.Survivors)
	
	self:MonitorPlayers(self.PlayersInRound)
end

function RoundController.EndRound(self: RoundController)
	print("Ended round")
	for _, Player in self.PlayersInRound do
		self:RemovePlayerFromRound(Player)
		self.PlayersInLobby[Player] = Player
	end
	
	self.PlayersInRound = {}
	self.Survivors = {}
	self.Killers = {}
	
	self.RoundTime = IntermissionTime
	MapService:DestroyAllLoadedMaps()
	
	for _, Conn in self.Connections do
		Conn:Disconnect()
	end
end


function RoundController.Start(self: RoundController)
	Players.PlayerAdded:Connect(function(Player: Player)
		self.PlayersInLobby[Player] = Player
		self.PlayersAvailable[Player] = Player
	end)
	
	Players.PlayerRemoving:Connect(function(Player: Player)
		self.PlayersInLobby[Player] = nil
		self.PlayersInRound[Player] = nil
		self.Survivors[Player] = nil
		self.Killers[Player] = nil
		self.PlayersAvailable[Player] = nil
	end)
	
	RunService.Heartbeat:Connect(function()
		if self.RoundRunning then return end
		
		if self:GetLobbyPlayerCount() >= MINIMUM_PLAYERS then
			self.RoundPossible = true
		else
			self.RoundPossible = false
		end
	end)
end

function RoundController.AddTimeToRound(self: RoundController,Time: number)
	if not self.RoundRunning then warn("Round not running") return end
	
	self.RoundTime += Time
end

function RoundController.ReduceTimeFromRound(self: RoundController,Time: number)
	if not self.RoundRunning then warn("Round not running") return end

	self.RoundTime -= Time
end


function RoundController.IsPlayerInRound(self: RoundController,Player:Player)
	if self.PlayersInLobby[Player] then return end
	
	return self.PlayersInRound[Player]
end

function RoundController.GetPlayersInRound(self: RoundController)
	
	return self.PlayersInRound
end

function RoundController.GetLobbyPlayerCount(self: RoundController)
	local CurrentCount = 0
	
	for _, player in self.PlayersInLobby do
		CurrentCount += 1
	end
	
	return CurrentCount
end

function RoundController.GetRoundPlayerCount(self: RoundController)
	local CurrentCount = 0

	for _, player in self.PlayersInRound do
		CurrentCount += 1
	end

	return CurrentCount
end

type RoundController = typeof(RoundController)&{
	_initialized: boolean,
	RoundRunning: boolean,
	IntermissionRunning: boolean,
	RoundPossible: boolean,
	RoundTime: number,
	PlayersInRound: {Player},
	PlayersInLobby: {Player},
	Survivors: {Player},
	Killers: {Player},
	PlayersAvailable: {Player},
	Connections: {RBXScriptConnection}
}

return RoundController :: RoundController