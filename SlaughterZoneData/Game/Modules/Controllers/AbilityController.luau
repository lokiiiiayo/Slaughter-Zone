local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local InputController = require(ReplicatedStorage.Game.Modules.Controllers.InputController)
local UIController = require(ReplicatedStorage.Game.Modules.Controllers.UIController)
local AnimationController = require(ReplicatedStorage.Game.Modules.Controllers.AnimationController)
local CooldownService = require(ReplicatedStorage.Game.Modules.CooldownService)

local AbilityPacket = require(ReplicatedStorage.Game.Packets.UseAbility)

local Player = Players.LocalPlayer
local PlayerGUI = Player.PlayerGui


local AbilityFolder = ReplicatedStorage.Game.Data.Abilities

local AbilityController = {}

function AbilityController.Init(self: AbilityController)
	self._Inititialized = true
	self.CurrentMoveset = nil
	self.AbilityKeybinds = {}
	self.Connections = {}
	
end

function AbilityController.UseAbility(self: AbilityController,AbilityName: string)
	if not AbilityName then return end
	if not AbilityFolder:FindFirstChild(AbilityName,true) then return end
	
	local AbiliyData = require(AbilityFolder:FindFirstChild(AbilityName,true))
		
	if not AbiliyData then return end
	
	if CooldownService:IsPlayerOnCooldown(AbilityName) then return end
	
	AnimationController:PlayAnimation(AbilityName,4,true)
	AbilityPacket.Send.send({AbilityName = AbilityName})
	CooldownService:SetPlayerCooldown(AbilityName,AbiliyData.Cooldown)
end

function AbilityController.UpdateMoveset(self: AbilityController,Moveset: string)
	if not Moveset then self:Cleanup() return end
	
	self:Cleanup()
	
	if ReplicatedStorage.Game.Modules.Characters:FindFirstChild(Moveset) then
		self.CurrentMoveset = ReplicatedStorage.Game.Modules.Characters:FindFirstChild(Moveset)
	else
		self.CurrentMoveset = nil
	end
end

function AbilityController.Start(self: AbilityController)
	local InpEndconn
	local InpStartconn
	
	InpStartconn = InputController.InputStarted:Connect(function(KeyPressed: Enum.KeyCode)
		if self.AbilityKeybinds[KeyPressed] then
			--print(self.AbilityKeybinds[KeyPressed])
		end
	end)
	
	InpEndconn = InputController.InputEnded:Connect(function(KeyPressed: Enum.KeyCode)
		if self.AbilityKeybinds[KeyPressed] then
			self:UseAbility(self.AbilityKeybinds[KeyPressed])
		end
	end)
	
	table.insert(self.Connections,InpEndconn)
	table.insert(self.Connections,InpStartconn)
	
	self:SetupUI()
end

function AbilityController.SetupUI(self: AbilityController)
	UIController:AddCharacterUI(self)
end

function AbilityController.Cleanup(self: AbilityController)
	if PlayerGUI:FindFirstChild("AbilityFrame") then
		PlayerGUI:FindFirstChild("AbilityFrame"):Destroy()
	end
	for _, Conn in self.Connections do
		Conn:Disconnect()
	end
	
	self.CurrentMoveset = nil
	self.AbilityKeybinds = {}
	
end

type AbilityController = typeof(AbilityController)&{
	_Inititialized: boolean,
	CurrentMoveset: Folder,
	AbilityKeybinds: {keybind: string},
	Connections: {RBXScriptConnection}
}

return AbilityController :: AbilityController