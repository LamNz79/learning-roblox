--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import our Service, Registry, and Button module
local EnemyService = require(script.Services.EnemyService)
local GameStateService = require(script.Services.GameStateService)
local WaveService = require(script.Services.WaveService)
local DoorService = require(ServerScriptService.Server.Services.DoorService)
local DoorRegistry = require(ServerScriptService.Server.Components.DoorRegistry)
local ButtonBase = require(ReplicatedStorage.Shared.Modules.ButtonBase)
local bigRedButtonModel = workspace:WaitForChild("BigRedButton")
local redButton = bigRedButtonModel:WaitForChild("Button") :: BasePart
local lockedDoorModel = workspace:WaitForChild("LockedDoorModel")
local myButton = ButtonBase.new(bigRedButtonModel)
local buttonDebounce = false
local enemyType = "BasicEnemy"

GameStateService.init()
DoorService.init()
EnemyService.init(enemyType)
WaveService.init()

redButton.Touched:Connect(function(otherPart)
	local character = otherPart.Parent
	local player = if character then game.Players:GetPlayerFromCharacter(character) else nil

	if not player or buttonDebounce then
		return
	end
	buttonDebounce = true

	-- Use the Registry to find the controller we created in DoorService
	local controller = DoorRegistry.ActiveDoors[lockedDoorModel]

	if controller then
		myButton:interact(player)

		-- Use a type-check to see if it's a locked door
		local lockedController = controller :: any
		if lockedController.isLocked then
			lockedController:unlock()
		else
			lockedController:lock()
		end
	end

	task.wait(1)
	buttonDebounce = false
end)

print("Server: All systems initialized.")
