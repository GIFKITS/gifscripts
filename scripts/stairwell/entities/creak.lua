local gifscript = getgenv().gifscript
local char = gifscript.char
local ui = gifscript.ui

gifscript.entities.creak = {}
local creakData = gifscript.entities.creak

local section = ui.tabs.entities:AddSection("Creak")

local creakAngerLabel = ui.tabs.entities:AddParagraph({
	Title = "Current Anger",
	Content = "0.0000"
})
