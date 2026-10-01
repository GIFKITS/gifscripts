local module = {}

local pathfindingService = game:GetService("PathfindingService")
local runService = game:GetService("RunService")

local char = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/archives_autowalk/modules/char.lua"))()

module.pathfindingEnabled = true
module.updateRate = 2

module.agentParams = {
	AgentRadius = 1.5,
	AgentHeight = 5.0,
	AgentCanJump = false,
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

function module.resetPath(recompute: boolean)
	module.path = nil
	module.pathCompleted = false

	module.waypoints = nil
	module.waypointIndex = 0

	if char.humanoid then char.humanoid:MoveTo(char.root.Position) end
	if recompute then prevTargetPos = nil end
end

function module.followWaypoints()
	if not module.waypoints or module.pathCompleted then return end

	if module.waypointIndex > #module.waypoints then
		module.pathCompleted = true
		if module.currentAction and module.currentAction.pathCompleted then module.currentAction.pathCompleted:Fire() end
		return
	end

	local waypointPos = module.waypoints[module.waypointIndex].Position
	char.humanoid:MoveTo(waypointPos - char.root.Position)
	
	local rootPosition = char.root.Position
	local direction = waypointPos - rootPosition

	waypointRaycastParams.FilterDescendantsInstances = {char.character}

	local raycast = workspace:Raycast(rootPosition, direction, waypointRaycastParams)
	if raycast then module.resetPath(true) return end

	if (direction*Vector3.new(1,0,1)).Magnitude < 1 then module.waypointIndex += 1 end
end

function module.computePath()
	if not module.targetPos then module.resetPath(true) return end
	
	if prevTargetPos == module.targetPos and not module.pathCompleted then return end
	prevTargetPos = module.targetPos

	module.resetPath()
	module.path = pathfindingService:CreatePath(module.agentParams)

	local success, err = pcall(function()
		module.path:ComputeAsync(char.root.Position, module.targetPos)
	end)

	if success and module.path.Status == Enum.PathStatus.Success then
		module.waypoints = module.path:GetWaypoints()
		module.waypointIndex = 2
		warn("PATH SUCCESS")
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
	end
end

module.connection = runService.Heartbeat:Connect(function()
	if not char.humanoid or not char.root or not module.pathfindingEnabled then return end
	module.followWaypoints()
	
	local currentTime = os.clock()
	if currentTime-lastUpdated < 1/module.updateRate then return end
	lastUpdated = currentTime

	module.updateAction()
	module.computePath()
end)

return module
