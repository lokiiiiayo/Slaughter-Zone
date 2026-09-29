local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataService = require(ServerScriptService.ServerGame.Modules.DataService)
local PurchaseServicePacket = require(ReplicatedStorage.Game.Packets.PurchaseService)
local CharacterService = require(ServerScriptService.ServerGame.Modules.CharacterService)

local CharacterData = ReplicatedStorage.Game.Data.Characters
local SkinData = ReplicatedStorage.Game.Data.Skins

local PurchaseService = {}

function PurchaseService.Init(self: PurchaseService)
	self._Initialized = true
	
	self:WaitForClient()
end

function PurchaseService.WaitForClient(self: PurchaseService)
	PurchaseServicePacket.BuySkin.listen(function(Data,Player)
		self:BuySkin(Player,Data.SkinToBuy,Data.CharacterBuyingFor)
	end)
	PurchaseServicePacket.BuyCharacter.listen(function(Data,Player)
		self:BuyCharacter(Player,Data.CharacterToBuy)
	end)
end

local function SpendTix(Cost,CurrentTix)
	local TixPostPurchase = CurrentTix - Cost
	
	if TixPostPurchase < 0 then return false end
	
	return true, TixPostPurchase
end

function PurchaseService.BuyCharacter(self: PurchaseService,Player: Player,Character: string)
	local PlayerTix = DataService:GetData(Player,"Tix")
	local CharData = CharacterData:FindFirstChild(Character,true) :: ModuleScript
	
	CharData = require(CharData)
	
	local Cost = CharData.Cost
	
	local Succesful, RemainingTix = SpendTix(Cost, PlayerTix)
	
	if not Succesful then return false end
	
	print(`Spent {Cost} Tix`)
	print(`{RemainingTix} Remain`)
	
	DataService:UpdateData(Player,"Tix",RemainingTix)
	CharacterService:GiveCharacter(Player,Character)
	
	return Succesful
end

function PurchaseService.BuySkin(self: PurchaseService,Player: Player,Skin: string,Character: string)
	local PlayerTix = DataService:GetData(Player,"Tix")
	local SkinDatamodule = SkinData:FindFirstChild(Skin,true) :: ModuleScript
	
	SkinDatamodule = require(SkinDatamodule)
	
	local Cost = SkinDatamodule.Cost

	local Succesful, RemainingTix = SpendTix(Cost, PlayerTix)

	if not Succesful then return false end
	
	print(`Spent {Cost} Tix`)
	print(`{RemainingTix} Remain`)
	
	DataService:UpdateData(Player,"Tix",RemainingTix)
	CharacterService:GiveSkin(Player,Skin,Character)
	
	return Succesful
end


type PurchaseService = typeof(PurchaseService)&{
	_Initialized: boolean
}

type CharacterModule = {
	Name: string,
	Type: string,
	Cost: number,
	RenderImage: string
}

return PurchaseService :: PurchaseService