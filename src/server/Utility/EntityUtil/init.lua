--// Services

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables

--// Packages

--// Modules

--// Constants

--// Types

--//----------------------------------------------

local EntityUtil = {}

--------------------------------------------------------
-- Entity to player functions
--------------------------------------------------------

function EntityUtil.LookForTarget(model: Model, searchParams: { Radius: number, RequiresLOS: boolean })
	return Players:GetPlayers()[1]
end

function EntityUtil.HasDirectRouteToTarget(model: Model, target: Player)
	-- check using entity specifics

	return false
end

return EntityUtil
