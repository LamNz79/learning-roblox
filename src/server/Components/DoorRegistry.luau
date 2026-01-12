--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DoorTypes = require(ReplicatedStorage.Shared.Types.DoorTypes)
local DoorRegistry = {}
DoorRegistry.ActiveDoors = {} :: { [Model]: DoorTypes.DoorControllerObject }

return DoorRegistry
