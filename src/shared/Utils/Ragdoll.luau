local Ragdoll = {}

function Ragdoll.apply(character: Model, duration: number)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	humanoid.RequiresNeck = false
	humanoid.PlatformStand = true

	for _, motor in character:GetDescendants() do
		if motor:IsA("Motor6D") then
			-- 1. Narrow the types of Part0 and Part1
			local p0: BasePart? = motor.Part0
			local p1: BasePart? = motor.Part1

			-- 2. Only proceed if BOTH parts exist
			if p0 and p1 then
				motor.Enabled = false

				-- Now Luau knows p0 and p1 are BaseParts, so FindFirstChild is safe
				local a0 = p0:FindFirstChild(`{motor.Name}RigAttachment`) or p0:FindFirstChildOfClass("Attachment")
				local a1 = p1:FindFirstChild(`{motor.Name}RigAttachment`) or p1:FindFirstChildOfClass("Attachment")

				if a0 and a1 and a0:IsA("Attachment") and a1:IsA("Attachment") then
					local socket = Instance.new("BallSocketConstraint")
					socket.LimitsEnabled = true
					socket.UpperAngle = 45 -- Prevents the limb from bending more than 45 degrees
					socket.TwistLimitsEnabled = true
					socket.TwistLowerAngle = -40
					socket.TwistUpperAngle = 40
					socket.Name = "RagdollSocket"
					socket.Attachment0 = a0
					socket.Attachment1 = a1
					socket.Parent = motor.Parent
				end
			end
		end
	end

	task.delay(duration, function()
		if not character.Parent then
			return
		end
		for _, motor in character:GetDescendants() do
			if motor:IsA("Motor6D") then
				motor.Enabled = true
			end
		end
		humanoid.PlatformStand = false
		humanoid.RequiresNeck = true
	end)
end

return Ragdoll
