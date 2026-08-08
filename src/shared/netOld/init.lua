-- local Players = game:GetService("Players")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local RunService = game:GetService("RunService")

-- local IS_SERVER = RunService:IsServer()

-- local network = {}

-- network.player = {}
-- network.inventory = {}
-- network.ui = {}
-- network.misc = {}

-- local eventsFolder = nil
-- if RunService:IsServer() then
-- 	eventsFolder = Instance.new("Folder")
-- 	eventsFolder.Name = "Events"
-- 	eventsFolder.Parent = ReplicatedStorage

-- 	for group in network do
-- 		local folder = Instance.new("Folder")
-- 		folder.Name = group
-- 		folder.Parent = eventsFolder
-- 	end
-- else
-- 	eventsFolder = ReplicatedStorage:WaitForChild("Events")
-- end

-- type ServerToClientEvent<A...> = {
-- 	send: (self: ServerToClientEvent<A...>, player: Player, A...) -> (),
-- 	sendAll: (self: ServerToClientEvent<A...>, A...) -> (),
-- 	sendPredicate: (self: ServerToClientEvent<A...>, predicate: (player: Player) -> boolean, A...) -> (),
-- }

-- type ServerReceiver<A...> = {
-- 	receive: (self: ServerReceiver<A...>, callback: (player: Player, A...) -> ()) -> RBXScriptConnection,
-- }

-- type ClientToServerEvent<A...> = {
-- 	send: (self: ClientToServerEvent<A...>, A...) -> (),
-- }

-- type ClientReceiver<A...> = {
-- 	receive: (self: ClientReceiver<A...>, callback: (A...) -> ()) -> RBXScriptConnection,
-- }

-- local function getRemote(group: string, name: string)
-- 	local remote = eventsFolder[group]:FindFirstChild(name)

-- 	if not remote then
-- 		remote = Instance.new("RemoteEvent")
-- 		remote.Name = name
-- 		remote.Parent = eventsFolder[group]
-- 	end

-- 	return remote
-- end

-- local function clientToServerEvent<A...>(group: string, name: string): ClientToServerEvent<A...>
-- 	local remote = getRemote(group, name)
-- 	return {
-- 		send = function(_, ...: A...)
-- 			remote:FireServer(...)
-- 		end,
-- 	}
-- end

-- local function clientReceiver<A...>(group: string, name: string): ClientReceiver<A...>
-- 	local remote = getRemote(group, name)
-- 	return {
-- 		receive = function(_, callback: (A...) -> ())
-- 			return remote.OnClientEvent:Connect(callback)
-- 		end,
-- 	}
-- end

-- local function serverToClientEvent<A...>(group: string, name: string): ServerToClientEvent<A...>
-- 	local remote = getRemote(group, name)
-- 	return {
-- 		send = function(_, player: Player, ...: A...)
-- 			remote:FireClient(player, ...)
-- 		end,

-- 		sendAll = function(_, ...: A...)
-- 			remote:FireAllClients(...)
-- 		end,

-- 		sendPredicate = function(_, predicate: (Player) -> boolean, ...: A...)
-- 			for _, player in Players:GetPlayers() do
-- 				if predicate(player) then
-- 					remote:FireClient(player, ...)
-- 				end
-- 			end
-- 		end,
-- 	}
-- end

-- local function serverReceiver<A...>(group: string, name: string): ServerReceiver<A...>
-- 	local remote = getRemote(group, name)
-- 	return {
-- 		receive = function(_, callback: (Player, A...) -> ())
-- 			return remote.OnServerEvent:Connect(callback)
-- 		end,
-- 	}
-- end

-- if IS_SERVER then
-- 	-- // send events
-- 	local sendMessage: ServerToClientEvent<string> = serverToClientEvent("Misc", "SendMessage")

-- 	-- // receive events
-- 	local receiveMessage: ServerReceiver<string> = serverReceiver("Misc", "ReceiveMessage")
-- else
-- end

-- export type Network = {

-- }

-- return network
