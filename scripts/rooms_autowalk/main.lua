getgenv().gifscript = {connections = {}}

local fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local pathfinding = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/pathfinding.lua"))()
getgenv().gifscript.pathfinding = pathfinding
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
		
		for _,connection in pairs(getgenv().gifscript.connections or {}) do
			connection:Disconnect()
		end
		table.remove(getgenv().gifscript)
		getgenv().gifscript = nil
		
		fluent:Destroy()
	end
})

-- PATHFINDING --

pathfinding.createAction("door", 1, function()
	return Vector3.new(264.300171, -0.401132464, -126.140739)
end)

warn("SUCCESS")
