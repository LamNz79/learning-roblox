local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EnemyService = require(script.Parent.EnemyService)
local WaveConfig = require(ReplicatedStorage.Shared.Constants.WaveConfig)
local WaveService = {}

local currentWave = 0
local isWaveActive = false

function WaveService.startWave(waveNumber: number)
	local waveData = WaveConfig[waveNumber]
	if not waveData then
		print("No more wave! Player win?")
		return
	end
	isWaveActive = true
	print(`--- WAVE   {waveNumber}   STARTING ---`)
	for _, group in ipairs(waveData.Enemies) do
		for i = 1, group.Amount do
			EnemyService.spawnEnemy(group.Type)
			task.wait(group.Delay)
		end
	end
	isWaveActive = false
	print(`--- WAVE   {waveNumber}   COMPLETED ---`)
end

function WaveService.init()
	task.spawn(function()
		while true do
			currentWave += 1
			local waveData = WaveConfig[currentWave]
			if not waveData then
				break
			end
			print(`Intermission:   {waveData.Intermission}   seconds...`)
			task.wait(waveData.Intermission)
			WaveService.startWave(currentWave)
		end
	end)
end
return WaveService
