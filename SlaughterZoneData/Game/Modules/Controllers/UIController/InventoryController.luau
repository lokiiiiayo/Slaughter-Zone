local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local InputController = require(ReplicatedStorage.Game.Modules.Controllers.InputController)
local CharacterServicePacket = require(ReplicatedStorage.Game.Packets.CharacterService)
local CharacterService = require(ReplicatedStorage.Game.Modules.CharacterService)
local CameraController = require(ReplicatedStorage.Game.Modules.Controllers.CameraController)
local MovementController = require(ReplicatedStorage.Game.Modules.Controllers.MovementController)

local Signal = require(ReplicatedStorage.Packages.Signal)

local Player = Players.LocalPlayer

local PlayerGUI = Player.PlayerGui

local ShopCords = CFrame.new(-3.119, 5.046, -5.177)

local Info = TweenInfo.new(1,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)

local EndShopTextGoal = {Position = UDim2.new(0.043, 0,0, 0)}
local StartShopTextGoal = {Position = UDim2.new(0.043, 0,-0.3, 0)}

local EndRightSideGoal = {Position = UDim2.new(0.494, 0,0.027, 0)}
local StartRightSideGoal = {Position = UDim2.new(0.494, 0,1, 0)}

local Background = PlayerGUI:WaitForChild("Shop").Background

local RightSide = Background.RightSide
local ShopText = Background.ShopTextFrame

local ShopTextStartTween = TweenService:Create(ShopText,Info,StartShopTextGoal)
local ShopTextEndTween = TweenService:Create(ShopText,Info,EndShopTextGoal)

local RightStartTween = TweenService:Create(RightSide,Info,StartRightSideGoal)
local RightEndTween = TweenService:Create(RightSide,Info,EndRightSideGoal)

local InventoryController = {}

function InventoryController.Init(self: InventoryController)
	self._Initialized = true
	self.ShopOpened = false
	
	self:TrackInputs()
end

function InventoryController.TrackInputs(self: InventoryController)
	InputController.InputStarted:Connect(function(Input: Enum.KeyCode)
		if Input ~= Enum.KeyCode.F then return end
		if self.ShopOpened then self:CloseShop() return end
		
		self:OpenShop()
	end)
end

function InventoryController.CloseShop(self: InventoryController)
	self.ShopOpened = false

	RightStartTween:Play()
	ShopTextStartTween:Play()
	CameraController:ReturnCF(true,1)
	
	Background.Visible = false
	Player:SetAttribute("SpeedDecrease",1)
end

function InventoryController.OpenShop(self: InventoryController)
	self.ShopOpened = true
	
	Player:SetAttribute("SpeedDecrease",0)
	CameraController:LockCFrame(ShopCords,true,1)
	RightEndTween:Play()
	ShopTextEndTween:Play()
	
	Background.Visible = true
end

type InventoryController = typeof(InventoryController)&{
	_Initialized: boolean,
	ShopOpened: boolean
}

return InventoryController