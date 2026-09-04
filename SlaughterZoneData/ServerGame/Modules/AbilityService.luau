local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CooldownService = require(ServerScriptService.Game.Modules.CooldownService)
local AbilityUsagePacket = require(ReplicatedStorage.Game.Packets.UseAbility)
local EffectService = require(ServerScriptService.Game.Modules.EffectService)

local AbilityService = {}

function AbilityService.Init(self: AbilityService)
	self._Initialized = true
	self.PlayersAndCharges = {}
	
	self:ListenForAbilityUsages()
end

function AbilityService.ListenForAbilityUsages(self: AbilityService)
	
	AbilityUsagePacket.Send.listen(function(Data,Player: Player?)
		if self:UseAbility(Data.AbilityName,Player) then
			print("Used", Data.AbilityName)
		end
	end)
end

function AbilityService.UseAbility(self: AbilityService,AbilityName: string,Player: Player)
	if not AbilityName then warn("No ability name") return end
	if CooldownService:IsPlayerOnCooldown(Player,AbilityName) then warn("Player on cooldown") return end
	if EffectService:PlayerHasEffect(Player,"Stunned") then print(EffectService.PlayersAndEffects[Player]) warn("Player is stunned") return end
	
	local AbilityData = ReplicatedStorage.Game.Data.Abilities:FindFirstChild(AbilityName,true)
	local AbilityModule = ReplicatedStorage.Game.Modules.Characters:FindFirstChild(AbilityName,true)
	
	assert(AbilityData and AbilityModule,"Ability module/data not found")
	
	AbilityModule = require(AbilityModule)
	AbilityData = require(AbilityData)
	
	local AbilityUsed = false
	
	if AbilityModule(Player) then
		CooldownService:SetPlayerCooldown(Player,AbilityName,AbilityData.Cooldown)
		AbilityUsed = true
	end
	
	return AbilityUsed
end


type AbilityService = typeof(AbilityService)&{
	_Initialized: boolean,
	PlayersAndCharges: {Player: number}
}

return AbilityService :: AbilityService