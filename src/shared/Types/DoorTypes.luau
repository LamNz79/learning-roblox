--!strict
local DoorTween = require(game.ReplicatedStorage.Shared.Utils.DoorTween)

export type DoorConfig = {
	closedCFrame: number,
	openCFrame: number,
	tween: DoorTween.DoorTweenObject,
}

export type DoorControllerObject = {
	closedCFrame: number,
	openCFrame: number,
	tween: DoorTween.DoorTweenObject,
	isAnimating: boolean,
	isOpen: boolean,
	toggle: (self: DoorControllerObject, player: Player) -> (),
	handleTouch: (self: DoorControllerObject, otherPart: BasePart, hingePosition: Vector3, smashForce: number) -> (),
}

-- Use '&' to extend the base type for the locked version
export type LockedDoorObject = DoorControllerObject & {
	isLocked: boolean,
	unlock: (self: LockedDoorObject) -> (),
}

return nil
