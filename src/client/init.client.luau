--// Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables

--// Packages

--// Modules

local NetworkEvents = require(ReplicatedStorage.Shared.Networking.Events)

--// Constants

--// Types

--//----------------------------------------------

NetworkEvents.Player.SomeoneJoin:Receive(function(data: { PlayerName: string })
	print("Player joined:", data.PlayerName)
end)
