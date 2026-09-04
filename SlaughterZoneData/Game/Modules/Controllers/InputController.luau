local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Packages").Signal)

local InputController = {}

function InputController.Init(self: InputController)
	
	self._Initialized = true
	self.Types = {}
	self.KeysHolding = {}
	
	self.InputStarted = Signal()
	self.InputEnded = Signal()
	

	
	self:TrackInputs()
end

function InputController.TrackInputs(self: InputController)
	UserInputService.InputBegan:Connect(function(Input,GPE)
		if GPE then return end
		
		
		self.InputStarted:Fire(Input.KeyCode)
		self.InputStarted:Fire(Input.UserInputType)
		
		if Input.KeyCode then
			self.KeysHolding[Input.KeyCode] = Input.KeyCode
		end
		
		if Input.UserInputType then
			self.Types[Input.UserInputType] = Input.UserInputType
		end
	end)
	
	UserInputService.InputEnded:Connect(function(Input,GPE)
		if GPE then return end
		
		self.InputEnded:Fire(Input.KeyCode)
		self.InputEnded:Fire(Input.UserInputType)

		if Input.KeyCode and self.KeysHolding[Input.KeyCode] then
			self.KeysHolding[Input.KeyCode] = nil
		end
		
		if Input.UserInputType and self.Types[Input.UserInputType] then
			self.Types[Input.UserInputType] = nil
		end
	end)
end

function InputController.LockMouse(self: InputController,MouseLocked: boolean)
	if MouseLocked then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	else
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end

function InputController.IsHoldingKey(self: InputController,Input: Enum.KeyCode)
	return self.KeysHolding[Input]
end

function InputController.IsHoldingType(self: InputController,InputType: Enum.UserInputType)
	return self.Types[InputType]
end

type InputController = typeof(InputController)&{
	_Initialized: boolean,
	KeysHolding: {Enum.KeyCode},
	Types: {Enum.UserInputType},
	InputStarted: BindableEvent,
	InputEnded: BindableEvent
}

return InputController :: InputController