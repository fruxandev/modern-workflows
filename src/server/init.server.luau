--// Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables

--// Packages

--// Modules

local NetworkEvents = require(ReplicatedStorage.Shared.Networking.Events)

--// Constants

--// Types

--//----------------------------------------------

task.wait(5)

NetworkEvents.Player.SomeoneJoin:SendEveryone({ PlayerName = "Aerovah" })
