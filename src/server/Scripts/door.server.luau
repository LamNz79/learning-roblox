-- local doorModel = workspace:WaitForChild("DoorModel")
-- local doorPart = doorModel.PrimaryPart

-- local doorHinge = doorModel:WaitForChild("doorHinge")
-- local prompt = doorPart:WaitForChild("ProximityPrompt")
-- local isOpen = false

-- -- Store the original pivot and hinge position
-- local originalCFrame = doorModel:GetPivot()
-- local hingePosition = doorHinge.Position
-- print("originalCFrame", originalCFrame)
-- print("hingePosition", hingePosition)
-- -- Calculate the offset from the model's pivot to the hinge
-- local pivotToHinge = originalCFrame:Inverse() * CFrame.new(hingePosition)
-- print("pivotToHinge", pivotToHinge)
-- -- Pre-calculate the open position (90° rotation around Y-axis)
-- -- This rotates the door around the hinge point
-- local openCFrame = CFrame.new(hingePosition) * CFrame.Angles(0, math.rad(90), 0) * pivotToHinge:Inverse()

-- prompt.Triggered:Connect(function(player)
-- 	if isOpen then
-- 		-- Rotate back to closed
-- 		doorPart:PivotTo(originalCFrame)
-- 		isOpen = false
-- 		print(player.Name .. " closed the door")
-- 	else
-- 		-- Rotate to open around the hinge
-- 		doorPart:PivotTo(openCFrame)
-- 		isOpen = true
-- 		print(player.Name .. " opened the door")
-- 	end
-- end)

--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")

local DoorMathModule = require(Shared.Math:WaitForChild("DoorMath"))
local DoorTweenModule = require(Shared.Utils:WaitForChild("DoorTween"))
local DoorControllerModule = require(Server.Components:WaitForChild("DoorController"))

local DoorMath = DoorMathModule :: typeof(require(game.ReplicatedStorage.Shared.Math.DoorMath))
local DoorTween = DoorTweenModule :: typeof(require(game.ReplicatedStorage.Shared.Math.DoorTween))
local DoorController =
	DoorControllerModule :: typeof(require(game.ServerScriptService.Server.Components.DoorController))

local doorModel = workspace:WaitForChild("DoorModel")
local doorPart = doorModel.PrimaryPart
local doorHinge = doorModel:WaitForChild("doorHinge")
local prompt = doorHinge:WaitForChild("ProximityPrompt")

local CLOSED_ANGLE = 0
local OPEN_ANGLE = 160
local SPIN_EXTRA = 0

local originalCFrame = doorModel:GetPivot()
local hingeCFrame = doorHinge.CFrame

local pivotToHinge = DoorMath.computePivotToHinge(originalCFrame, hingeCFrame)

local function updateDoor(angle: number)
	local currentCFrame = DoorMath.getHingeCFrame(hingeCFrame, pivotToHinge, angle)
	doorPart:PivotTo(currentCFrame)
end

local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

local tween = DoorTween.new(CLOSED_ANGLE, tweenInfo, updateDoor)

local controller = DoorController.new({
	closedCFrame = CLOSED_ANGLE,
	openCFrame = OPEN_ANGLE + SPIN_EXTRA,
	tween = tween,
})

prompt.Triggered:Connect(function(player)
	controller:toggle(player)
end)
