getgenv().moveVector = nil
local char = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/archives_autowalk/modules/char.lua"))()

for _,t in pairs(getreg() or {}) do
	if type(t) ~= "table" or not rawget(t, "GetMoveVector") then continue end
	local getMoveVector = t.GetMoveVector
	t.GetMoveVector = function(self, ...)
		if getgenv().moveVector then 
			return Vector3.new(0, 0, -1)
		end
		return getMoveVector(self, ...)
	end
	break
end

return game:GetService("RunService").RenderStepped:Connect(function()
	if not char.humanoid and getgenv().moveVector then return end
	char.humanoid:Move(getgenv().moveVector)
end)
