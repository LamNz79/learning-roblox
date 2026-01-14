--!strict
local ButtonBase = {}
ButtonBase.__index = ButtonBase
export type ButtonControllerObject = {
	isClicked: boolean,
	model: Model,
	--Methods
	interact: (self: ButtonControllerObject, player: Player) -> (),
}
function ButtonBase.new(buttonModel: Model)
	local self = setmetatable({}, ButtonBase)
	self.isClicked = false
	self.model = buttonModel
	return (self :: any) :: ButtonControllerObject
end
function ButtonBase.interact(self: ButtonControllerObject, player)
	self.isClicked = not self.isClicked
	if self.isClicked then
		self.model:ScaleTo(0.5)
	else
		self.model:ScaleTo(1.0)
	end
end
return ButtonBase
