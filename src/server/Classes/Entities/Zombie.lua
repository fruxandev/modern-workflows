--!strict
--// Services

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Variables

local entityModels = ReplicatedStorage.Assets.Models.Entity

--// Packages

-- local Promise = require(ReplicatedStorage.Packages.Promise)
local Promise = require(ReplicatedStorage.Packages.Promise)

--// Modules

local EntityUtil = require(ServerScriptService.Server.Utility.EntityUtil)

--// Constants

local ZOMBIE_TARGET_RADIUS = 50
local REPATH_DISTANCE = 5

--// Types

type Promise = typeof(Promise.new(function() end))

--//----------------------------------------------

local Zombie = {}
Zombie.__index = Zombie

export type Zombie = typeof(setmetatable(
	{} :: {
		Health: number,
		Model: Model,
		Humanoid: Humanoid,
		Target: Player?,

		PathController: Path,
		Path: Promise?,
		PathDestination: Vector3?,

		State: {
			MoveElapsed: number,
		},
	},
	Zombie
))

function Zombie.new(): Zombie
	local self = setmetatable({}, Zombie)

	-- Create Zombie Model

	local zombieModel = entityModels.Zombie:Clone()
	zombieModel.Parent = workspace.Entities

	-- Properties

	self.Health = 100
	self.Humanoid = zombieModel.Humanoid
	self.Model = zombieModel
	self.Model.PrimaryPart:SetNetworkOwner(nil)
	self.PathController = PathfindingService:CreatePath({
		AgentRadius = 4,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = false,
		WaypointSpacing = 4,
		Costs = {},
	})

	self.State = {
		MoveElapsed = 0,
	}

	-- Cancel path if the PathController gets blocked
	self.PathController.Blocked:Connect(function(blockedWaypointIndex: number)
		self:cancelPath()
	end)

	return self
end

function Zombie.TakeDamage(self: Zombie, damage: number)
	self:setHealth(math.clamp(self.Health - damage, 0, 100))
end

function Zombie.Update(self: Zombie, deltaTime: number)
	-- If there is no target then look for one
	if not self.Target then
		self.Target = EntityUtil.LookForTarget(self.Model, {
			Radius = ZOMBIE_TARGET_RADIUS,
			RequiresLOS = true,
		})
	end

	-- Verify our target is valid
	self:verifyTarget()

	-- If there's still no target then cancel any path and do nothing
	if not self.Target then
		self:cancelPath()
		return
	end

	-- Target behavior

	-- Check if we are in radius to attack

	-- Check if we can directly walk to the target, otherwise attempt to pathfind.
	if EntityUtil.HasDirectRouteToTarget(self.Model, self.Target) then
		self:cancelPath()

		print("has direct route to target:", self.Target)

		-- Move to target
		self.State.MoveElapsed += deltaTime
		if self.State.MoveElapsed > 0.1 then
			self.State.MoveElapsed = 0
			self.Humanoid:MoveTo((self.Target.Character :: Model):GetPivot().Position)
		end

		return
	end

	self:updatePath()
end

--------------------------------------------------------
-- Private Methods
--------------------------------------------------------

local id = 0
function Zombie.updatePath(self: Zombie)
	-- Make sure we have a target and character.
	if not self.Target or not self.Target.Character then
		return
	end

	-- Current position and our target destination
	local zombiePos: Vector3 = self.Model:GetPivot().Position
	local targetPos: Vector3 = self.Target.Character:GetPivot().Position

	-- Check if there is an active path promise already
	-- If the active path doesn't need to be recalculated then return
	if self.Path and self.Path:getStatus() == "Started" then
		-- If the target hasn't moved far
		if ((self.PathDestination :: Vector3) - targetPos).Magnitude <= REPATH_DISTANCE then
			return
		end

		-- At some point add a check in here for stuck zombies?
	end

	-- Cancel the path promise if there is one
	self:cancelPath()

	-- Start a new path promise to move the zombie to waypoints
	self.Path = Promise.new(function(resolve, reject: (...any) -> (), onCancel: (abortHandler: (() -> ())?) -> boolean)
		id += 1
		warn("Zombie is calculating new path, id:", id)

		-- Compute the path waypoints
		self.PathDestination = targetPos
		self.PathController:ComputeAsync(zombiePos, targetPos)

		if onCancel() then
			return
		end

		local waypoints = self.PathController:GetWaypoints()
		table.remove(waypoints, 1) -- first waypoint isn't needed (counts as zombie position)
		for _, waypoint in waypoints do
			-- Breaks if the promise was cancelled and for some reason loop is continued.
			if onCancel() then
				break
			end

			-- Move to the waypoint

			if waypoint.Action == Enum.PathWaypointAction.Jump then
				self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end

			self.Humanoid:MoveTo(waypoint.Position)
			self.Humanoid.MoveToFinished:Wait()
		end
	end)
end

function Zombie.cancelPath(self: Zombie)
	if self.Path and self.Path:getStatus() == "Started" then
		self.Path:cancel()
	end
end

function Zombie.verifyTarget(self: Zombie)
	if not self.Target then
		return
	end

	-- If target is not a player then invalid
	if not self.Target:IsA("Player") then
		self.Target = nil
		return
	end

	-- If target doesn't have a character then invalid
	if not self.Target.Character then
		self.Target = nil
		return
	end
end

function Zombie.setHealth(self: Zombie, health: number)
	self.Health = health
end

function Zombie:Destroy() end

return Zombie
