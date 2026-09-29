local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnimationController = require(ReplicatedStorage.Game.Modules.Controllers.AnimationController)

local VfxReplicationPacket = require(ReplicatedStorage.Game.Packets.ClientReplication.VfxReplicationPacket)
--local AnimationReplicationPacket = require(ReplicatedStorage.Game.Packets.ClientReplication.AnimationReplicationPacket)

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VFX = Assets:WaitForChild("VFX")

local ReplicationController = {}

function ReplicationController.init(self: ReplicationController)
	self._initialized = true
	self.CachedVfx = {}
	
	self:Start()
end

function ReplicationController.Start(self: ReplicationController)
	self:Listen()
	
end

function ReplicationController.Listen(self: ReplicationController)
	VfxReplicationPacket.packets.ReplicateVfx.listen(function(Data)
		local VfxToPlay = VFX:FindFirstChild(Data.VfxName) :: Model
		
		if not VfxToPlay then warn(`No VFX found for {Data.VfxName}`) return end
		
		local NewVFX = VfxToPlay:Clone()
		
		NewVFX.Parent = workspace.Temporary
		
		NewVFX:PivotTo(Data.VfxCframe)
		
		if Data.VfxDuration then
			task.delay(Data.VfxDuration,function()
				NewVFX:Destroy()
			end)
		end
	end)
	
end

function ReplicationController.ReplicateVfx(self: ReplicationController,Data)
	
end

function ReplicationController.DestroyVfx(self: ReplicationController,Data)
	
end

function ReplicationController.ReplicateAnimation(self: ReplicationController,Data)
	
end



type ReplicationController = typeof(ReplicationController)&{
	_initialized: boolean,
	CachedVfx: {Instance}
}

return ReplicationController :: ReplicationController