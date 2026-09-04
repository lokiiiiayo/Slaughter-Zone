local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local EffectClass = require(ServerScriptService.Game.Modules.EffectClass)

local EffectService = {}

function EffectService.Init(self: EffectService)
	
	self._Initialized = true
	self.PlayersAndEffects = {}
end



function EffectService.AddPlayerToMonitoring(self: EffectService,Player: Player)
	if self.PlayersAndEffects[Player] then return end
	
	self.PlayersAndEffects[Player] = {}
end

function EffectService.AddEffectToPlayer(self: EffectService,Player: Player,Effect: string,Duration: number,Level: number)
	self:AddPlayerToMonitoring(Player)
	
	local NewEffect = EffectClass.New({
		PlayerEffected = Player,
		Duration = Duration,
		Name = Effect,
		Level = Level
	})
	
	self.PlayersAndEffects[Player][Effect] = NewEffect
	
	local conn
	
	conn = NewEffect.EffectedEnded:Connect(function()
		self:RemoveEffectFromPlayer(Player,Effect)
		conn:Disconnect()
	end)
end

function EffectService.RemoveEffectFromPlayer(self: EffectService,Player: Player,Effect: string)
	self:AddPlayerToMonitoring(Player)
	if not self.PlayersAndEffects[Player][Effect] then return end
	
	
	self.PlayersAndEffects[Player][Effect]:Destroy()
	self.PlayersAndEffects[Player][Effect] = nil
end

function EffectService.PlayerHasEffect(self: EffectService,Player: Player,Effect: string)
	self:AddPlayerToMonitoring(Player)
	if not self.PlayersAndEffects[Player][Effect] then return false end 
	
	return self.PlayersAndEffects[Player][Effect]
end


type EffectService = typeof(EffectService)&{
	_Initialized: boolean,
	PlayersAndEffects: {Player: {string: {string}}},
	
}

return EffectService :: EffectService