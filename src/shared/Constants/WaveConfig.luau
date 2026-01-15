--!strict
local EnemyConfig = require(script.Parent.EnemyConfig)

local WaveConfig = {
	[1] = {
		Enemies = {
			{ Type = "BasicEnemy", Amount = 5, Delay = 2 },
		},
		Intermission = 10, -- Time before this wave starts
	},
	[2] = {
		Enemies = {
			{ Type = "BasicEnemy", Amount = 10, Delay = 1.5 },
		},
		Intermission = 15,
	},
}

return WaveConfig
