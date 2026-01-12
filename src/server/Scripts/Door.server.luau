--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DoorConstants = require(ReplicatedStorage.Shared.Constants.DoorConstants)
local ButtonBase = require(ReplicatedStorage.Shared.Modules.ButtonBase)
local DoorMath = require(ReplicatedStorage.Shared.Math:WaitForChild("DoorMath"))
local DoorTween = require(ReplicatedStorage.Shared.Utils:WaitForChild("DoorTween"))
local DoorBase = require(ReplicatedStorage.Shared.Modules:WaitForChild("DoorBase"))
local DoorTypes = require(ReplicatedStorage.Shared.Types.DoorTypes)
local LockedDoorController = require(ServerScriptService.Server.Components:WaitForChild("LockedDoor"))

local lockedDoorModel = workspace:WaitForChild("LockedDoorModel")
local bigRedButtonModel = workspace:WaitForChild("BigRedButton")
local redButton = bigRedButtonModel:WaitForChild("Button") :: BasePart

-- Type alias for cleaner code
type DoorControllerType = DoorTypes.DoorBaseObject | LockedDoorController.LockedDoorObject

-- Type guard function to check if controller is a LockedDoorObject
local function isLockedDoor(controller: DoorControllerType): boolean
	return (controller :: any).isLocked ~= nil
end

-- Function to set up a door
local function setupDoor(doorModel: Model): DoorControllerType?
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

	local tweenInfo = TweenInfo.new(DoorConstants.TWEEN_DURATION, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local tweenConfig: DoorTween.DoorTweenConfig = {
		initialValue = DoorConstants.CLOSE_ANGLE,
		tweenInfo = tweenInfo,
		updateCallback = updateDoor,
	}

	local tween = DoorTween.new(tweenConfig)
	local controller: DoorControllerType

	if isLocked then
		controller = LockedDoorController.new({
			closedCFrame = DoorConstants.CLOSE_ANGLE,
			openCFrame = DoorConstants.OPEN_ANGLE + DoorConstants.SPIN_EXTRA,
			tween = tween,
		})
		print(doorModel.Name .. " - Created LOCKED door controller")
	else
		controller = DoorBase.new({
			closedCFrame = DoorConstants.CLOSE_ANGLE,
			openCFrame = DoorConstants.OPEN_ANGLE + DoorConstants.SPIN_EXTRA,
			tween = tween,
		})
		print(doorModel.Name .. " - Created regular door controller")
	end

	-- Connect the Touched event
	doorPart.Touched:Connect(function(otherPart)
		controller:handleTouch(otherPart, doorHinge.Position, DoorConstants.SMASH_FORCE)
	end)

	-- Connect the ProximityPrompt
	prompt.Triggered:Connect(function(player)
		controller:toggle(player)
	end)

	return controller
end

local lockedDoorController = setupDoor(lockedDoorModel)
local myButton = ButtonBase.new(bigRedButtonModel)

-- Guard clause: early return if controller doesn't exist
if not lockedDoorController then
	warn("Failed to setup locked door controller")
	return
end

-- Type-safe check and cast
if not isLockedDoor(lockedDoorController) then
	warn("Door controller is not a locked door")
	return
end

-- Now we can safely cast to LockedDoorObject
local typedLockedController = lockedDoorController :: LockedDoorController.LockedDoorObject

local buttonDebounce = false

redButton.Touched:Connect(function(otherPart)
	local character = otherPart.Parent

	-- Guard clause: early return if not a character
	if not character or not character:IsA("Model") then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local player = game.Players:GetPlayerFromCharacter(character)

	-- Guard clause: early return if missing humanoid or player
	if not humanoid or not player then
		return
	end

	-- Guard clause: debounce check
	if buttonDebounce then
		return
	end

	buttonDebounce = true

	myButton:interact(player)
	print("Button pressed by", player.Name)

	-- Now we can safely call unlock without type casting
	if typedLockedController.isLocked then
		typedLockedController:unlock()
		print("Door is now UNLOCKED")
	end

	task.wait(1)
	buttonDebounce = false
end)
