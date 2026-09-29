local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)
local EffectsFolder = ReplicatedStorage.Game.Modules.Effects

local EffectClass = {}

EffectClass.__index = EffectClass

function EffectClass.New(TableOfContents: Effect)
	local NewEffect = setmetatable({},EffectClass) :: Effect
	
	NewEffect.Level = TableOfContents.Level or 1
	NewEffect.Name = TableOfContents.Name or "Burning"
	NewEffect.PlayerEffected = TableOfContents.PlayerEffected or nil
	NewEffect.Duration = TableOfContents.Duration or 5
	NewEffect.EffectedEnded = Signal()
	NewEffect.Connections = {}
	
	if EffectsFolder:FindFirstChild(NewEffect.Name) then
		local ChosenModule = require(EffectsFolder:FindFirstChild(NewEffect.Name))
		
		table.insert(NewEffect.Connections,ChosenModule(NewEffect))
	end
	
	task.delay(NewEffect.Duration, function()
		NewEffect.EffectedEnded:Fire()
	end)
	
	return NewEffect
end

function EffectClass.Destroy(self: Effect)
	self.EffectedEnded:Fire()
	
	for _, conn in self.Connections do
		conn:Disconnect()
	end
	
	self = nil
end


type Effect = typeof(EffectClass)&{
	Level: number,
	Name: string,
	PlayerEffected: Player,
	Duration: number,
	EffectedEnded: BindableEvent,
	Connections: {RBXScriptConnection},
}

type EffectClass = typeof(EffectClass)

return EffectClass :: EffectClass