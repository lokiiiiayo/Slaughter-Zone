local Bytenet = require(game.ReplicatedStorage.Packages.ByteNet)

return Bytenet.defineNamespace("UpdateTimer",function()
	return {
		newtimervalue = Bytenet.definePacket({
			value = Bytenet.struct({
				message = Bytenet.int32
			})
		})
	}
end)