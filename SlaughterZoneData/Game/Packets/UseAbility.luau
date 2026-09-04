local Bytenet = require(game.ReplicatedStorage.Packages.ByteNet)

return Bytenet.defineNamespace("UseAbility",function()
	return {
		Send = Bytenet.definePacket({
			value = Bytenet.struct({
				AbilityName = Bytenet.string
			})
		})
	}
end)