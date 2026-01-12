--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DoorConstants = require(ReplicatedStorage.Shared.Constants.DoorConstants)
local DoorMath = require(ReplicatedStorage.Shared.Math.DoorMath)
local DoorTween = require(ReplicatedStorage.Shared.Utils.DoorTween)
local DoorBase = require(ReplicatedStorage.Shared.Modules.DoorBase)
local DoorTypes = require(ReplicatedStorage.Shared.Types.DoorTypes)
local LockedDoor = require(ServerScriptService.Server.Components.LockedDoor)
local DoorRegistry = require(ServerScriptService.Server.Components.DoorRegistry)

local DoorService = {}

-- Internal helper function to set up a door
local function setupDoor(doorModel: Model): DoorTypes.DoorControllerObject?
	local doorPart = doorModel.PrimaryPart
	if not doorPart then
		return nil
	end

	local doorHinge = doorModel:WaitForChild("doorHinge") :: BasePart
	local prompt = doorHinge:WaitForChild("ProximityPrompt") :: ProximityPrompt
	local isLocked = doorModel:GetAttribute("IsLocked") or false

	local originalCFrame = doorModel:GetPivot()
	local hingeCFrame = doorHinge.CFrame
	local pivotToHinge = DoorMath.computePivotToHinge(originalCFrame, hingeCFrame)

	local function updateDoor(angle: number)
		doorPart:PivotTo(DoorMath.getHingeCFrame(hingeCFrame, pivotToHinge, angle))
	end

	local tween = DoorTween.new({
		initialValue = DoorConstants.CLOSE_ANGLE,
		tweenInfo = TweenInfo.new(DoorConstants.TWEEN_DURATION, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		updateCallback = updateDoor,
	})

	local controller: DoorTypes.DoorControllerObject
	local config = {
		closedCFrame = DoorConstants.CLOSE_ANGLE,
		openCFrame = DoorConstants.OPEN_ANGLE + DoorConstants.SPIN_EXTRA,
		tween = tween,
	}

	if isLocked then
		controller = LockedDoor.new(config)
	else
		controller = DoorBase.new(config)
	end

	-- Connections
	doorPart.Touched:Connect(function(other)
		controller:handleTouch(other, doorHinge.Position, DoorConstants.SMASH_FORCE)
	end)

	prompt.Triggered:Connect(function(player)
		controller:toggle(player)
	end)

	return controller
end

-- The main function that 'init.server.luau' will call
function DoorService.init()
	print("DoorService: Initializing...")
	local normalDoorModel = workspace:WaitForChild("DoorModel")
	local normalController = setupDoor(normalDoorModel)
	if normalController then
		DoorRegistry.ActiveDoors[normalDoorModel] = normalController
	end
	-- For your manual testing:
	local lockedDoorModel = workspace:WaitForChild("LockedDoorModel")
	local lockedController = setupDoor(lockedDoorModel)
	if lockedController then
		DoorRegistry.ActiveDoors[lockedDoorModel] = lockedController
	end
end

return DoorService
