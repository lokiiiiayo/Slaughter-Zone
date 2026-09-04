local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CharacterServicePacket = require(ReplicatedStorage.Game.Packets.CharacterService)
local DataService = require(ServerScriptService.Game.Modules.DataService)
local AbilityStateService = require(ServerScriptService.Game.Modules.AbilityStateService)

local CharacterStates = ReplicatedStorage.Game.Data.States

local CharacterService = {}

function CharacterService.Init(self: CharacterService)
	self._Initialized = true
	self.PlayersAndCharacterEquipped = {}
	
	Players.PlayerAdded:Connect(function(Player)
		repeat
			task.wait(0.2)
		until self:AddPlayerToMonitoring(Player)
	end)
	
	self:WaitForClient()
end

function CharacterService.AddPlayerToMonitoring(self: CharacterService,Player: Player)
	local SurvivorData = DataService:GetData(Player,"Survivor")
	local KillerData = DataService:GetData(Player,"Killer")
	
	if not KillerData or not SurvivorData then return false end
	
	local KillerEquipped = KillerData.Character
	local SurvivorEquipped = SurvivorData.Character
	local KillerSkin = DataService:GetData(Player,"EquippedSkins")[KillerEquipped]
	local SurvivorSkin = DataService:GetData(Player,"EquippedSkins")[SurvivorEquipped]
	
	if not KillerEquipped or not SurvivorEquipped then return false end
	
	self.PlayersAndCharacterEquipped[Player] = {
		Killer = {Character = KillerEquipped,Skin = KillerSkin},
		Survivor = {Character = SurvivorEquipped,Skin = SurvivorSkin},
	}
	
	self:SyncClientCharactersOwned(Player)
	return true
end

function CharacterService.SyncClientCharactersOwned(self: CharacterService,Player)
	CharacterServicePacket.SendCharactersOwned.sendTo({
		CharactersOwned = DataService:GetData(Player,"OwnedCharacters") or {}
	},Player)
	CharacterServicePacket.SendSkinsOwned.sendTo({
		SkinsOwned = DataService:GetData(Player,"OwnedSkins") or {}
	},Player)
	CharacterServicePacket.SendSkinsEquippedClient.sendTo({
		CharactersAndSkinsOwned = DataService:GetData(Player,"EquippedSkins") or {}
	},Player)
	CharacterServicePacket.SendCharactersEquipped.sendTo({
		CharactersEquipped = self.PlayersAndCharacterEquipped[Player]
	},Player)
end

function CharacterService.WaitForClient(self: CharacterService)
	CharacterServicePacket.SendSkinEquipped.listen(function(Data,Player)
		if not Data.SkinEquipped then self:EquipSkin(Player,nil,Data.CharacterEquipping,Data.Type) return end
		if not self:OwnsSkin(Player,Data.CharacterEquipping,Data.SkinEquipped) then warn(Player.Name, "Doesnt own", Data.SkinEquipped) return end
		
		self:EquipSkin(Player,Data.SkinEquipped,Data.CharacterEquipping,Data.Type)
	end)
	CharacterServicePacket.SendCharacterEquipped.listen(function(Data,Player)
		if not self:OwnsCharacter(Player,Data.CharacterEquipped) then warn(Player.Name, "Doesnt own", Data.CharacterEquipped) return end
		
		self:EquipCharacter(Player,Data.CharacterEquipped,nil,Data.Type)
	end)
end

function CharacterService.OwnsCharacter(self: CharacterService,Player: Player,Character: string)
	local CharactersOwned = DataService:GetData(Player,"OwnedCharacters")
	
	for _, CharacterOwned in CharactersOwned do
		if CharacterOwned ~= Character then continue end
		
		return true
	end
	
	return false
end

function CharacterService.OwnsSkin(self: CharacterService,Player: Player,Character: string,Skin: string)
	local SkinsOwned = DataService:GetData(Player,"OwnedSkins")[Character]
	local SkinFound = false
	
	if not SkinsOwned then
		DataService:UpdateTableWithKey(Player,"OwnedSkins",Character,{})
	end
	
	SkinsOwned = DataService:GetData(Player,"OwnedSkins")[Character]
	
	for _, foundskin in SkinsOwned do
		if foundskin == Skin then
			SkinFound = true
		end
	end
	
	return SkinFound
end

function CharacterService.EquipSkin(self: CharacterService,Player: Player,Skin: string,Character: string,Type: string)
	local SkinsEquipped = DataService:GetData(Player,"EquippedSkins")
	
	self.PlayersAndCharacterEquipped[Player][Type] = {Character = Character,Skin = Skin}
	DataService:UpdateTableWithKey(Player,"EquippedSkins",Character,Skin)
	self:SyncClientCharactersOwned(Player)
end

function CharacterService.EquipCharacter(self: CharacterService,Player: Player,Character: string,Skin: string,Type: string)
	local SkinsEquipped = DataService:GetData(Player,"EquippedSkins")
	
	if SkinsEquipped[Character] and not Skin then
		Skin = SkinsEquipped[Character]
	end
	
	print("Equipped", Character)
	DataService:UpdateData(Player,Type,{Character = Character,Skin = Skin})
	
	self.PlayersAndCharacterEquipped[Player][Type] = {Character = Character,Skin = Skin}
	self:SyncClientCharactersOwned(Player)
end

function CharacterService.GiveCharacter(self: CharacterService,Player: Player,Character: string)
	DataService:UpdateDataTable(Player,"OwnedCharacters",Character)
	
	self:SyncClientCharactersOwned(Player)
end

function CharacterService.GiveSkin(self: CharacterService,Player: Player,Skin: string,Character: string)
	local OriginalTable = DataService:GetData(Player,"OwnedSkins")[Character]
	
	if not OriginalTable then
		DataService:UpdateTableWithKey(Player,"OwnedSkins",Character,{})
		
		OriginalTable = DataService:GetData(Player,"OwnedSkins")[Character]
	end
	
	local NewTable = {}
	
	for _, OriginalSkin in OriginalTable do
		table.insert(NewTable,OriginalSkin)
	end
	
	table.insert(NewTable,Skin)
	
	DataService:UpdateTableWithKey(Player,"OwnedSkins",Character,NewTable)
	self:SyncClientCharactersOwned(Player)
end

function CharacterService.LoadCharacterForGroup(self: CharacterService,PlayerGroup: {Player},Type: string)
	for _, Player in PlayerGroup do
		self:LoadCharacterFor(Player,Type)
	end
end

function CharacterService.AddStateTo(self: CharacterService,Player: Player,Name: string)
	if not CharacterStates:FindFirstChild(Name) then return end
	
	local NewModule = require(CharacterStates:FindFirstChild(Name))
	
	if not NewModule then return end
	
	AbilityStateService:CleanPlayer(Player)
	AbilityStateService:AddState(Player,Name,NewModule)
end

function CharacterService.LoadCharacterFor(self: CharacterService,Player: Player,Type: string)
	local CurrentPlayerCharacter: Model = Player.Character or Player.CharacterAdded:Wait()
	
	if not CurrentPlayerCharacter then warn("Player character not found") return end
	
	local CharacterData = self.PlayersAndCharacterEquipped[Player][Type]
	
	if not CharacterData then return end
	
	local SkinName = CharacterData.Skin
	local CharacterName = CharacterData.Character
	
	local NewCharacterModel = nil
	
	if SkinName then
		NewCharacterModel = ReplicatedStorage.Game.Assets.Skins:FindFirstChild(SkinName,true)
	elseif CharacterName then
		NewCharacterModel = ReplicatedStorage.Game.Assets.Characters:FindFirstChild(CharacterName)
	end
	
	if not NewCharacterModel then warn("Character model not found for", Player.Name) return end
	
	NewCharacterModel = NewCharacterModel:Clone() :: Model
	
	NewCharacterModel:SetAttribute(Type,true)
	
	local OldCF = CurrentPlayerCharacter:GetPivot()
	
	Player.Character = NewCharacterModel
	NewCharacterModel.Parent = workspace
	
	NewCharacterModel:PivotTo(OldCF)
	CurrentPlayerCharacter:Destroy()
	
	self:AddStateTo(Player,CharacterName)
end

function CharacterService.SwitchCharactersWith(self:CharacterService,Player: Player,OtherCharacter: Model)
	local CurrentPlayerCharacter: Model = Player.Character or Player.CharacterAdded:Wait()

	if not CurrentPlayerCharacter then warn("Player character not found") return end

	OtherCharacter = OtherCharacter:Clone() :: Model

	local OldCF = CurrentPlayerCharacter:GetPivot()

	Player.Character = OtherCharacter
	OtherCharacter.Parent = workspace

	OtherCharacter:PivotTo(OldCF)
	CurrentPlayerCharacter:Destroy()
end

function CharacterService.GetCharacter(self: CharacterService,Player: Player,Type: string,Skin: boolean)
	self:AddPlayerToMonitoring(Player)

	local Path = "Character"

	if Skin then
		Path = "Skin"
	end

	return self.PlayersAndCharacterEquipped[Player][Type][Path]
end

type CharacterService = typeof(CharacterService)&{
	_Initialized: boolean,
	PlayersAndCharacterEquipped: {}
}

return CharacterService :: CharacterService