local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Skins = ReplicatedStorage:WaitForChild("Game").Data.Skins

local AnimationController = require(ReplicatedStorage.Game.Modules.Controllers.AnimationController)
local StateController = require(ReplicatedStorage.Game.Modules.Controllers.StateController)
local AbilityController = require(ReplicatedStorage.Game.Modules.Controllers.AbilityController)
local HealthController = require(ReplicatedStorage.Game.Modules.Controllers.HealthController)

local StateMap = require(script.StateMap)

local Animations = ReplicatedStorage:WaitForChild("Game").Assets.Animations
local DefaultAnimations = ReplicatedStorage:WaitForChild("Game").Assets.Animations.Default

local CharacterController = {}

function CharacterController.Init(self: CharacterController)
	self._Initialized = true
	self.Character = Player.Character.Name or Player.CharacterAdded:Wait().Name
	self.CharacterSkin = nil
	
	self.State = "Normal"
	self.Injured = false
	
	self:Start()
	self:UpdateCharacter()
	self:UpdateAnimations()
	
	HealthController.Updated:Connect(function()
		if HealthController.BelowHalf then
			self.Injured = true
			self.State = "Injured"
		else
			self.State = "Normal"
			self.Injured = false
		end
		
		
		AnimationController:StopAllAnimations()
		self:UpdateAnimations()
	end)
end

function CharacterController.UpdateAnimations(self: CharacterController)
	if Animations:FindFirstChild(self.Character) then
		AnimationController:LoadAnimations(Animations:FindFirstChild(self.Character)[self.State]:GetDescendants())
	else
		AnimationController:LoadAnimations(DefaultAnimations[self.State]:GetDescendants())
	end
end

function CharacterController.Start(self: CharacterController)
	
	StateController.StateRemoving:Connect(function(State: string)
		AnimationController:StopAnimation(State)
	end)
	
	RunService.PreRender:Connect(function()
		self:UpdateStates()
	end)
	
	RunService.RenderStepped:Connect(function()
		StateController:AddStates(nil,"Idle")
		StateController:UpdateHighestState()
		
		AnimationController:PlayAnimation(StateController.CurrentState)
	end)
end

function CharacterController.GetCharacterInfo(self: CharacterController)
	
end

function CharacterController.UpdateCharacter(self: CharacterController)
	Player.CharacterAdded:Connect(function(Character)
		if Skins:FindFirstChild(Character.Name) then
			self.Character = Character.Name
		elseif Skins:FindFirstChild(Character.Name,true) then
			self.CharacterSkin = Character.Name
			self.Character = Skins:FindFirstChild(Character.Name,true).Parent.Name
		end
		self:UpdateAnimations()
		
		AbilityController:UpdateMoveset(self.Character)
		AbilityController:Start()
	end)
end

function CharacterController.UpdateStates(self: CharacterController)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	
	for _, State: Mapping in StateMap() do
		if Humanoid:GetState() ~= State.StateType or not State.Requirements() then
			
			for _, StateAdd in State.Add do
				StateController:RemoveStates(StateAdd.Name)
			end
			
			continue
		end
		
		for _, StateToAdd in State.Add do
			StateController:AddStates(StateToAdd.Duration,StateToAdd.Name)
		end
		
		for _, StateToRemove in State.Remove do
			StateController:RemoveStates(StateToRemove)
		end
		
		task.spawn(State.Effects)
	end
end

type Mapping = {
	Add: { {name: string, Duration: number} },
	Remove: {string},
	StateType: Enum.HumanoidStateType,
	Requirements: () -> (),
	Effects: () -> ()
}


type CharacterController = typeof(CharacterController)&{
	_Initialized: boolean,
	Character: Model,
	Injured: boolean,
	State: string,
	CharacterSkin: string
}

return CharacterController :: CharacterController