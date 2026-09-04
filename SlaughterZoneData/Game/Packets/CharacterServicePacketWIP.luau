local Bytenet = require(game.ReplicatedStorage.Packages.ByteNetMax)

return Bytenet.defineNamespace("CharacterService",function()
	return {
		packets = {
			SendAllCharactersOwned = Bytenet.definePacket({
				value = Bytenet.struct({
					CharactersOwned = Bytenet.array(Bytenet.string)
				})
			}),
			SendCharactersEquipped = Bytenet.definePacket({
				value = Bytenet.struct({
					Survivor = Bytenet.string,
					Killer = Bytenet.string
				})
			})
		},
		queries = {
			
		},
	}
end)