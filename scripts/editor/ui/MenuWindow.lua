local GUIConf = require("ui/base/GUIConf")
local MenuWindow = GUI.Window:new(true, "MENU")

function MenuWindow:begin()
	self.w = GUIConf.border*12
	self.h = GUIConf.border*20

	-- Containers
	local c1
	-- Labels
	local w1
	-- Buttons
	local b1, b2, b3, b4, b5

	c1 = GUI.VContainer:new()
	c1:begin()

	w1 = GUI.Widget:new("")
	b1 = GUI.Button:new("About...")
	b1:begin(createAboutWindow)
	b1.userData = self
	b1.fixedH = 36

	b2 = GUI.Button:new("Save...")
	b2:begin()
	b2.fixedH = 36

	b3 = GUI.Button:new("Save as...")
	b3:begin()
	b3.fixedH = 36

	b4 = GUI.Button:new("Load...")
	b4:begin()
	b4.fixedH = 36

	b5 = GUI.Button:new("New...")
	b5:begin()
	b5.fixedH = 36

	c1:addWidget(b5)
	c1:addWidget(b2)
	c1:addWidget(b3)
	c1:addWidget(b4)
	c1:addWidget(w1)
	c1:addWidget(b1)

	self:setRootContainer(c1)

	GUI.addWindow(self)
end

return MenuWindow
