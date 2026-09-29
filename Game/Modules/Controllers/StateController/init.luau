local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local StateProrities = require(script.StatePriority)

local StateController = {}

function StateController.Init(self: StateController)
	
	self._Initialized = true
	self.CurrentState = "Idle"
	self.LastState = nil
	self.States = {}
	
	self.StateAdded = Signal()
	self.StateRemoving = Signal()
	self.StateUpdated = Signal()
end


function StateController.AddStates(self: StateController,Duration: number,...)
	for _, State in {...} do
		if self.States[State] then continue end
		
		self.States[State] = State
		self.StateAdded:Fire(State)
		
		if Duration then
			task.delay(Duration,function()
				self:RemoveStates(State)
			end)
		end
	end
end

function StateController.RemoveStates(self: StateController,...)
	for _, State in {...} do
		if not self.States[State] then continue end
		
		self.States[State] = nil
		self.StateRemoving:Fire(State)
	end
end

function StateController.UpdateHighestState(self: StateController)
	local HighestStateNum = -math.huge
	
	for _, State in self.States do
		if not StateProrities[State] then warn("State priority not found") continue end
		if StateProrities[State] < HighestStateNum then continue end
		
		HighestStateNum = StateProrities[State]
		self.CurrentState = State
	end
	
	
	if self.CurrentState ~= self.LastState then
		self.LastState = self.CurrentState
		self.StateUpdated:Fire()
	end
end



type StateController = typeof(StateController)&{
	_Initialized: boolean,
	CurrentState: string,
	LastState: string,
	States: {string},
	StateAdded: BindableEvent,
	StateRemoving: BindableEvent,
	StateUpdated: BindableEvent
}

return StateController :: StateController