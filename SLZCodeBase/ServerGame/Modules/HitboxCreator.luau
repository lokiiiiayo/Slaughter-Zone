local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)

local HitboxCreator = {}

HitboxCreator.__index = HitboxCreator

function HitboxCreator.New(TableOfContents: HitboxGroup)
	local NewHitbox = setmetatable({},HitboxCreator) :: HitboxGroup
	
	NewHitbox.HitboxTouched = Signal()
	NewHitbox.HitboxCount = TableOfContents.HitboxCount or 1
	NewHitbox.MaxPlayersHit = TableOfContents.MaxPlayersHit or 1
	NewHitbox.HitboxDuration = TableOfContents.HitboxDuration or 1
	NewHitbox.ObjectFollowing = TableOfContents.ObjectFollowing or nil
	NewHitbox.HitboxSize = TableOfContents.HitboxSize or Vector3.new(2,6,2)
	NewHitbox.Offset = TableOfContents.Offset or CFrame.new(0,0,0)
	NewHitbox.TimeBetweenHitboxes = TableOfContents.TimeBetweenHitboxes or 0.07
	NewHitbox.HitboxLifeTime = TableOfContents.HitboxLifeTime or 5
	NewHitbox.HitPlayers = {}
	NewHitbox.FilterList = TableOfContents.FilterList or {NewHitbox.ObjectFollowing}
	NewHitbox.Connections = {}
	return NewHitbox :: HitboxGroup
end

function HitboxCreator.Activate(self: HitboxGroup)
	task.spawn(function()
		for Count = 1, self.HitboxCount do
			local conn = self:CheckHitboxForPlayers(self.ObjectFollowing.CFrame * self.Offset)
			task.wait(self.TimeBetweenHitboxes)
			conn:Disconnect()
		end
	end)
	
	task.delay(self.HitboxDuration,function()
		self:Destroy()
	end)
end

function HitboxCreator.Destroy(self: HitboxGroup)
	for _, Conn in self.Connections do
		Conn:Disconnect()
	end
end

function HitboxCreator.CheckHitboxForPlayers(self: HitboxGroup,CF: CFrame)
	local HitPlayers = {}
	
	local Hitconn
	
	Hitconn = RunService.Heartbeat:Connect(function()
		local OverlapParams = OverlapParams.new()
		OverlapParams.FilterType = Enum.RaycastFilterType.Exclude
		OverlapParams.FilterDescendantsInstances = {
			self.FilterList
		}
		local PartsInHitbox = workspace:GetPartBoundsInBox(CF,self.HitboxSize)
		
		for _, Part: BasePart in PartsInHitbox do
			if not Part then continue end
			if not Part.Parent:FindFirstChild("Humanoid") then continue end
			if self.ObjectFollowing.Parent == Part.Parent then continue end
			if self.HitPlayers[Part.Parent] then continue end
			
			print("Hit", Part.Parent)
			self.HitboxTouched:Fire(Part.Parent)
			self.HitPlayers[Part.Parent] = Part.Parent
		end
	end)
	
	table.insert(self.Connections,Hitconn)
	return Hitconn
end

function HitboxCreator.GetHitCount(self: HitboxGroup)
	local CurrentCount = 0
	
	for _, Character: Model in self.HitPlayers do
		CurrentCount += 1
	end
	
	return CurrentCount
end

type HitboxGroup = typeof(HitboxCreator)&{
	ObjectFollowing: BasePart,
	HitboxSize: number,
	HitboxTouched: BindableEvent,
	HitboxCount: number,
	MaxPlayersHit: number,
	HitboxDuration: number,
	Offset: CFrame,
	TimeBetweenHitboxes: number,
	HitboxLifeTime: number,
	HitPlayers: {Player},
	FilterList: {Instance},
	Connections: {RBXScriptConnection},
}


type HitboxCreator = typeof(HitboxCreator)&{
	_Initialized: boolean
}

return HitboxCreator :: HitboxCreator