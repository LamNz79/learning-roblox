--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoorTypes = require(ReplicatedStorage.Shared.Types.DoorTypes)
local DoorBase = require(game.ReplicatedStorage.Shared.Modules.DoorBase)
export type LockedDoorObject = DoorTypes.DoorControllerObject & {
	isLocked: boolean,
	unlock: (self: LockedDoorObject) -> (),
}

local LockedDoor = {}
LockedDoor.__index = LockedDoor
setmetatable(LockedDoor, DoorBase)

function LockedDoor.new(config: DoorTypes.DoorConfig): LockedDoorObject
	local self = DoorBase.new(config) :: any
	self.isLocked = true

	setmetatable(self, LockedDoor)

	return self :: LockedDoorObject
end

function LockedDoor:toggle(player: Player)
	if self.isLocked then
		print("This door is locked! Cannot toggle")
		return
	end

	DoorBase.toggle(self, player)
end

function LockedDoor.unlock(self: LockedDoorObject)
	self.isLocked = false
	print("Door unlocked!")
end

return LockedDoor
