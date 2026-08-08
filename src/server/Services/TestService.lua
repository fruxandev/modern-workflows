--// Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables

--// Packages

--// Modules

local Events = require(ReplicatedStorage.Shared.Networking.Events)

--// Constants

--// Types

--//----------------------------------------------

local TestService = {}

function TestService:Launch()
	Events.Player.TouchPart:Receive(function(player: Player, data: {})
		if not self.CanToggleTransition then
			return
		end

		self.CanToggleTransition = false
		self.TransitionEnabled = not self.TransitionEnabled
		Events.UI.ToggleTransition:SendEveryone({ Visible = self.TransitionEnabled })

		task.delay(5, function()
			self.CanToggleTransition = true
		end)
	end)
end

function TestService:Setup()
	self.TransitionEnabled = false
	self.CanToggleTransition = true
end

return TestService
