local Bytenet = require(game.ReplicatedStorage.Packages.ByteNetMax)

return Bytenet.defineNamespace("CharacterService",function()
	return {
		packets = {
			SendSkinEquipped = Bytenet.definePacket({
				value = Bytenet.struct({
					SkinEquipped = Bytenet.optional(Bytenet.string)
				})
			}),
			
		},
		queries = {
			
		},
	}
end)