--!strict
local DoorConstants = {
	SMASH_FORCE = 10,
	OPEN_ANGLE = 160,
	CLOSE_ANGLE = 0,
	TWEEN_TIME = 0.5,
	SPIN_EXTRA = 0,
}

return table.freeze(DoorConstants) -- Use freeze so other scripts can't change them
