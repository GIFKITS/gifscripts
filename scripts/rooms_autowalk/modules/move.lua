getgenv().gifscript.moveVector = nil
local char = loadstring(game:HttpGet("https://raw.githubusercontent.com/GIFKITS/gifscripts/refs/heads/main/scripts/rooms_autowalk/modules/char.lua"))()

for _,t in pairs(getreg() or {}) do
	if type(t) ~= "table" or not rawget(t, "GetMoveVector") then continue end
	local getMoveVector = t.GetMoveVector
	
	table.insert(getgenv().gifscript.hooks, {
		t, "GetMoveVector", getMoveVector
	})
	
	t.GetMoveVector = function(self, ...)
		if getgenv().gifscript.moveVector then 
			return Vector3.new(0, 0, -1)
		end
		return getMoveVector(self, ...)
	end
	break
end

table.insert(getgenv().gifscript.connections, game:GetService("RunService").RenderStepped:Connect(function()
	if not char.humanoid or not getgenv().gifscript.moveVector then return end
	char.humanoid:Move(getgenv().gifscript.moveVector)
end))
