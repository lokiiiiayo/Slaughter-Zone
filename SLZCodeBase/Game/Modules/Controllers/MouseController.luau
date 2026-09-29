local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local InputController = require(ReplicatedStorage.Game.Modules.Controllers.InputController)
local MovementController = require(ReplicatedStorage.Game.Modules.Controllers.MovementController)

local MouseButton = ReplicatedStorage:WaitForChild("Game").Data.Keybinds.UI.Mouse

local Player = Players.LocalPlayer

local Mouse = Player:GetMouse()

local MouseController = {}

function MouseController.Init(self: MouseController)
	self._Initialized = true
	self.MouseState = "Hover"
	
	self.MouseTypes = {
		["Idle"] = "rbxassetid://97498505651755",
		["Hover"] = "rbxassetid://91059395986466",
		["Click"] = "rbxassetid://108674909666986",
		["Shiftlock"] = "rbxassetid://75450593905090"
	}
	
	self:MonitorMouse()
end

function MouseController.MonitorMouse(self: MouseController)
	MouseButton.Pressed:Connect(function()
		self.MouseState = "Click"
	end)
	
	MouseButton.Released:Connect(function()
		self.MouseState = "Idle"
	end)
	
	RunService.RenderStepped:Connect(function(DT)
		if MovementController.Shiftlocked == true then self.MouseState = "Shiftlock" elseif self.MouseState == "Shiftlock" then self.MouseState = "Idle" end
		
		self:ChangeMouseTo(self.MouseState)
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