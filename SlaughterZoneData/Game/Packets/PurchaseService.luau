local Bytenet = require(game.ReplicatedStorage.Packages.ByteNet)

return Bytenet.defineNamespace("PurchaseService",function()
	return {
		BuyCharacter = Bytenet.definePacket({
			value = Bytenet.struct({
				CharacterToBuy = Bytenet.string
			})
		}),
		BuySkin = Bytenet.definePacket({
			value = Bytenet.struct({
				SkinToBuy = Bytenet.string,
				CharacterBuyingFor = Bytenet.string
			})
		})
	}
end)