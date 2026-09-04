local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local MovementController = require(ReplicatedStorage.Game.Modules.Controllers.MovementController)
local CooldownServicePacket = require(ReplicatedStorage.Game.Packets.CooldownServicePacket)

local Signal = require(ReplicatedStorage.Packages.Signal)
local InventoryController = require(script.InventoryController)

local Player = Players.LocalPlayer
local PlayerGUI = Player.PlayerGui

local UIController = {}

function UIController.Init(self: UIController)
	self._Initialized = true
	self.AbilityUsed = Signal()
	self.CharacterUIConns = {}
	
	self:UpdateSprintBar()
	
	InventoryController:Init()
end

function UIController.UpdateSprintBar(self: UIController)
	RunService.RenderStepped:Connect(function()
		local PlayerGUI = Player.PlayerGui
		local SprintBarGUI = PlayerGUI:WaitForChild("SprintBar")

		local SprintBar = SprintBarGUI.Background.Bar
		local TextTotal = SprintBarGUI.SprintTotalText
		
		local NewCurrentStam = MovementController.CurrentStamina
		
		if NewCurrentStam > MovementController.MaxStamina/2 then
			NewCurrentStam = math.floor(NewCurrentStam)
		else
			NewCurrentStam = math.ceil(NewCurrentStam)
			if NewCurrentStam <= 0 then
				NewCurrentStam = 0
			end
		end

		SprintBar.Size = UDim2.new(math.clamp(MovementController.CurrentStamina/100,0,1),0,1,0)
		TextTotal.Text = NewCurrentStam.."/"..MovementController.MaxStamina
	end)
end

function UIController.AddCharacterUI(self: UIController, AbilityController)
	if not AbilityController.CurrentMoveset then return end
	
	for _, Conn in self.CharacterUIConns do
		Conn:Disconnect()
	end
	
	local NewAbilityGUI = ReplicatedStorage:WaitForChild("Game").Assets.UI.Abilities.Abilities:Clone()
	NewAbilityGUI.Parent = PlayerGUI
	
	for _, Ability: ModuleScript in AbilityController.CurrentMoveset:GetChildren() do
		local DataModule = ReplicatedStorage:WaitForChild("Game").Data.Abilities:FindFirstChild(Ability.Name,true)
		if not DataModule then warn("data module not found") continue end

		DataModule = require(DataModule)

		AbilityController.AbilityKeybinds[DataModule.Keybind] = Ability.Name

		local NewAbilityFrame = ReplicatedStorage:WaitForChild("Game").Assets.UI.Abilities.AbilityFrame:Clone()
		NewAbilityFrame.Parent = NewAbilityGUI.Frame
		NewAbilityFrame.Name = Ability.Name
		NewAbilityFrame.KeybindName.Text = DataModule.Keybind.Name
		NewAbilityFrame.AbilityName.Text = Ability.Name
		NewAbilityFrame.AbilityImage.Image = DataModule.ImageID

		NewAbilityFrame.AbilityImage.MouseButton1Up:Connect(function()
			AbilityController:UseAbility(Ability.Name)
		end)
		
		local attChangedConn
		
		attChangedConn = CooldownServicePacket.NewCooldown.listen(function(data)
			if not tonumber(data.Duration) then return end
			if data.Ability ~= Ability.Name then return end

			local NewCooldownFrame = ReplicatedStorage:WaitForChild("Game").Assets.UI.Abilities.CooldownFrame:Clone()

			NewCooldownFrame.Parent = NewAbilityFrame

			local StartTime = tick()
			local Duration = data.Duration

			local UpdateCDFrameConn

			UpdateCDFrameConn = RunService.RenderStepped:Connect(function()
				if not NewAbilityFrame or not NewCooldownFrame then return end
				local Elapsed = tick() - StartTime

				if Elapsed >= Duration then NewCooldownFrame:Destroy() NewAbilityFrame.KeybindName.Text = DataModule.Keybind.Name return end

				if Duration - Elapsed < 10 then
					NewAbilityFrame.KeybindName.Text = string.format("%.3s",tostring(Duration - Elapsed))
				else
					local Nstring = tostring(math.round(Duration - Elapsed))
					NewAbilityFrame.KeybindName.Text = Nstring
				end

				NewCooldownFrame.UIGradient.Offset = Vector2.new(0,Elapsed/Duration)
			end)

			table.insert(self.CharacterUIConns,UpdateCDFrameConn)
		end)
		
		--table.insert(self.CharacterUIConns,attChangedConn)
	end
end


type UIController = typeof(UIController)&{
	_Initialized: boolean,
	AbilityUsed: BindableEvent,
	CharacterUIConns: {RBXScriptConnection}
}

return UIController :: UIController