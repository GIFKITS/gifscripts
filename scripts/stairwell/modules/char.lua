local gifscript = getgenv().gifscript
local char = {}

local players = game:GetService("Players")
local player = players.LocalPlayer

char.character = nil :: Model
char.humanoid = nil :: Humanoid
char.root = nil :: BasePart

function char.updateCharacter()
	char.character = player.Character or player.CharacterAdded:Wait()
	char.humanoid = char.character:FindFirstChildOfClass("Humanoid") or char.character:WaitForChild("Humanoid")
	char.root = char.character:WaitForChild("HumanoidRootPart")
end

table.insert(gifscript.connections, player.CharacterAdded:Connect(char.updateCharacter))
char.updateCharacter()

return char
