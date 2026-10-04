getgenv().gifscript.cameraDirection = nil

for _, t in pairs(getreg() or {}) do
	if type(t) == "table" and rawget(t, "camSens") then
		local old = t.targetCameraTowardsDirection
		table.insert(getgenv().gifscript.hooks, {t, "targetCameraTowardsDirection", old})

		t.targetCameraTowardsDirection = function(self, dir, inst, ...)
			return old(self, getgenv().gifscript.cameraDirection or dir, inst, ...)
		end

		table.insert(getgenv().gifscript.connections, game:GetService("RunService").RenderStepped:Connect(function()
			if getgenv().gifscript.cameraDirection then t:targetCameraTowardsDirection(getgenv().gifscript.cameraDirection, false) end
		end))
		break
	end
end
