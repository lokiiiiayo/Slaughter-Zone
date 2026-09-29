return {
	Cooldown = 1,
	PossibleRecipies = {
		Vanilla = {
			Quote = "Light and soft, like snow.",
			Heal = 6,
			Stamina = 6,
			Effects = function()

			end,
			},
		Chocolate = {
			Quote = "Heavy, but extremely tasty.",
			Heal = 15,
			Stamina = 0,
			Effects = function()

			end,
		},
		HomemadePie = {
			Quote = "That's... not exactly what I was expecting.",
			Heal = 3,
			Stamina = 0,
			Effects = function()
				
			end,
		},
		Strawberry = {
			Quote = "Complicated preparation, but the result is always phenomenal.",
			Heal = 10,
			Stamina = 0,
			Effects = function()

			end,
		}
	},
	RecipeOrder = {"Vanilla", "Chocolate", "HomemadePie", "Strawberry"},
	Keybind = Enum.KeyCode.Two,
	ImageID = "rbxassetid://135056191400639",
	Description = "Uhh, i think i'll have a number 2"
}