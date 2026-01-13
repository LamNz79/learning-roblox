local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoorBase = require(ReplicatedStorage.Shared.Modules.DoorBase)
local DoorTypes = require(ReplicatedStorage.Shared.Types.DoorTypes)

export type HeavenDoorObject = DoorTypes.DoorControllerObject & {
	model: Model,
	Sound: Sound?,
}

local HeavenDoor = {}
HeavenDoor.__index = HeavenDoor
setmetatable(HeavenDoor, DoorBase)

function HeavenDoor.new(config: DoorTypes.DoorConfig, model: Model, sound: Sound?): HeavenDoorObject
	local self = DoorBase.new(config) :: any
	self.model = model
	self.sound = sound

	setmetatable(self, HeavenDoor)

	return self :: HeavenDoorObject
end

function HeavenDoor:toggle(player: Player)
	if self.isAnimating then
		return
	end
	if self.sound and not self.isOpen then
		self.sound:Play()
	end
	DoorBase.toggle(self, player)
end
return HeavenDoor
