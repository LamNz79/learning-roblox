--!strict
local DoorController = require(game.ReplicatedStorage.Shared.Controllers.DoorController)

export type LockedDoorObject = DoorController.DoorControllerObject & {
	isLocked: boolean,
	unlock: (self: LockedDoorObject) -> (),
}

local LockedDoor = {}
LockedDoor.__index = LockedDoor
setmetatable(LockedDoor, DoorController)

function LockedDoor.new(config): LockedDoorObject
	local self = DoorController.new(config) :: any

	setmetatable(self, LockedDoor)

	self.isLocked = true

	return self :: LockedDoorObject
end

function LockedDoor:toggle(player: Player)
	if self.isLocked then
		print("This door is locked! Cannot toggle")
		return
	end
	DoorController.toggle(self, player)
end

function LockedDoor.unlock(self: LockedDoorObject)
	self.isLocked = false
	print("Door unlocked!")
end

return LockedDoor
