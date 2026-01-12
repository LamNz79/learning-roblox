local TweenService = game:GetService("TweenService")

local DoorTween = {}
DoorTween.__index = DoorTween

export type DoorTweenObject = {
	-- Params
	initialValue: number,
	tweenInfo: TweenInfo,
	-- Methods
	updateCallback: (number) -> (),
	play: (self: DoorTweenObject, targetValue: number) -> (),
	Completed: RBXScriptSignal,
}

-- Changed: Now accepts an initial number value and a callback function
function DoorTween.new(params: DoorTweenObject): DoorTweenObject
	local self = setmetatable({}, DoorTween)

	-- We use a NumberValue instead of CFrameValue to support values > 360
	self.value = Instance.new("NumberValue")
	self.value.Value = params.initialValue
	self.tweenInfo = params.tweenInfo
	self.currentTween = TweenService:Create(self.value, self.tweenInfo, { Value = params.initialValue })
	-- Connect the callback: this runs every frame the tween updates
	self.value.Changed:Connect(function(newValue)
		params.updateCallback(newValue)
	end)

	self.tweenInfo = params.tweenInfo
	self.currentTween = nil

	return (self :: any) :: DoorTweenObject
end

function DoorTween:play(targetValue: number)
	if self.currentTween then
		self.currentTween:Cancel()
	end

	-- Tween the NumberValue
	self.currentTween = TweenService:Create(self.value, self.tweenInfo, { Value = targetValue })
	self.Completed = self.currentTween.Completed
	self.currentTween:Play()
end

return DoorTween
