local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local Player = Players.LocalPlayer

local HealthService = {}

function HealthService.Init(self: HealthService)
	self._Initialized = true
	self.BelowHalf = false
	self.Updated = Signal()
	
	RunService.RenderStepped:Connect(function(DT)
		self:UpdateStatus()
	end)
end

function HealthService.UpdateStatus(self: HealthService)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	
	if Humanoid.Health < Humanoid.MaxHealth/2 then
		if not self.BelowHalf then
			self.BelowHalf = true
			self.Updated:Fire()
		end
	else
		if self.BelowHalf then
			self.BelowHalf = false
			self.Updated:Fire()
		end
	end
end


type HealthService = typeof(HealthService)&{
	_Initialized: boolean,
	BelowHalf: boolean,
	Updated: BindableEvent
	
}

return HealthService :: HealthService