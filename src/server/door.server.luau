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

local DoorMathModule = require(script.Parent:WaitForChild("doorMath"))
local DoorTweenModule = require(script.Parent:WaitForChild("doorTween"))
local DoorControllerModule = require(script.Parent:WaitForChild("doorController"))

-- 2. "Cast" them to the types we exported above
-- Note: In Rojo/VSCode, you often have to access the type via the file path logic or just rely on the require if the extension is smart enough.
-- However, the most reliable way for `WaitForChild` (which returns 'Instance') is this:

local DoorMath = DoorMathModule :: typeof(require(script.Parent.doorMath))
local DoorTween = DoorTweenModule :: typeof(require(script.Parent.doorTween))
local DoorController = DoorControllerModule :: typeof(require(script.Parent.doorController))

local doorModel = workspace:WaitForChild("DoorModel")
local doorPart = doorModel.PrimaryPart
local doorHinge = doorModel:WaitForChild("doorHinge")
local prompt = doorPart:WaitForChild("ProximityPrompt")

local CLOSED_ANGLE = 0
local OPEN_ANGLE = 90
local SPIN_EXTRA = 360 -- 3 full spins (360 * 3)

local originalCFrame = doorModel:GetPivot()
local hingeCFrame = doorHinge.CFrame

local pivotToHinge = DoorMath.computePivotToHinge(originalCFrame, hingeCFrame)

-- 1. Create a function that updates the door based on the current angle
local function updateDoor(angle)
	local currentCFrame = DoorMath.getHingeCFrame(hingeCFrame, pivotToHinge, angle)
	doorPart:PivotTo(currentCFrame)
end

local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

-- 2. Create the tween, passing the Starting Angle (0) and the Update Function
local tween = DoorTween.new(CLOSED_ANGLE, tweenInfo, updateDoor)

-- 3. Pass the TARGET ANGLES (Numbers) to the controller instead of CFrames
-- The controller will pass these numbers to tween:play()
local controller = DoorController.new({
	closedCFrame = CLOSED_ANGLE, -- Passing 0
	openCFrame = OPEN_ANGLE + SPIN_EXTRA, -- Passing 1170
	tween = tween,
})

prompt.Triggered:Connect(function(player)
	controller:toggle(player)
end)
