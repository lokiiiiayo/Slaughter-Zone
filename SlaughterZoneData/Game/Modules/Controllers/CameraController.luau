local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local Camera = workspace.CurrentCamera

local CameraController = {}

function CameraController.Init(self: CameraController)
	self._Initialized = true
	self.FOV = 90
	self.CameraOffset = Vector3.new(0,0,0)
	self.LastCFrame = nil
	
	self.CframelockConn = nil
end

function CameraController.UpdateOffset(self: CameraController,NewOffset: Vector3)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	
	assert(Character and Humanoid,"Character or humanoid not found")
	
	if NewOffset then
		self.CameraOffset = NewOffset
	end
	
	for i = 1, 10 do
		local Goal = self.CameraOffset/Vector3.new(10,10,10)
		
		Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp(Goal,0.1)
	end
end

function CameraController.UpdateFOV(self: CameraController,NewFOV: number)	
	if NewFOV then
		self.FOV = NewFOV
	end
	
	Camera.FieldOfView = self.FOV
end

function CameraController.LockCFrame(self: CameraController,CF: CFrame,Smoothing: boolean,TotalTime: number)
	if not CF then warn("No cframe") return end
	
	self.LastCFrame = Camera.CFrame
	Camera.CameraType = Enum.CameraType.Scriptable
	
	
	local Info = TweenInfo.new(TotalTime,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)
	local Goal = {CFrame = CF}
	
	local Tween = TweenService:Create(Camera,Info,Goal)
	
	if Smoothing then
		Tween:Play()
	else
		Camera.CFrame = CF
	end
end

function CameraController.ReturnCF(self: CameraController,Smoothing: boolean,TotalTime: number)
	local Info = TweenInfo.new(TotalTime,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)
	local Goal = {CFrame = self.LastCFrame}

	local Tween = TweenService:Create(Camera,Info,Goal)
	
	if Smoothing then
		Tween:Play()
		Tween.Completed:Wait()
		Camera.CameraType = Enum.CameraType.Custom
	else
		Camera.CFrame = self.LastCFrame or CFrame.new(0,0,0)
		Camera.CameraType = Enum.CameraType.Custom
	end
end

function CameraController.LockCframeToObject(self: CameraController,Object: BasePart)
	if not Object then warn("Object to lock not found") return end
	
	if self.CframelockConn then
		self.CframelockConn:Disconnect()
	end
	self.LastCFrame = Camera.CFrame
	Camera.CameraType = Enum.CameraType.Scriptable
	
	self.CframelockConn = RunService.PreRender:Connect(function()
		Camera.CFrame = Object.CFrame
	end)
end

function CameraController.ReturnCameraToPlayer(self: CameraController)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local PrimaryPart = Character:WaitForChild("Humanoid") :: Humanoid
	
	assert(Character and PrimaryPart,"Character or primary part not found")
	
	
	if self.CframelockConn then
		self.CframelockConn:Disconnect()
	end
	
	Camera.CameraType = Enum.CameraType.Custom
	
	Camera.CameraSubject = PrimaryPart
end

function CameraController.ScreenShake(self: CameraController,Intensity: number,Duration: number)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	
	assert(Character and Humanoid,"Character or humanoid not found")
	assert(Intensity and Duration,"Paramaters not found")
	
	local Elapsed = 0
	
	RunService.RenderStepped:Connect(function(DT)
		Elapsed += DT
		
		if Elapsed > Duration then self:UpdateOffset() return end
		
		local NewIntensity = (Intensity*10)*DT
		
		
		local R1 = math.random(-NewIntensity,NewIntensity)
		local R2 = math.random(-NewIntensity,NewIntensity)
		
		Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp(Vector3.new(R1,R2,0),0.2)
	end)
end

function CameraController.GetLookVector(self: CameraController)
	return Camera.CFrame.LookVector
end




type CameraController = typeof(CameraController)&{
	_Initialized: boolean,
	FOV: number,
	CframelockConn: RBXScriptConnection,
	CameraOffset: Vector3,
	LastCFrame: CFrame
}

return CameraController :: CameraController