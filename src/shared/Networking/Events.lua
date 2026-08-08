local Network = require(script.Parent.Network)

--------------------------------------------------------
-- Player Events
--------------------------------------------------------

--------------------------------------------------------
-- UI Events
--------------------------------------------------------

local touchPartEvent: Network.ClientToServerEvent<{}> = Network.ClientToServer()
local transitionEvent: Network.ServerToClientEvent<{ Visible: boolean }> = Network.ServerToClient()

return Network.define({
	Player = {
		TouchPart = touchPartEvent,
	},

	UI = {
		ToggleTransition = transitionEvent,
	},
})
