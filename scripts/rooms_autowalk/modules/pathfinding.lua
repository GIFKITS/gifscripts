local module = {}

local pathfindingService = game:GetService("PathfindingService")
local runService = game:GetService("RunService")

local char = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/char.lua"))()
local move = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/move.lua"))()

module.pathfindingEnabled = false
module.updateRate = 2

module.agentParams = {
	AgentRadius = 1.5,
	AgentCanJump = false,
	WaypointSpacing = 1,
	Costs = {
		Avoid = math.huge,
	}
}

module.path = nil :: Path
module.targetPos = nil :: Vector3?
module.pathCompleted = false

module.waypoints = nil :: {PathWaypoint}
module.waypointIndex = 0

module.actions = {}
module.currentAction = nil

local lastUpdated = 0
local prevTargetPos = nil

local waypointRaycastParams = RaycastParams.new()
waypointRaycastParams.RespectCanCollide = true

function module.computeDistance(targetPos: Vector3)
	local totalDistance = 0
	local path = pathfindingService:CreatePath(module.agentParams)

	local success, err = pcall(function()
		path:ComputeAsync(char.root.Position, targetPos)
	end)
	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		local rootPos = char.root.Position
		local prevWaypointPos = nil

		for _,waypoint in pairs(waypoints) do
			local waypointPos = waypoint.Position
			if not prevWaypointPos then prevWaypointPos = rootPos end

			local distance = (prevWaypointPos - waypointPos).Magnitude
			totalDistance += distance
			prevWaypointPos = waypointPos
		end
	end
	return totalDistance == 0 and math.huge or totalDistance
end

function module.resetPath(recompute: boolean)
	module.path = nil
	module.pathCompleted = false

	module.waypoints = nil
	module.waypointIndex = 0
	getgenv().gifscript.moveVector = nil

	if recompute then prevTargetPos = nil end
end

function module.followWaypoints()
	if not module.waypoints or module.pathCompleted then return end

	if module.waypointIndex > #module.waypoints then
		module.pathCompleted = true
		getgenv().gifscript.moveVector = nil
		if module.currentAction and module.currentAction.pathCompleted then module.currentAction.pathCompleted:Fire() end
		return
	end

	local waypointPos = module.waypoints[module.waypointIndex].Position + Vector3.new(0, 1, 0)
	local rootPos = char.root.Position
	local direction: Vector3 = waypointPos - rootPos

	getgenv().gifscript.moveVector = direction.Unit
	waypointRaycastParams.FilterDescendantsInstances = {char.character}

	local raycast = workspace:Raycast(rootPos, direction, waypointRaycastParams)
	if raycast then module.resetPath(true) return end

	if (direction*Vector3.new(1,0,1)).Magnitude < 1 then module.waypointIndex += 1 end
end

function module.computePath()
	if not module.targetPos then module.resetPath(true) return end

	if prevTargetPos == module.targetPos then return end
	prevTargetPos = module.targetPos

	module.resetPath()
	module.path = pathfindingService:CreatePath(module.agentParams)

	local success, err = pcall(function()
		module.path:ComputeAsync(char.root.Position, module.targetPos)
	end)

	if success and module.path.Status == Enum.PathStatus.Success then
		module.waypoints = module.path:GetWaypoints()
		module.waypointIndex = 2
		return
	end

	module.resetPath(true)
end

function module.updateAction()
	module.currentAction = nil
	module.targetPos = nil

	local actions = {}

	for _,action in module.actions do
		table.insert(actions, action)
	end

	table.sort(actions, function(a, b)
		return a.priority > b.priority
	end)

	for _,action in actions do
		if not action.callback then continue end
		local targetPos: Vector3 = action.callback()
		if not targetPos then continue end

		module.currentAction = action
		module.targetPos = targetPos
		return targetPos
	end
end

function module.createAction(name, priority, callback)
	if module.actions[name] then error(string.format("An action with the name %q already exists", tostring(name))) end

	local action = {
		name = name,
		priority = priority,

		callback = callback,
		pathCompleted = Instance.new("BindableEvent"),
	}

	action.destroy = function()
		if module.currentAction == action then
			module.currentAction = nil
			module.targetPos = nil
			prevTargetPos = nil
			module.resetPath(false)
		end
		action.pathCompleted:Destroy()
		module.actions[name] = nil
	end

	module.actions[name] = action
	return action
end

function module.togglePathfinding(enable: boolean)
	if enable == module.pathfindingEnabled then return end
	module.pathfindingEnabled = enable
	if not enable then
		module.resetPath(true)
		module.currentAction = nil
		module.targetPos = nil
		getgenv().gifscript.moveVector = nil
	end
end

table.insert(getgenv().gifscript.connections, runService.Heartbeat:Connect(function()
	if not char.humanoid or not char.root or not module.pathfindingEnabled then return end
	module.followWaypoints()

	local currentTime = os.clock()
	if currentTime-lastUpdated < 1/module.updateRate then return end
	lastUpdated = currentTime

	module.updateAction()
	module.computePath()
end))

return module
