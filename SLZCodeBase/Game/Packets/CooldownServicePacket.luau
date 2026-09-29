local Bytenet = require(game.ReplicatedStorage.Packages.ByteNet)

return Bytenet.defineNamespace("CooldownServicePacket",function()
	return {
		NewCooldown = Bytenet.definePacket({
			value = Bytenet.struct({
				Ability = Bytenet.string,
				Duration = Bytenet.int32
			})
		}),
	}
end)