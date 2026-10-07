-- DATA --

local gifscript = getgenv().gifscript
local char = gifscript.char
local ui = gifscript.ui

local runService = game:GetService("RunService")
local httpsService = game:GetService("HttpService")

local camera = workspace.CurrentCamera

-- CREAK --

gifscript.entities.creak = {}
local creakData = gifscript.entities.creak

local creak: Model = nil
local creakHum: Humanoid = nil
local creakGraph: Animator = nil

local liveEntitiesFolder = workspace:WaitForChild("LiveEntities")

local function updateCreak()
	creak = liveEntitiesFolder:FindFirstChild("Creak")
	creakHum = creak and creak:FindFirstChildOfClass("Humanoid") or nil
	creakGraph = creakHum and creakHum.Animator.CreakGraph or nil
	creakData.model = creak
end

-- UI --

local section = ui.tabs.entities:AddSection("Creak")

local creakStatusLabel = section:AddParagraph({
	Title = "Creak:",
	Content = ""
})

local creakAngerLabel = section:AddParagraph({
	Title = "Current Anger:",
	Content = ""
})

-- LOOP --

table.insert(gifscript.connections, runService.Heartbeat:Connect(function()
	updateCreak()
	
	local creakState = httpsService:JSONDecode(creakGraph:GetAttribute("State"))
	creakData.anger = math.floor(creakState.Aggression*1000)/1000
	
	creakStatusLabel:SetDesc(creak and "found" or "not found")
	creakAngerLabel:SetDesc(creakData.anger or "unknown")
end))
