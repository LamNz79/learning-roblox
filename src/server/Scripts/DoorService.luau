--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DoorConstants = require(ReplicatedStorage.Shared.Constants.DoorConstants)
local DoorMath = require(ReplicatedStorage.Shared.Math.DoorMath)
local DoorTween = require(ReplicatedStorage.Shared.Utils.DoorTween)
local DoorBase = require(ReplicatedStorage.Shared.Modules.DoorBase)
local DoorTypes = require(ReplicatedStorage.Shared.Types.DoorTypes)
local LockedDoor = require(ServerScriptService.Server.Components.LockedDoor)
local HeavenDoor = require(ServerScriptService.Server.Components.HeavenDoor) -- Added this
local DoorRegistry = require(ServerScriptService.Server.Components.DoorRegistry)

local DoorService = {}

local function setupDoor(doorModel: Model): DoorTypes.DoorControllerObject?
	local doorPart = doorModel.PrimaryPart
	if not doorPart then
		return nil
	end

	local sound = doorModel:FindFirstChild("HeavenlySong") :: Sound?
	local isHeaven = doorModel:GetAttribute("IsHeaven") or false
	local isLocked = doorModel:GetAttribute("IsLocked") or false
	local doorHinge = doorModel:WaitForChild("doorHinge") :: BasePart
	local originalPivot = doorModel:GetPivot()

	-- 1. DEFINE MOTION LOGIC
	local tween: any
	local config: DoorTypes.DoorConfig

	if isHeaven then
		-- HEAVENLY MOTION: Slides Up 15 studs smoothly
		local function updateHeavenDoor(height: number)
			doorPart:PivotTo(originalPivot + (doorPart.CFrame.UpVector * height))
		end

		tween = DoorTween.new({
			initialValue = 0,
			tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			updateCallback = updateHeavenDoor,
		})

		config = {
			closedCFrame = 0,
			openCFrame = 15,
			tween = tween,
		}

		return HeavenDoor.new(config, doorModel, sound)
	else
		-- STANDARD HINGE MOTION
		local hingeCFrame = doorHinge.CFrame
		local pivotToHinge = DoorMath.computePivotToHinge(originalPivot, hingeCFrame)

		local function updateStandardDoor(angle: number)
			doorPart:PivotTo(DoorMath.getHingeCFrame(hingeCFrame, pivotToHinge, angle))
		end

		tween = DoorTween.new({
			initialValue = DoorConstants.CLOSE_ANGLE,
			tweenInfo = TweenInfo.new(DoorConstants.TWEEN_DURATION, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
			updateCallback = updateStandardDoor,
		})

		config = {
			closedCFrame = DoorConstants.CLOSE_ANGLE,
			openCFrame = DoorConstants.OPEN_ANGLE + DoorConstants.SPIN_EXTRA,
			tween = tween,
		}

		return if isLocked then LockedDoor.new(config) else DoorBase.new(config)
	end
end

function DoorService.init()
	-- print("DoorService: Initializing...")
	-- local normalDoorModel = workspace:WaitForChild("DoorModel")
	-- local normalController = setupDoor(normalDoorModel)
	-- if normalController then
	-- 	DoorRegistry.ActiveDoors[normalDoorModel] = normalController
	-- end
	-- -- For your manual testing:
	-- local lockedDoorModel = workspace:WaitForChild("LockedDoorModel")
	-- local lockedController = setupDoor(lockedDoorModel)
	-- if lockedController then
	-- 	DoorRegistry.ActiveDoors[lockedDoorModel] = lockedController
	-- end

	-- Automated registration for all doors [cite: 4]
	for _, doorModel in ipairs(workspace:GetDescendants()) do
		if not doorModel:IsA("Model") or not doorModel:GetAttribute("IsDoor") then
			continue
		end

		local controller = setupDoor(doorModel)
		print(doorModel)
		if controller then
			DoorRegistry.ActiveDoors[doorModel] = controller

			-- Final Setup for all door types
			local doorPart = doorModel.PrimaryPart :: BasePart
			local doorHinge = doorModel:WaitForChild("doorHinge") :: BasePart
			local prompt = doorHinge:WaitForChild("ProximityPrompt") :: ProximityPrompt

			doorPart.Touched:Connect(function(other)
				controller:handleTouch(other, doorHinge.Position, DoorConstants.SMASH_FORCE)
			end)

			prompt.Triggered:Connect(function(player)
				controller:toggle(player)
			end)
		end
	end
end

return DoorService
