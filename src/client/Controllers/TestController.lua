--// Services

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Variables

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

--// Packages

--// Modules

local Events = require(ReplicatedStorage.Shared.Networking.Events)

--// Constants

--// Types

--//----------------------------------------------

local TestController = {}

function TestController:Launch()
	workspace:WaitForChild("Part").Touched:Connect(function(touchedBy: BasePart)
		if touchedBy.Parent == localPlayer.Character then
			Events.Player.TouchPart:Send({})
		end
	end)

	Events.UI.ToggleTransition:Receive(function(data: { Visible: boolean })
		local multi = data.Visible and 0 or 1
		local transitionScreen = playerGui.transition
		local frame = transitionScreen.Frame :: Frame

		TweenService:Create(frame, TweenInfo.new(2), {
			Size = UDim2.fromOffset(10000 * multi, 10000 * multi),
		}):Play()
	end)
end

function TestController:Setup() end

return TestController
