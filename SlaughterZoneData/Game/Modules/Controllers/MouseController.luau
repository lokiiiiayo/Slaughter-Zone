local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local InputController = require(ReplicatedStorage.Game.Modules.Controllers.InputController)
local MovementController = require(ReplicatedStorage.Game.Modules.Controllers.MovementController)

local Player = Players.LocalPlayer

local Mouse = Player:GetMouse()

local MouseController = {}

function MouseController.Init(self: MouseController)
	self._Initialized = true
	self.MouseState = "Hover"
	
	self.MouseTypes = {
		["Hover"] = "http://www.roblox.com/asset/?id=7767269282",
		["Click"] = "rbxassetid://12649628367",
		["Shiftlock"] = "http://www.roblox.com/asset/?id=94938365473619"
	}
	
	self:MonitorMouse()
end

function MouseController.MonitorMouse(self: MouseController)
	RunService.RenderStepped:Connect(function(DT)
		if MovementController.Shiftlocked == true then self:ChangeMouseTo("Shiftlock") return end
		if InputController:IsHoldingType(Enum.UserInputType.MouseButton1) then self:ChangeMouseTo("Click") return end
		
		self:ChangeMouseTo("Hover")
	end)
end

function MouseController.ChangeMouseTo(self: MouseController,MouseType: string)
	if not self.MouseTypes[MouseType] then return end
	
	Mouse.Icon = self.MouseTypes[MouseType]
end


type MouseController = typeof(MouseController)&{
	_Initialized: boolean,
	MouseState: string,
	MouseTypes: {string: string}
}

return MouseController :: MouseController