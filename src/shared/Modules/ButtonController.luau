--!strict
local ButtonController = {}
ButtonController.__index = ButtonController
export type ButtonControllerObject = {
	isClicked: boolean,
	model: Model,
	--Methods
	interact: (self: ButtonControllerObject, player: Player) -> (),
}
function ButtonController.new(buttonModel: Model)
	local self = setmetatable({}, ButtonController)
	self.isClicked = false
	self.model = buttonModel
	return (self :: any) :: ButtonControllerObject
end
function ButtonController.interact(self: ButtonControllerObject, player)
	self.isClicked = not self.isClicked
	if self.isClicked then
		print(`{player.Name} just press this big red button`)
		self.model:ScaleTo(0.5)
	else
		self.model:ScaleTo(1.0)
	end
end
return ButtonController
