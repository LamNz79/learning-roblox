--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import our Service, Registry, and Button module
local EnemyService = require(script.Scripts.EnemyService)
local DoorService = require(ServerScriptService.Server.Scripts.DoorService)
local DoorRegistry = require(ServerScriptService.Server.Components.DoorRegistry)
local ButtonBase = require(ReplicatedStorage.Shared.Modules.ButtonBase)

-- 1. START THE DOOR SYSTEM FIRST
DoorService.init()

-- 2. SETUP THE MANUAL BUTTON LOGIC
local bigRedButtonModel = workspace:WaitForChild("BigRedButton")
local redButton = bigRedButtonModel:WaitForChild("Button") :: BasePart
local lockedDoorModel = workspace:WaitForChild("LockedDoorModel")

local myButton = ButtonBase.new(bigRedButtonModel)
local buttonDebounce = false

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
			print("Button successfully unlocked the door!")
		else
			lockedController:lock()
			print("Button successfully locked the door!")
		end
	end

	task.wait(1)
	buttonDebounce = false
end)

EnemyService.init()

print("Server: All systems initialized.")
