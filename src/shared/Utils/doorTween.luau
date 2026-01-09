local TweenService = game:GetService("TweenService")

local DoorTween = {}
DoorTween.__index = DoorTween

export type DoorTweenObject = {
	play: (self: DoorTweenObject, targetValue: number) -> (),
	Completed: RBXScriptSignal,
	-- Add other internal properties if you want them visible, but 'play' is the important one
}

-- Changed: Now accepts an initial number value and a callback function
function DoorTween.new(initialValue: number, tweenInfo: TweenInfo, updateCallback: (number) -> ()): DoorTweenObject
	local self = setmetatable({}, DoorTween)

	-- We use a NumberValue instead of CFrameValue to support values > 360
	self.value = Instance.new("NumberValue")
	self.value.Value = initialValue
	self.tweenInfo = tweenInfo
	self.currentTween = TweenService:Create(self.value, self.tweenInfo, { Value = initialValue })
	-- Connect the callback: this runs every frame the tween updates
	self.value.Changed:Connect(function(newValue)
		updateCallback(newValue)
	end)

	self.tweenInfo = tweenInfo
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
