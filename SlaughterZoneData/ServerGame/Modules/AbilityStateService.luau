local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AbilityStateService = {}

function AbilityStateService.Init(self: AbilityStateService)
	self._Initialized = true
	self.PlayersAndStates = {}
end

function AbilityStateService.AddPlayerToMonitoring(self: AbilityStateService,Player: Player)
	if self.PlayersAndStates[Player] then return end
	
	self.PlayersAndStates[Player] = {}
end

function AbilityStateService.CleanPlayer(self: AbilityStateService,Player: Player)
	self.PlayersAndStates[Player] = {}
end

function AbilityStateService.AddState(self: AbilityStateService,Player: Player,Name: string,StateTemplate: {})
	self:AddPlayerToMonitoring(Player)
	
	self.PlayersAndStates[Player][Name] = StateTemplate
end

function AbilityStateService.SetState(self: AbilityStateService,Player: Player,Name: string, Key: string,Value: number?)
	self:AddPlayerToMonitoring(Player)
	
	if not self.PlayersAndStates[Player][Name] then warn(Name, "Not found")  return end
	
	self.PlayersAndStates[Player][Name][Key] = Value
end

function AbilityStateService.ReduceState(self: AbilityStateService,Player: Player,Name: string, Key: string,Value: number?)
	self:AddPlayerToMonitoring(Player)
	
	if not self.PlayersAndStates[Player][Name] then warn(Name, "Not found")  return end
	if not self.PlayersAndStates[Player][Name][Key] then warn(Key, "Not found")  return end
	
	self.PlayersAndStates[Player][Name][Key] -= Value
end

function AbilityStateService.AddToState(self: AbilityStateService,Player: Player,Name: string, Key: string,Value: number?)
	self:AddPlayerToMonitoring(Player)
	
	if not self.PlayersAndStates[Player][Name] then warn(Name, "Not found") return end
	if not self.PlayersAndStates[Player][Name][Key] then warn(Key, "Not found")  return end
	
	self.PlayersAndStates[Player][Name][Key] += Value
end

function AbilityStateService.GetStateWithKey(self: AbilityStateService,Player: Player,Name: string, Key: string)
	self:AddPlayerToMonitoring(Player)
	
	return self.PlayersAndStates[Player][Name][Key]
end

function AbilityStateService.GetState(self: AbilityStateService,Player: Player,Name: string)
	self:AddPlayerToMonitoring(Player)

	return self.PlayersAndStates[Player][Name]
end

type AbilityStateService = typeof(AbilityStateService)&{
	_Initialized: boolean,
	PlayersAndStates: {Player: {{}}}
}

return AbilityStateService :: AbilityStateService