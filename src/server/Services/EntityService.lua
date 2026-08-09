--!strict
--// Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

--// Variables

--// Packages

--// Modules

local Zombie = require(ServerScriptService.Server.Classes.Entities.Zombie)

--// Constants

--// Types

export type Entity = {
	Update: (self: any, delta: number) -> (),
}

--//----------------------------------------------

local EntityService = {
	Entities = {} :: { Entity },
}

function EntityService.Add(entity: any)
	table.insert(EntityService.Entities, entity :: Entity)
end

function EntityService.UpdateAll(delta: number)
	for _, entity in EntityService.Entities do
		entity:Update(delta)
	end
end

function EntityService.Launch()
	RunService.Heartbeat:Connect(function(delta: number)
		EntityService.UpdateAll(delta)
	end)
end

function EntityService.Setup()
	EntityService.Add(Zombie.new())
end

return EntityService
