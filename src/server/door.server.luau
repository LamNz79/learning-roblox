local doorModel = workspace:WaitForChild("DoorModel")
local doorPart = doorModel.PrimaryPart

local doorHinge = doorModel:WaitForChild("doorHinge")
local prompt = doorPart:WaitForChild("ProximityPrompt")
local isOpen = false

-- Store the original pivot and hinge position
local originalCFrame = doorModel:GetPivot()
local hingePosition = doorHinge.Position
print("originalCFrame", originalCFrame)
print("hingePosition", hingePosition)
-- Calculate the offset from the model's pivot to the hinge
local pivotToHinge = originalCFrame:Inverse() * CFrame.new(hingePosition)
print("pivotToHinge", pivotToHinge)
-- Pre-calculate the open position (90° rotation around Y-axis)
-- This rotates the door around the hinge point
local openCFrame = CFrame.new(hingePosition) * CFrame.Angles(0, math.rad(90), 0) * pivotToHinge:Inverse()

prompt.Triggered:Connect(function(player)
	if isOpen then
		-- Rotate back to closed
		doorPart:PivotTo(originalCFrame)
		isOpen = false
		print(player.Name .. " closed the door")
	else
		-- Rotate to open around the hinge
		doorPart:PivotTo(openCFrame)
		isOpen = true
		print(player.Name .. " opened the door")
	end
end)
