local Bytenet = require(game.ReplicatedStorage.Packages.ByteNet)

return Bytenet.defineNamespace("CharacterService",function()
	return {
		SendCharacterEquipped = Bytenet.definePacket({
			value = Bytenet.struct({
				CharacterEquipped = Bytenet.string,
				Type = Bytenet.string
			})
		}),
		SendSkinEquipped = Bytenet.definePacket({
			value = Bytenet.struct({
				SkinEquipped = Bytenet.optional(Bytenet.string),
				CharacterEquipping = Bytenet.string,
				Type = Bytenet.string
			})
		}),
		SendCharactersOwned = Bytenet.definePacket({
			value = Bytenet.struct({
				CharactersOwned = Bytenet.map(Bytenet.string,Bytenet.string)
			})
		}),
		SendSkinsOwned = Bytenet.definePacket({
			value = Bytenet.struct({
				SkinsOwned = Bytenet.map(Bytenet.string,Bytenet.array(Bytenet.string))
			})
		}),
		SendSkinsEquippedClient = Bytenet.definePacket({
			value = Bytenet.struct({
				CharactersAndSkinsOwned = Bytenet.map(Bytenet.string,Bytenet.optional(Bytenet.string))
			})
		}),
		SendCharactersEquipped = Bytenet.definePacket({
			value = Bytenet.struct({
				CharactersEquipped = Bytenet.map(Bytenet.string,Bytenet.map(Bytenet.string,Bytenet.string))
			})
		})
	}
end)