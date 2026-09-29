local Bytenet = require(game.ReplicatedStorage.Packages.ByteNetMax)

return Bytenet.defineNamespace("VfxReplicationPacket",function()
	return {
		packets = {
			ReplicateVfx = Bytenet.definePacket({
				value = Bytenet.struct({
					VfxCframe = Bytenet.cframe,
					VfxName = Bytenet.string,
					VfxDuration = Bytenet.int32
				})
			}),
			DestroyVfx = Bytenet.definePacket({
				value = Bytenet.struct({
					VfxName = Bytenet.string,
					TimeToDestroy = Bytenet.optional(Bytenet.int32)
				})
			}),
		},
		queries = {
			
		},
	}
end)