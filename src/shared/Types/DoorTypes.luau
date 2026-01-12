--!strict
local DoorTween = require(game.ReplicatedStorage.Shared.Utils.DoorTween)

export type DoorConfig = {
	closedCFrame: number,
	openCFrame: number,
	tween: DoorTween.DoorTweenObject,
}

export type DoorBaseObject = {
	closedCFrame: number,
	openCFrame: number,
	tween: DoorTween.DoorTweenObject,
	isAnimating: boolean,
	isOpen: boolean,
	toggle: (self: DoorBaseObject, player: Player) -> (),
	handleTouch: (self: DoorBaseObject, otherPart: BasePart, hingePosition: Vector3, smashForce: number) -> (),
}

-- Use '&' to extend the base type for the locked version
export type LockedDoorObject = DoorBaseObject & {
	isLocked: boolean,
	unlock: (self: LockedDoorObject) -> (),
}

return nil
