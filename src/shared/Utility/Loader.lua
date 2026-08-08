export type Manager = {
	Setup: () -> (),
	Launch: () -> (),
}

local Loader = {}

function Loader.LoadManagers(folder: Folder)
	local managers = folder:GetChildren()
	local setup: { Manager } = {}

	for index, manager in managers do
		if manager:IsA("ModuleScript") then
			local accessed = require(manager) :: Manager
			accessed:Setup()
			table.insert(setup, accessed)

			print(`Successfully setup the manager: {manager.Name}!`)
		end
	end

	print("Launching managers!")

	for index, manager in setup do
		task.spawn(function()
			manager:Launch()
		end)
	end
end

return Loader
