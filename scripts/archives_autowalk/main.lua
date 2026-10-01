local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

--local fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local char = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/archives_autowalk/modules/char.lua"))()
local pathfinding = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/archives_autowalk/modules/pathfinding.lua"))()

local gameDataFolder: Folder = replicatedStorage:WaitForChild("GameData")
local latestRoom: IntValue = gameDataFolder:WaitForChild("LatestRoom")
local currentRoomsFolder: Folder = workspace:WaitForChild("CurrentRooms")

local function setupRoom(room: Model)
	local door = room:FindFirstChild("door")
	if not door then return end
	for _,doorPart: BasePart in pairs(door:GetChildren()) do
		if doorPart.Name ~= "Door" then continue end
		doorPart.CanCollide = false
	end
end

pathfinding.createAction("door", 1, function()
	local room: Model = currentRoomsFolder:FindFirstChild(tostring(latestRoom.Value))
	if not room then return end
	
	setupRoom(room)
	return room:GetPivot().Position
end)

warn("success2")
