local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local InputController = require(ReplicatedStorage.Game.Modules.Controllers.InputController)
local CameraController = require(ReplicatedStorage.Game.Modules.Controllers.CameraController)

local Player = Players.LocalPlayer

local MovementKeybind = Enum.KeyCode.LeftShift
local ShiftlockKeybind = Enum.KeyCode.LeftControl

local TILT_SIZE = 150
local CamOffset = Vector3.new(0.5,0,0)

local MovementController = {}

function MovementController.Init(self: MovementController)
	self._Initialized = true
	self.Sprinting = false
	self.ShiftlockLOCKED = false
	self.Shiftlocked = false
	self.ShiftlockSmoothing = 0.4
	self.CurrentStamina = 100
	self.MaxStamina = 100
	self.StaminaDrainRate = 10
	self.StaminaRecoverRate = 15
	self.RecoverTime = 1.5
	self.RecoverTimeAny = 1
	self.SprintSpeed = 24
	self.WalkSpeed = 12
	
	RunService.RenderStepped:Connect(function()
		if InputController:IsHoldingKey(MovementKeybind) and self:IsMoving() and self.CurrentStamina > 0 then
			self.Sprinting = true
		else
			self.Sprinting = false
		end
	end)
	
	InputController.InputStarted:Connect(function(Input: Enum.KeyCode)
		if Input ~= ShiftlockKeybind then return end
		
		self.Shiftlocked = not self.Shiftlocked
		
		self:Shiftlock()
	end)
	
	self:StartSprintLoop()
	self:TiltEffect()
end

function MovementController.IsMoving(self: MovementController)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	local HRP = Character:FindFirstChild("HumanoidRootPart") :: BasePart
	
	if not Character and Humanoid then return end
	
	if Humanoid.MoveDirection.Magnitude > 0 and HRP.AssemblyLinearVelocity.Magnitude > 0 and Humanoid.WalkSpeed > 0 then
		return true
	else
		return false
	end
end

function MovementController.StartSprintLoop(self: MovementController)
	local function Regen(DT)
		if self.CurrentStamina < self.MaxStamina then
			self.CurrentStamina += (self.StaminaRecoverRate * DT)
		end
	end
	
	local function Recovering()
		if self.CurrentStamina <= 0 then
			return true
		else
			return false
		end
	end
	
	local Elapsed = 0
	
	RunService.PreRender:Connect(function(DeltaTime)
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
		
		assert(Character and Humanoid,"Character or humanoid not found")
		
		local SpeedIncrease = Player:GetAttribute("SpeedIncrease") or 1
		local SpeedDecrease = Player:GetAttribute("SpeedDecrease") or 1
		
		if not self.Sprinting then
			Humanoid.WalkSpeed = self.WalkSpeed*SpeedIncrease*SpeedDecrease
			
			if Recovering() then
				Elapsed += DeltaTime
				if Elapsed >= self.RecoverTime then
					Regen(DeltaTime)
					Elapsed = 0
				end
			else
				Elapsed += DeltaTime
				
				if Elapsed >= self.RecoverTimeAny then
					Regen(DeltaTime)
				end
			end
			
			return
		end
		
		if self.CurrentStamina > 0 then
			Humanoid.WalkSpeed = self.SprintSpeed*SpeedIncrease*SpeedDecrease
			
			self.CurrentStamina -= (self.StaminaDrainRate * DeltaTime)
			Elapsed = 0
		else
			Humanoid.WalkSpeed = self.WalkSpeed*SpeedIncrease*SpeedDecrease
		end
	end)
end

function MovementController.IsSprinting(self: MovementController)
	return self.Sprinting
end

function MovementController.Shiftlock(self: MovementController,Value: boolean)
	if self.ShiftlockLOCKED then return end
	
	if Value then
		self.Shiftlocked = Value
	end
	
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local HRP = Character:WaitForChild("HumanoidRootPart") :: BasePart
	
	local function Lock()
		local Lookvector = CameraController:GetLookVector()
		local OriginalPOS = HRP.Position
		local FlatPos = Vector3.new(Lookvector.X,0,Lookvector.Z).Unit
		local TargCF = CFrame.new(HRP.Position,HRP.Position + FlatPos)

		HRP.CFrame = HRP.CFrame:Lerp(TargCF,self.ShiftlockSmoothing)
	end

	if self.Shiftlocked then
		print("locked")
		CameraController:UpdateOffset(CamOffset)
		RunService:BindToRenderStep("Shiftlock",200,Lock)

		InputController:LockMouse(true)
	else
		print("Unlocked")
		CameraController:UpdateOffset(Vector3.new(0,0,0))
		RunService:UnbindFromRenderStep("Shiftlock")
		InputController:LockMouse(false)
	end

	Humanoid.AutoRotate = not self.Shiftlocked
end

function MovementController.LOCKSHIFTLOCK(self: MovementController,Locked: boolean)
	self.ShiftlockLOCKED = Locked
	self.Shiftlocked = Locked
	self:Shiftlock()
end

function MovementController.TiltEffect(self: MovementController)
	local Angle1 = 0
	local Angle2 = 0
	local Direction
	local Velocity
	
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: BasePart
	local RootJoint = HumanoidRootPart:WaitForChild("RootJoint") :: Motor6D
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

	local ORIGINAL_C0
	ORIGINAL_C0 = RootJoint.C0
	
	
	RunService.RenderStepped:Connect(function()
 		Character = Player.Character or Player.CharacterAdded:Wait()
		HumanoidRootPart = Character:WaitForChild("HumanoidRootPart",1)
		RootJoint = HumanoidRootPart:WaitForChild("RootJoint",1)
		Humanoid = Character:WaitForChild("Humanoid",1) :: Humanoid

		if Humanoid.Health > 0 then
			Velocity = HumanoidRootPart.Velocity * Vector3.new(1, 0, 1)

			if Velocity.Magnitude > 2 then
				Direction = Velocity.Unit

				Angle1 = HumanoidRootPart.CFrame.LookVector:Dot(Direction) / (1000 / TILT_SIZE)
				Angle2 = HumanoidRootPart.CFrame.RightVector:Dot(Direction) / (1000 / TILT_SIZE)
			else
				-- Resets the angles because player is moving too slow

				Angle1 = 0
				Angle2 = 0
			end

			local TiltGoal = {C0 = ORIGINAL_C0 * CFrame.Angles(Angle1, -Angle2, 0)}
			local TiltTween = TweenService:Create(RootJoint, TweenInfo.new(0.2), TiltGoal)

			TiltTween:Play()
		end
	end)
end

type MovementController = typeof(MovementController)&{
	_Initialized: boolean,
	Sprinting: boolean,
	ShiftlockLOCKED: boolean,
	Shiftlocked: boolean,
	ShiftlockSmoothing: number,
	MaxStamina: number,
	CurrentStamina: number,
	StaminaRecoverRate: number,
	StaminaDrainRate: number,
	RecoverTime: number,
	SprintSpeed: number,
	WalkSpeed: number,
	RecoverTimeAny: number
}

return MovementController :: MovementController