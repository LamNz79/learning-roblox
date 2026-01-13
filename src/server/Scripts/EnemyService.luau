local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DoorTween = require(ReplicatedStorage.Shared.Utils.DoorTween)
local EnemyService = {}

function EnemyService.spawnEnemy()
	local template = ServerStorage.Entities:FindFirstChild("EnemyTemplate")

	if not template then
		return
	end

	local enemy = template:Clone() :: BasePart
	enemy.Parent = workspace
	local spawnPart = workspace.Map.SpawnPoint
	local goalPart = workspace.Map.Goal

	local function moveEnemy(fraction: number)
		enemy.Position = spawnPart.Position:Lerp(goalPart.Position, fraction)
	end

	local movement = DoorTween.new({
		initialValue = 0,
		tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear),
		updateCallback = moveEnemy,
	})

	movement:play(1)

	task.delay(10, function()
		enemy:Destroy()
	end)
end

function EnemyService.init()
	workspace:WaitForChild("Map")
	ServerStorage:WaitForChild("Entities"):WaitForChild("EnemyTemplate")
	task.wait(1)
	task.spawn(function()
		while true do
			EnemyService.spawnEnemy()
			task.wait(5)
		end
	end)
end

return EnemyService
