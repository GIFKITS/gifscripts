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

		t.ax_t = math.deg(yaw)
		t.ay_t = math.clamp(math.deg(pitch), -85, 70)
	end))
	break
end
