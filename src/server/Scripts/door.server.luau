--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Server = ServerScriptService:WaitForChild("Server")

local DoorMathModule = require(Shared.Math:WaitForChild("doorMath"))
local DoorTweenModule = require(Shared.Utils:WaitForChild("doorTween"))
local DoorControllerModule = require(Server.Components:WaitForChild("doorController"))

local DoorMath = DoorMathModule :: typeof(require(game.ReplicatedStorage.Shared.Math.doorMath))
local DoorTween = DoorTweenModule :: typeof(require(game.ReplicatedStorage.Shared.Utils.doorTween))
local DoorController =
	DoorControllerModule :: typeof(require(game.ServerScriptService.Server.Components.doorController))

local doorModel = workspace:WaitForChild("DoorModel")
local doorPart = doorModel.PrimaryPart
local doorHinge = doorModel:WaitForChild("doorHinge")
local prompt = doorHinge:WaitForChild("ProximityPrompt")

local CLOSED_ANGLE = 0
local OPEN_ANGLE = 160
local SPIN_EXTRA = 0

local originalCFrame = doorModel:GetPivot()
local hingeCFrame = doorHinge.CFrame

local pivotToHinge = DoorMath.computePivotToHinge(originalCFrame, hingeCFrame)

local function updateDoor(angle: number)
	local currentCFrame = DoorMath.getHingeCFrame(hingeCFrame, pivotToHinge, angle)
	doorPart:PivotTo(currentCFrame)
end

local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

local tween = DoorTween.new(CLOSED_ANGLE, tweenInfo, updateDoor)

local controller = DoorController.new({
	closedCFrame = CLOSED_ANGLE,
	openCFrame = OPEN_ANGLE + SPIN_EXTRA,
	tween = tween,
})

prompt.Triggered:Connect(function(player)
	controller:toggle(player)
end)
