local SkinService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local DataService = require(ServerScriptService.Game.Modules.DataService)

local SkinServicePacket = require(ReplicatedStorage.Game.Packets.SkinServicePacket)

function SkinService.init(self: SkinService)
	self._initialized = true
	self.players = {}
	self.skinIndex = nil
	
	self:Start()
end

function SkinService.Start(self: SkinService)
	game.Players.PlayerAdded:Connect(function(Player: Player)
		while task.wait(0.1) do
			if not self:UpdateSkinsOwned(Player) then continue else break end
		end
	end)
	
	self.skinIndex = self:GetAllSkins()
end

function SkinService.UpdateSkinsOwned(self: SkinService, Player: Player) --When a new player joins, they have their skins added to them here (grabbed from data store)
	local SkinsOwned = DataService:GetData(Player,"OwnedSkins")
	local SkinsEquipped = DataService:GetData(Player,"EquippedSkins")
	
	if not SkinsOwned and SkinsEquipped then return false end
	
	self.players[Player] = {SkinsOwned,SkinsEquipped}
	
	return true
end

function SkinService.EquipSkin(self: SkinService,Player: Player,Character: string, Skin: string, Variant: string?)
	if self:OwnsSkin(Player,Skin) then
		self.players[Player]["SkinsEquipped"][Character].Skin = Skin
		self.players[Player]["SkinsEquipped"][Character].Variant = Variant
		
		DataService:UpdateData(Player,"SkinsEquipped",self.players[Player]["SkinsEquipped"])
	end
end

function SkinService.GiveSkin(self: SkinService,Player: Player, SkinName: string)
	if self.skinIndex[SkinName] then
		DataService:UpdateTableWithKey(Player,"OwnedSkins",SkinName,true)
		self.players[Player]["SkinsOwned"][SkinName] = true
	end
end

function SkinService.GetSkinEquipped(self: SkinService, Player: Player, Character: string)
	local SkinFound = self.players[Player]["SkinsEquipped"][Character]["Skin"]
	local VariantFound = self.players[Player]["SkinsEquipped"][Character]["Variant"]
	
	return SkinFound, VariantFound
end

function SkinService.OwnsSkin(self: SkinService, Player: Player, Skin: string)
	return self.players[Player]["OwnedSkins"][Skin]
end

function SkinService.GetAllSkins(self: SkinService)
	local Skins = {}

	for _, Skin in ReplicatedStorage:WaitForChild("Game").Data.Skins:GetDescendants() do
		if Skin:IsA("ModuleScript") then
			Skins[Skin.Name] = Skin.Name
		end
	end
	
	return Skins
end

type SkinService = typeof(SkinService)&{
	_initialized: boolean,
	players: {Player: {SkinsEquipped: {Character: {Skin: string, Variant: string}}, OwnedSkins: {Skin: boolean}}},
	skinIndex: {string}
}

return SkinService :: SkinService