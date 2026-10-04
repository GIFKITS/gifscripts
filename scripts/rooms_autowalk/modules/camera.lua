getgenv().gifscript.cameraDirection = nil

for _, t in pairs(getreg() or {}) do
	if type(t) ~= "table" or not rawget(t, "camSens") then continue end
	local old = t.targetCameraTowardsDirection
	table.insert(getgenv().gifscript.hooks, {t, "targetCameraTowardsDirection", old})

	t.targetCameraTowardsDirection = function(self, dir, inst, ...)
		if getgenv().gifscript.cameraDirection then return end
		return old(self, dir, inst, ...)
	end

	table.insert(getgenv().gifscript.connections, game:GetService("RunService").RenderStepped:Connect(function()
		local dir = getgenv().gifscript.cameraDirection
		if not dir then return end

		local pitch, yaw, _ = CFrame.new(Vector3.zero, dir):ToOrientation()
		local smoothness = 0.1
		
		t.ax_t = t.ax_t + ((math.deg(yaw) - t.ax_t + 180) % 360 - 180) * smoothness
		t.ay_t = t.ay_t + (math.clamp(math.deg(pitch), -85, 70) - t.ay_t) * smoothness
	end))
	break
end
