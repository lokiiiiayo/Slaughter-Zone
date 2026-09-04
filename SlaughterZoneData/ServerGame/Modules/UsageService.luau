local UsageService = {}

function UsageService.Init(self: UsageService)
	self._Initialized = true
	self.PlayersAndUsage = {}
	
end

function UsageService.SetupForPlayer(self: UsageService,Player: Player)
	if self.PlayersAndUsage[Player] then return end
	
	self.PlayersAndUsage[Player] = {}
end

function UsageService.GetUsages(self: UsageService,Player: Player,Ability: string)
	self:SetupForPlayer(Player)
	
	if not self.PlayersAndUsage[Player][Ability] then return false end
	
	return self.PlayersAndUsage[Player][Ability].CurrentUses
end

function UsageService.AddUsageLimit(self: UsageService,Player: Player,Ability: string,MaxUses: number,CurrentUses: number)
	self:SetupForPlayer(Player)
	
	self.PlayersAndUsage[Player][Ability] = {MaxUses = MaxUses,CurrentUses = CurrentUses}
end

function UsageService.AddUsageToAbility(self: UsageService,Player: Player,Ability: string)
	self:SetupForPlayer(Player)
	local MaxUses = self.PlayersAndUsage[Player][Ability].MaxUses
	
	if self.PlayersAndUsage[Player][Ability].CurrentUses >= MaxUses then return end
	
	self.PlayersAndUsage[Player][Ability].CurrentUses += 1
end

function UsageService.CanUseAbility(self: UsageService,Player: Player,Ability: string)
	local MaxUses = self.PlayersAndUsage[Player][Ability].MaxUses

	if self.PlayersAndUsage[Player][Ability].CurrentUses >= MaxUses then return false end
	
	return true
end

function UsageService.AddToMaxUsages(self: UsageService,Player: Player,Ability: string,AmountToAdd: number)
	self:SetupForPlayer(Player)

	
	self.PlayersAndUsage[Player][Ability].MaxUses += 1
end

function UsageService.GetMaxUsage(self: UsageService,Player: Player,Ability: string)
	self:SetupForPlayer(Player)


	return self.PlayersAndUsage[Player][Ability].MaxUses
end

function UsageService.CleanPlayer(self: UsageService,Player: Player)
	self.PlayersAndUsage[Player] = nil
end


type UsageService = typeof(UsageService)&{
	_Initialized: boolean,
	PlayersAndUsage: {Player: {string: {string: number}}}
}

return UsageService :: UsageService