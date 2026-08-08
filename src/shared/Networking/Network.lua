--// Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Variables

local eventsFolder: Folder = nil

--// Packages

--// Modules

--// Constants

local IS_SERVER = RunService:IsServer()

--// Types

export type ServerToClientEvent<A> = {
	Send: (self: ServerToClientEvent<A>, player: Player, data: A) -> (),
	SendEveryone: (self: ServerToClientEvent<A>, data: A) -> (),
	Receive: (self: ServerToClientEvent<A>, callback: (data: A) -> ()) -> RBXScriptConnection,
}

export type ClientToServerEvent<A> = {
	Send: (self: ClientToServerEvent<A>, data: A) -> (),
	Receive: (self: ClientToServerEvent<A>, callback: (player: Player, data: A) -> ()) -> RBXScriptConnection,
}

type Direction = "ServerToClient" | "ClientToServer"
type Descriptor = {
	_direction: Direction,
	_path: { string }?,
	_remote: RemoteEvent?,
}

--//----------------------------------------------

if IS_SERVER then
	eventsFolder = Instance.new("Folder")
	eventsFolder.Name = "Events"
	eventsFolder.Parent = ReplicatedStorage
else
	eventsFolder = ReplicatedStorage:WaitForChild("Events")
end

--------------------------------------------------------------------------------

local Network = {}

--------------------------------------------------------
-- Local Methods
--------------------------------------------------------

local function getFolder(parent: Instance, name: string): Folder
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function getEvent(path: { string }): RemoteEvent
	local parent: Instance = eventsFolder
	for index = 1, #path - 1 do
		parent = getFolder(parent, path[index])
	end

	local eventName = path[#path]
	local event = parent:FindFirstChild(eventName)

	if not event then
		event = Instance.new("RemoteEvent")
		event.Name = eventName
		event.Parent = parent
	end

	return event
end

local function makeDescriptor(direction: Direction): Descriptor
	return {
		_direction = direction,
		_path = nil,
		_remote = nil,
	}
end

local function isDescriptor(value: any): boolean
	return type(value) == "table" and (value._direction == "ServerToClient" or value._direction == "ClientToServer")
end

local function initEvents(tbl: { [any]: any }, path: { string })
	for index, value in tbl do
		local newPath = table.clone(path)
		table.insert(newPath, tostring(index))

		if isDescriptor(value) then
			local descriptor = value :: Descriptor
			descriptor._path = newPath

			if IS_SERVER then
				descriptor._remote = getEvent(newPath)
			end
		elseif typeof(value) == "table" then
			initEvents(value, newPath)
		end
	end
end

local function resolveEvent(descriptor: Descriptor): RemoteEvent
	assert(descriptor._path, "Network event has no path")

	if not descriptor._remote then
		descriptor._remote = getEvent(descriptor._path)
	end

	assert(descriptor._remote, "Could not get remote for network event")

	return descriptor._remote
end

--------------------------------------------------------
-- Public Methods
--------------------------------------------------------

function Network.ServerToClient<A>(): ServerToClientEvent<A>
	local descriptor = makeDescriptor("ServerToClient")
	local event = descriptor :: any

	function event:Send(player: Player, data: A)
		assert(IS_SERVER, "ServerToClient:Send can only be called from the server")

		resolveEvent(descriptor):FireClient(player, data)
	end

	function event:SendEveryone(data: A)
		assert(IS_SERVER, "ServerToClient:SendEveryone can only be called from the Server")

		resolveEvent(descriptor):FireAllClients(data)
	end

	function event:Receive(callback: (data: A) -> ())
		assert(not IS_SERVER, "ServerToClient:Receive can only be called from the client")

		return resolveEvent(descriptor).OnClientEvent:Connect(callback)
	end

	return event
end

function Network.ClientToServer<A>(): ClientToServerEvent<A>
	local descriptor = makeDescriptor("ClientToServer")
	local event = descriptor :: any

	function event:Send(data: A)
		assert(not IS_SERVER, "ClientToServer:Send can only be called from the client")

		resolveEvent(descriptor):FireServer(data)
	end

	function event:Receive(callback: (Player, data: A) -> ())
		assert(IS_SERVER, "ClientToServer:Receive can only be called from the server")

		return resolveEvent(descriptor).OnServerEvent:Connect(callback)
	end

	return event
end

function Network.define<A>(definition: A): A
	initEvents(definition :: any, {})
	return definition
end

return Network
