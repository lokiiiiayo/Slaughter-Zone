local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local DamageService = {}

function DamageService.Init(self: DamageService)
	self._Initialized = true
	self.PlayerDied = Signal()
	
end

function DamageService.DamagePlayer(self: DamageService,Player: Player,Damage: number,Lethal: boolean)
	self:DamageCharacter(Player.Character,Damage,Lethal)
end

function DamageService.DamageCharacter(self: DamageService,Character: Model,Damage: number,Lethal: boolean,PlayerDamaging: Player)
	if not Character then return end
	
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid

	local CurrentHealth = Humanoid.Health
	
	if not Lethal then
		Lethal = true
	end
	
	if PlayerDamaging then
		Character:SetAttribute("LastDamaged",PlayerDamaging.Name)
	end
	
	if (CurrentHealth - Damage) <= 0 then
		if Lethal then Humanoid:TakeDamage(Damage) self.PlayerDied:Fire(Character) return true end
		Humanoid.Health = 1
		
		return false
	else
		Humanoid:TakeDamage(Damage)
		
		return false
	end
end


type DamageService = typeof(DamageService)&{
	_Initialized: boolean,
	PlayerDied: BindableEvent
}

return DamageService :: DamageService