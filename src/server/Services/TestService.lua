--// Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables

--// Packages

--// Modules

local Events = require(ReplicatedStorage.Shared.Networking.Events)

--// Constants

--// Types

--//----------------------------------------------

local TestService = {
	CanToggleTransition = true,
	TransitionEnabled = false,
}

function TestService.Launch()
	Events.Player.TouchPart:Receive(function(player: Player, data: {})
		if not TestService.CanToggleTransition then
			return
		end

		TestService.CanToggleTransition = false
		TestService.TransitionEnabled = not TestService.TransitionEnabled
		Events.UI.ToggleTransition:SendEveryone({ Visible = TestService.TransitionEnabled })

		task.delay(5, function()
			TestService.CanToggleTransition = true
		end)
	end)
end

function TestService.Setup() end

return TestService
