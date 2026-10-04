if getgenv().gifscript then warn("script already exist") return end
warn("Loading...")

getgenv().gifscript = {}
getgenv().gifscript.connections = {}
getgenv().gifscript.hooks = {}

local char = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/char.lua"))()
getgenv().gifscript.char = char

local move = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/move.lua"))()
local camera = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/camera.lua"))()

local fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local pathfinding = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/pathfinding.lua"))()
local roomsManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/roomsManager.lua"))()

-- UI --

local window = fluent:CreateWindow({
	Title = "Rooms Autowalk",
	SubTitle = "by gifkits",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = false,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftAlt
})

local tabs = {
	main = window:AddTab({Title = "Main", Icon = "" }),
}

tabs.main:AddToggle("enablePathfinding", {
	Title = "Enable Pathfinding",
	Default = false,
	Callback = function(value)
		pathfinding.togglePathfinding(value)
	end,
})

tabs.main:AddButton({
	Title = "Unload",
	Description = "Unload the script",
	Callback = function()
		pathfinding.togglePathfinding(false)
		
		for _,hook in pairs(getgenv().gifscript.hooks or {}) do
			hook[1][hook[2]] = hook[3]
		end
		for _,connection in pairs(getgenv().gifscript.connections or {}) do
			connection:Disconnect()
		end
		
		getgenv().gifscript = nil
		warn("Unloaded")
		fluent:Destroy()
	end
})

-- PATHFINDING --

local playerGui = char.player:WaitForChild("PlayerGui")
local mainUI = playerGui:WaitForChild("MainUI")

local A90: Frame = mainUI:WaitForChild("Jumpscare"):WaitForChild("Jumpscare_A90")
local targetLocker: Model = nil

pathfinding.createAction("door", 1, function()
	local door: Model = roomsManager.getDoor()
	return door and door:GetPivot().Position or nil
end)

local lockerAction = pathfinding.createAction("locker", 2, function()
	local danger = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
	if not danger then return end
	
	local locker = roomsManager.getClosestLocker()
	targetLocker = locker
	return locker and roomsManager.getLockerPos(locker) or nil
end)

table.insert(getgenv().gifscript.connections, lockerAction.pathCompleted.Event:Connect(function()
	if not targetLocker then return end
	
	local lockerPosition = targetLocker:GetPivot().Position
	local prompt = targetLocker:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then return end
	
	if A90.Visible then
		repeat task.wait() until not A90.Visible
	end
	
	getgenv().gifscript.cameraDirection = (lockerPosition - workspace.CurrentCamera.CFrame.Position).Unit
	task.wait(.2)
	fireproximityprompt(prompt)
	getgenv().gifscript.cameraDirection = nil
end))

pathfinding.createAction("a90", 3, function()
	return A90.Visible and Vector3.one * math.huge or nil
end)

warn("Loading Completed")
