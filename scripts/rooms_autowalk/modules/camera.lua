getgenv().gifscript.cameraDir = nil

for _, t in pairs(getreg() or {}) do
	if type(t) == "table" and rawget(t, "camSens") then
		local old = t.targetCameraTowardsDirection
		table.insert(getgenv().gifscript.hooks, {t, "targetCameraTowardsDirection", old})

		t.targetCameraTowardsDirection = function(self, dir, inst, ...)
			return old(self, getgenv().gifscript.cameraDir or dir, inst, ...)
		end

		table.insert(getgenv().gifscript.connections, game:GetService("RunService").RenderStepped:Connect(function()
			if getgenv().gifscript.cameraDir then t:targetCameraTowardsDirection(getgenv().gifscript.cameraDir, false) end
		end))
		break
	end
end
