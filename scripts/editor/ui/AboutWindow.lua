local AboutWindow = GUI.Window:new(true, "About")

function AboutWindow:onOk()
  self:close()
end

function AboutWindow:begin()
	-- Containers
	local c1,c2
	-- Buttons and raw widgets (labels)
	local b1,w1,w2
	-- Text Box

	-- Vertical Container
	c1 = GUI.VContainer:new()
	c1:begin()

	b1 = GUI.Button:new('Thanks!')
	b1:begin(self.onOk)
	b1.userData = self
	b1.fixedH = 36

	w1 = GUI.Widget:new('Lovely Tactics Hex')
	w1.fixedH = 36

	w2 = GUI.Widget:new('Mad Programmer & GloamingCat')

	c1:addWidget(w1)
	c1:addWidget(w2)
	c1:addWidget(b1)

	self:setRootContainer(c1)

	GUI.addWindow(self)
end

return AboutWindow
