local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local RoundController = require(ServerScriptService.Game.Modules.RoundController)
local CharacterService = require(ServerScriptService.Game.Modules.CharacterService)

local DisguiseUI = ReplicatedStorage.Game.Assets.UI.Dummy.Disguise

return function(Player: Player)
	local PlayerGUI = Player.PlayerGui
	if PlayerGUI:FindFirstChild(DisguiseUI.Name) then return false end
	if #Player:GetChildren() <= 1 then return false end
	
	local NewDisguiseUI = DisguiseUI:Clone()
	NewDisguiseUI.Parent = PlayerGUI
	
	if PlayerGUI:FindFirstChild(DisguiseUI.Name) then
		local NewDisguiseUI = PlayerGUI:FindFirstChild(DisguiseUI.Name) :: typeof(DisguiseUI)
		
		local PlayerParentFrame = NewDisguiseUI.Frame.PlayerFrame
		local SelectButton = NewDisguiseUI.Frame.TextButton
		
		local CurrentSelectedPlayer = nil
		
		for _, PlayerClone: Player in Players:GetPlayers() do
			if PlayerClone == Player then continue end
			if not PlayerClone.Character:GetAttribute("Survivor") then continue end
			
			local Character = PlayerClone.Character :: Model
			Character.Archivable = true
			
			local NewFrame = ReplicatedStorage.Game.Assets.UI.Dummy.CharacterFrame:Clone()
			local NewCharacter = Character:Clone()
			
			NewFrame.Parent = PlayerParentFrame
			local NewCam = Instance.new("Camera")
			NewCam.CFrame = CFrame.new(0,0,0)
			NewCam.Parent = NewFrame.ViewportFrame
			NewFrame.ViewportFrame.CurrentCamera = NewCam
			
			NewCharacter.Parent = NewFrame.ViewportFrame
			NewCharacter:PivotTo(CFrame.new(0,0,0))
			
			NewFrame.TextButton.MouseButton1Up:Connect(function()
				CurrentSelectedPlayer = PlayerClone
			end)
		end
		
		local conn
		
		conn = SelectButton.MouseButton1Up:Connect(function()
			if not CurrentSelectedPlayer then return end
			conn:Disconnect()
			
			CharacterService:SwitchCharactersWith(Player,CurrentSelectedPlayer.Character)
			
			NewDisguiseUI:Destroy()
			return true
		end)
	end
	
	return true
end