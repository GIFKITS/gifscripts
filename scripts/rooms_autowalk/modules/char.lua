local module = {}

local players = game:GetService("Players")
module.player = players.LocalPlayer

module.character = nil :: Model?
module.humanoid = nil :: Humanoid?
module.root = nil :: BasePart?

function module.updatePlayer()
	module.character = module.player.Character or module.player.CharacterAdded:Wait()
	module.humanoid = module.character:WaitForChild("Humanoid") :: Humanoid
	module.root = module.character:WaitForChild("HumanoidRootPart") :: BasePart
end

module.connection = module.player.CharacterAdded:Connect(module.updatePlayer)
module.updatePlayer()

return module
