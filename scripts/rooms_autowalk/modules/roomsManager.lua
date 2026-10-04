local module = {}

local char = getgenv().gifscript.char

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

function module.getLockerPos(locker: Model)
	local base = locker:FindFirstChild("Base")
	if not base then return end
	local attachment = base:FindFirstChild("EnterAttachment")
	return attachment and attachment.WorldPosition or nil
end

function module.getClosestLocker()
	local lockers = collectionService:GetTagged("HidingSpot")
	local closestLocker = {nil, math.huge}

	for _,locker: Model in pairs(lockers or {}) do
		local lockerPos = module.getLockerPos(locker)
		if not lockerPos then continue end

		local distance = (char.root.Position - lockerPos).Magnitude
		if distance < closestLocker[2] then closestLocker[1] = locker closestLocker[2] = distance end
	end
	return closestLocker[1]
end

return module
