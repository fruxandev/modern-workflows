local Network = require(script.Parent.Network)

--------------------------------------------------------
-- Player Events
--------------------------------------------------------

local playerJoinEvent: Network.ServerToClientEvent<{ PlayerName: string }> = Network.ServerToClient()

--------------------------------------------------------
-- UI Events
--------------------------------------------------------

return Network.define({
	Player = {
		SomeoneJoin = playerJoinEvent,
	},

	UI = {},
})
