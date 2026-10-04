local module = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")

local currentRooms = workspace:WaitForChild("CurrentRooms")
local gameDataFolder = game.ReplicatedStorage:WaitForChild("GameData")
local latestRoom = gameDataFolder:WaitForChild("LatestRoom")

function module.getCurrentRoom()
	return currentRooms:FindFirstChild(tostring(latestRoom.Value))
end

function module.getDoor()
	return module.getCurrentRoom():FindFirstChild("Door")
end

function module.getClosestCloser()
	local lockers = collectionService:GetTagged("HidingSpot")
	local closestLocker = {nil, math.huge}
	
	for _,locker: Model in pairs(lockers or {}) do
		local pivot = locker:GetPivot()
		local distance = getgenv().gifscript.pathfinding.computeDistance(pivot.Position)
		if distance < closestLocker[2] then closestLocker[1] = locker closestLocker[2] = distance end
	end
	return closestLocker[1]
end

return module
