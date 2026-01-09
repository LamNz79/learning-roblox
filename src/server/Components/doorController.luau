local DoorController = {}
DoorController.__index = DoorController
local DoorTween = require(game.ReplicatedStorage.Shared.Utils.doorTween)
export type DoorControllerObject = {
	toggle: (self: DoorControllerObject, player: Player) -> (),
	handleTouch: (self: DoorControllerObject, otherPart: BasePart, hingePosition: Vector3, smashForce: number) -> (),
	isAnimating: boolean,
	isOpen: boolean,
	isAnimating: boolean,
	tween: DoorTween.DoorTweenObject,
}

function DoorController.new(config): DoorControllerObject
	local self = setmetatable({}, DoorController)
	self.closedCFrame = config.closedCFrame
	self.openCFrame = config.openCFrame
	self.tween = config.tween
	self.isOpen = false
	self.isAnimating = false
	return (self :: any) :: DoorControllerObject
end

function DoorController:toggle(player)
	if self.isAnimating then
		return
	end
	self.isAnimating = true
	if self.isOpen then
		self.tween:play(self.closedCFrame)
		self.isOpen = false
		self.tween.Completed:Once(function()
			self.isAnimating = false
		end)
		print(player.Name .. " closed the door")
	else
		self.tween:play(self.openCFrame)
		self.isOpen = true
		self.tween.Completed:Once(function()
			self.isAnimating = false
		end)

		print(player.Name .. " opened the door (SPIN!)")
	end
end

function DoorController:handleTouch(otherPart: BasePart, hingePosition: Vector3, smashForce: number)
	local character = otherPart.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart

	if humanoid and rootPart and not rootPart:FindFirstChild("SmashForce") then
		if self.isOpen == false and self.isAnimating == true then
			local attachment = Instance.new("Attachment")
			attachment.Parent = rootPart

			local force = Instance.new("LinearVelocity")
			force.Name = "SmashForce"
			force.MaxForce = 2000000

			local direction = (rootPart.Position - hingePosition).Unit
			force.VectorVelocity = (direction + Vector3.new(0, 0.8, 0)) * (smashForce * 1.5)
			force.Attachment0 = attachment
			force.Parent = rootPart

			humanoid.PlatformStand = true
			task.delay(0.2, function()
				force:Destroy()
				attachment:Destroy()
				task.wait(1)
				humanoid.PlatformStand = false
			end)
		end
	end
end

return DoorController
