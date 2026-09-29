local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local MovementController = require(ReplicatedStorage.Game.Modules.Controllers.MovementController)

type Mapping = {
	Add: { {name: string, Duration: number} },
	Remove: {string},
	StateType: string,
	Requirements: () -> (),
	Effects: () -> ()
}


return function()
	local Character = Player.Character :: Model
	local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid
	local StateTypes = Enum.HumanoidStateType
	
	
	return {
		{
			Add = {{Name = "Walking",Duration = nil}},
			Remove = {"Idle"},
			StateType = StateTypes.Running,
			Requirements = function()
				if MovementController:IsMoving() and not MovementController:IsSprinting() then
					return true
				else
					return false
				end
			end,
			Effects = function()
				
			end,
		},
		{
			Add = {{Name = "Sprinting",Duration = nil}},
			Remove = {"Walking"},
			StateType = StateTypes.Running,
			Requirements = function()
				return MovementController:IsSprinting()
			end,
			Effects = function()

			end,
		},
		{
			Add = {{Name = "Landed",Duration = 0.15}},
			Remove = {},
			StateType = StateTypes.Landed,
			Requirements = function()
				return true
			end,
			Effects = function()

			end,
		},
		{
			Add = {{Name = "Idle",Duration = nil}},
			Remove = {},
			StateType = StateTypes.Running,
			Requirements = function()
				return true
			end,
			Effects = function()
				
			end,
		}
	} :: Mapping
end