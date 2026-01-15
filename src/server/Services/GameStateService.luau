local GameStateService = {}

local baseHealth = 100
local currentWave = 0

function GameStateService.reduceHealth(amount: number)
	baseHealth -= amount
	-- Using math.max ensures health never goes below 0
	baseHealth = math.max(0, baseHealth)

	print("💥 Base Damaged! Health remaining: " .. baseHealth)

	if baseHealth <= 0 then
		warn("💀 GAME OVER: The base has been destroyed!")
	end
end
function GameStateService.getHealth()
	return baseHealth
end
function GameStateService.init()
	print("❤️ GameStateService initialized. Starting Health: " .. baseHealth)
end
return GameStateService
