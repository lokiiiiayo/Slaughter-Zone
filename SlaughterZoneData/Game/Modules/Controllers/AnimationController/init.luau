local ReplicatedStrorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local AnimationFolder = ReplicatedStrorage:WaitForChild("Game").Assets.Animations:GetDescendants()
local LoopedAnimations = require(script.LoopedAnimations)
local AnimationPriorities = require(ReplicatedStrorage:WaitForChild("Game").Modules.Controllers.StateController.StatePriority)

local MovementController = require(ReplicatedStrorage.Game.Modules.Controllers.MovementController)

local FadeTime = 0.3

local AnimationController = {}

function AnimationController.Init(self: AnimationController)
	self._Initialized = true
	self.AnimationPlaying = {}
	self.AnimationsCached = {}
	self.AnimationsLoaded = {}
	
	self:CacheAnimations()
	self:ReplaceAnimate()
	
	Player.CharacterAdded:Connect(function()
		self:CacheAnimations()
		self:ReplaceAnimate()
	end)
	
	self:UpdateSpeed()
end

local function updateAnimationSpeed()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid

	assert(Character and Humanoid,"Assets not found")

	local speed = Humanoid.RootPart.AssemblyLinearVelocity.Magnitude
	
	local normalizedSpeed = math.max(speed / 24, 0)
	
	if MovementController:IsSprinting() then
		normalizedSpeed = math.max(speed / MovementController.SprintSpeed, 0)
	else
		normalizedSpeed = math.max(speed / MovementController.WalkSpeed, 0)
	end
	
	
	return normalizedSpeed
end

function AnimationController.UpdateSpeed(self: AnimationController)
	RunService.RenderStepped:Connect(function(DT)
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
		
		if Humanoid.MoveDirection.Magnitude > 0 then
			for _, AnimationTrack in self.AnimationPlaying do
				AnimationTrack:AdjustSpeed(updateAnimationSpeed())
			end
		end
	end)
end

function AnimationController.ReplaceAnimate(self: AnimationController)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	
	local AnimateScript = Character:FindFirstChild("Animate") :: LocalScript
	
	local NewAnimate = Instance.new("StringValue")

	NewAnimate.Parent = Character
	NewAnimate.Name = "Animate"
	
	if AnimateScript then
		AnimateScript:Destroy()
	end
end

function AnimationController.CacheAnimations(self: AnimationController)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Animator = Humanoid:FindFirstChild("Animator") :: Animator
	
	for _, Animation: Animation in AnimationFolder do
		if not Animation:IsA("Animation") then continue end
		
		local LoadedAnimation = Animator:LoadAnimation(Animation)
		
		self.AnimationsCached[Animation.Name] = LoadedAnimation
	end
end

function AnimationController.LoadAnimations(self: AnimationController,Anims: {Animation})
	self:ClearAllLoadedAnimations()
	
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local Animator = Humanoid:FindFirstChild("Animator") :: Animator
	
	for _, Animation: Animation in Anims do
		if not Animation:IsA("Animation") then warn("Can't put non animations in the table") continue end
		
		local LoadedAnimation = Animator:LoadAnimation(Animation)
		
		self.AnimationsLoaded[Animation.Name] = LoadedAnimation
		self.AnimationsCached[Animation.Name] = LoadedAnimation
	end
end

function AnimationController.PlayAnimation(self: AnimationController,AnimationName: string,Priority: number,Action: boolean)
	if not self.AnimationsCached[AnimationName] then return end
	if self.AnimationPlaying[AnimationName] then return end
	
	local Animation: AnimationTrack
	
	if Action then
		Animation = self.AnimationsCached[AnimationName]
	else
		Animation = self.AnimationsLoaded[AnimationName]
	end
	
	local Looped = false
	
	if LoopedAnimations[AnimationName] then Looped = true end
	if not AnimationPriorities[AnimationName] then Priority = 4 end
	
	self:StopAllAnimations(AnimationName)
	
	self.AnimationPlaying[AnimationName] = Animation
	
	if Priority then
		Animation.Looped = Looped
		Animation:Play(FadeTime,Priority)
	else
		Animation.Looped = true
		Animation:Play(FadeTime,AnimationPriorities[AnimationName] or 1)
	end
	
	local conn
	
	conn = Animation.Ended:Connect(function()
		conn:Disconnect()
		self.AnimationPlaying[AnimationName] = nil
	end)
end

function AnimationController.StopAnimation(self:AnimationController, AnimationName: string)
	if not self.AnimationPlaying[AnimationName] then return end
	
	self.AnimationPlaying[AnimationName]:Stop(FadeTime)
	self.AnimationPlaying[AnimationName] = nil
end

function AnimationController.StopAllAnimations(self: AnimationController,Exception: string)
	for Name, Animation: AnimationTrack in self.AnimationsLoaded do
		if Name == Exception then continue end
		
		Animation:Stop(FadeTime)
		self.AnimationPlaying[Name] = nil
	end
end

function AnimationController.AdjustSpeed(self: AnimationController,AnimationName: string,NewSpeed: number)
	local SelectedAnimation = self.AnimationPlaying[AnimationName]
	
	if not SelectedAnimation then return end
	
	SelectedAnimation:AdjustSpeed(NewSpeed)
end

function AnimationController.AdjustWeight(self: AnimationController,AnimationName: string,NewWeight: number)
	local SelectedAnimation = self.AnimationPlaying[AnimationName]

	if not SelectedAnimation then return end

	SelectedAnimation:AdjustWeight(NewWeight)
end

function AnimationController.ClearAllLoadedAnimations(self: AnimationController)
	for Name, LoadedAnimation in self.AnimationsLoaded do
		LoadedAnimation = nil
		self.AnimationPlaying[Name] = nil
	end
end

type AnimationController = typeof(AnimationController)&{
	_Initialized: boolean,
	AnimationPlaying: {AnimationTrack},
	AnimationsCached: {AnimationTrack},
	AnimationsLoaded: {AnimationTrack}
}

return AnimationController :: AnimationController