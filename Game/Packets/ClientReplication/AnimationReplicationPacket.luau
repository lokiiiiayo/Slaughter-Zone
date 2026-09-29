local Bytenet = require(game.ReplicatedStorage.Packages.ByteNetMax)

return Bytenet.defineNamespace("AnimationReplicationPacket",function()
	return {
		packets = {
			PlayAnimation = Bytenet.definePacket({
				value = Bytenet.struct({
					AnimationName = Bytenet.string,
					PlayerName = Bytenet.string,
				})
			}),
			StopAnimation = Bytenet.definePacket({
				value = Bytenet.struct({
					AnimationName = Bytenet.string,
					PlayerName = Bytenet.string,
				})
			})
		},
		queries = {
			
		},
	}
end)