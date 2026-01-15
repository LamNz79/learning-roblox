local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local EnemyConfig = require(ReplicatedStorage.Shared.Constants.EnemyConfig)
local DoorTween = require(ReplicatedStorage.Shared.Utils.DoorTween)
local EnemyService = {}

function EnemyService.spawnEnemy(enemyType: string)
	local config = EnemyConfig[enemyType]
	if not config then
		warn("Enemy type not found in config: " .. enemyType)
		return
	end
	local template = ServerStorage.Entities:FindFirstChild("EnemyTemplate")

	if not template then
		return
	end

	local enemy = template:Clone() :: BasePart

	local spawnPart = workspace.Map.SpawnPoint
	local goalPart = workspace.Map.Goal
	enemy.Position = spawnPart.Position
	enemy.Parent = workspace

	local function moveEnemy(fraction: number)
		if not enemy or not enemy.Parent then
			return
		end
		enemy.Position = spawnPart.Position:Lerp(goalPart.Position, fraction)
	end

	local movement = DoorTween.new({
		initialValue = 0,
		tweenInfo = TweenInfo.new(config.Speed, Enum.EasingStyle.Linear),
		updateCallback = moveEnemy,
	})

	movement:play(1)

	task.delay(config.Speed, function()
		if enemy and enemy.Parent then
			enemy:Destroy()
		end
	end)
end

function EnemyService.init(enemyType: string)
	workspace:WaitForChild("Map")
	ServerStorage:WaitForChild("Entities"):WaitForChild("EnemyTemplate")
	print("EnemyService: Ready to receive spawn commands.")
end

return EnemyService
