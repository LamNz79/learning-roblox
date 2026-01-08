local DoorController = {}
DoorController.__index = DoorController

export type DoorControllerObject = {
	toggle: (self: DoorControllerObject, player: Player) -> (),
}

export type DoorControllerModule = {
	new: (config: { closedCFrame: any, openCFrame: any, tween: any }) -> DoorControllerObject,
}

function DoorController.new(config)
	local self = setmetatable({}, DoorController)

	self.closedCFrame = config.closedCFrame
	self.openCFrame = config.openCFrame
	self.tween = config.tween
	self.isOpen = false

	return self
end

function DoorController:toggle(player)
	if self.isOpen then
		self.tween:play(self.closedCFrame)
		self.isOpen = false
		print(player.Name .. " closed the door")
	else
		self.tween:play(self.openCFrame)
		self.isOpen = true
		print(player.Name .. " opened the door (SPIN!)")
	end
end

return DoorController
