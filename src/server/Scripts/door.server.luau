--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")

local DoorMathModule = require(Shared.Math:WaitForChild("doorMath"))
local DoorTweenModule = require(Shared.Utils:WaitForChild("doorTween"))
local DoorControllerModule = require(Shared.Controllers:WaitForChild("DoorController"))
local LockedDoorControllerModule = require(Server.Components:WaitForChild("LockDoorController"))

local DoorMath = DoorMathModule :: typeof(require(game.ReplicatedStorage.Shared.Math.doorMath))
local DoorTween = DoorTweenModule :: typeof(require(game.ReplicatedStorage.Shared.Utils.doorTween))
local DoorController = DoorControllerModule :: typeof(require(game.ReplicatedStorage.Shared.Controllers.DoorController))
local LockedDoorController =
	LockedDoorControllerModule :: typeof(require(game.ServerScriptService.Server.Components.LockDoorController))

local SMASH_FORCE = 10
local CLOSED_ANGLE = 0
local OPEN_ANGLE = 160
local SPIN_EXTRA = 0

-- Function to set up a door
local function setupDoor(doorModel: Model)
	local doorPart = doorModel.PrimaryPart
	if not doorPart then
		warn(`Model {doorModel.Name} is missing a PrimaryPart!`)
		return nil
	end
	local doorHinge = doorModel:WaitForChild("doorHinge") :: BasePart
	local prompt = doorHinge:WaitForChild("ProximityPrompt") :: ProximityPrompt
	local isLocked = doorModel:GetAttribute("IsLocked") or false

	local originalCFrame = doorModel:GetPivot()
	local hingeCFrame = doorHinge.CFrame

	local pivotToHinge = DoorMath.computePivotToHinge(originalCFrame, hingeCFrame)

	local function updateDoor(angle: number)
		local currentCFrame = DoorMath.getHingeCFrame(hingeCFrame, pivotToHinge, angle)
		doorPart:PivotTo(currentCFrame)
	end

	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local tween = DoorTween.new(CLOSED_ANGLE, tweenInfo, updateDoor)

	local controller
	if isLocked then
		controller = LockedDoorController.new({
			closedCFrame = CLOSED_ANGLE,
			openCFrame = OPEN_ANGLE + SPIN_EXTRA,
			tween = tween,
		})
		print(doorModel.Name .. " - Created LOCKED door controller")
	else
		controller = DoorController.new({
			closedCFrame = CLOSED_ANGLE,
			openCFrame = OPEN_ANGLE + SPIN_EXTRA,
			tween = tween,
		})
		print(doorModel.Name .. " - Created regular door controller")
	end

	-- Connect the Touched event
	doorPart.Touched:Connect(function(otherPart)
		controller:handleTouch(otherPart, doorHinge.Position, SMASH_FORCE)
	end)

	-- Connect the ProximityPrompt
	prompt.Triggered:Connect(function(player)
		controller:toggle(player)
	end)

	return controller
end

-- Set up both doors
-- local normalDoorModel = workspace:WaitForChild("DoorModel")
local lockedDoorModel = workspace:WaitForChild("LockedDoorModel")
local bigRedButtonModel = workspace:WaitForChild("BigRedButton")
local redButton = bigRedButtonModel:WaitForChild("Button")
-- local normalDoorController = setupDoor(normalDoorModel)
local lockedDoorController = setupDoor(lockedDoorModel)
local buttonDebounce = false

if lockedDoorController then
	redButton.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		if buttonDebounce then
			buttonDebounce = true
			print("Button pressed by", character.Name)
		end
		if lockedDoorController.unlock and lockedDoorController.isLocked then
			lockedDoorController:unlock()
			print("Door is now UNLOCKED")
		end

		task.wait(1)
		buttonDebounce = false
	end)
end

-- Repeat the same logic for the normal door safely
-- if normalDoorController then
-- 	if normalDoorController.unlock then
-- 		task.delay(10, function()
-- 			normalDoorController:unlock()
-- 		end)
-- 	end
-- end
