local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maps = ReplicatedStorage.Game.Assets.Maps

local DefaultCF = CFrame.new(1000,1000,1000)

local MapService = {}

function MapService.Init(self: MapService)
	
	if not workspace:FindFirstChild("CurrentMap") then
		local NewFolder = Instance.new("Folder")
		NewFolder.Parent = workspace
		NewFolder.Name = "CurrentMap"
	end
	
	self._Initialized = true
	self.CurrentLoadedMap = nil
	self.GlobalMapParent = workspace:FindFirstChild("CurrentMap")
end

function MapService.DestroyAllLoadedMaps(self: MapService)
	for _, Map: Model in self.GlobalMapParent:GetChildren() do
		Map:Destroy()
	end
end

function MapService.LoadMap(self: MapService,MapName: string)
	if not Maps:FindFirstChild(MapName) then warn("Map not found for", MapName) return end
	
	local MapClone = Maps:FindFirstChild(MapName):Clone() :: Model
	MapClone.Parent = self.GlobalMapParent
	
	if not MapClone.PrimaryPart then warn("Map primarypart not found for", MapClone.Name) return end
	
	MapClone:PivotTo(DefaultCF)
	
	self.CurrentLoadedMap = MapClone
	
	return MapClone
end

function MapService.LoadRandomMap(self: MapService)
	local ChosenMap = Maps:GetChildren()[math.random(1,#Maps:GetChildren())]
	if not ChosenMap then warn("Random map not found") return end

	local MapClone = ChosenMap:Clone()
	MapClone.Parent = self.GlobalMapParent

	if not MapClone.PrimaryPart then warn("Map primarypart not found for", MapClone.Name) return end

	MapClone:PivotTo(DefaultCF)
	
	self.CurrentLoadedMap = MapClone
	
	return MapClone
end

function MapService.SelectRandomMap(self: MapService)
	local ChosenMap = Maps:GetChildren()[math.random(1,#Maps:GetChildren())]
	if not ChosenMap then warn("Random map not found") return end
	
	return ChosenMap
end

function MapService.TeleportPlayersToMap(self: MapService,PlayerRange: {Player})
	for _, Player in PlayerRange do
		for _, MapTP: BasePart in self.CurrentLoadedMap.Spawns:GetChildren() do
			if Player.Character:GetAttribute(MapTP.Name) then
				local Character = Player.Character :: Model
				
				local ChosenSpawn = MapTP:GetChildren()[math.random(1,#MapTP:GetChildren())]
				
				Character:PivotTo(ChosenSpawn.CFrame)
			end
		end
	end
end


type MapService = typeof(MapService)&{
	_Initialized: boolean,
	CurrentLoadedMap: Model,
	GlobalMapParent: Folder
}

return MapService :: MapService