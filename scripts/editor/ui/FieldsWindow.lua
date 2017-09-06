local GUIConf = require("ui/base/GUIConf")
local FieldsWindow = GUI.Window:new(true, "FIELDS")

function FieldsWindow:begin()
  self.w = GUIConf.border*20
  self.h = GUIConf.border*15

  -- Containers
  local c1, c2, c3
  -- Scroll bars
  local s1
  -- Buttons
  local b1, b2

  c1 = GUI.VContainer:new()
  c1:begin()
  c2 = GUI.HContainer:new()
  c2:begin(true)
  c3 = GUI.VContainer:new()
  c3:begin(false, true)

  b1 = GUI.Button:new("0")
  b1:begin(onLoadField)
  b1.fixedH = 36
  b1.userData = {field = 0}

  b2 = GUI.Button:new("1")
  b2:begin(onLoadField)
  b2.fixedH = 36
  b2.userData = {field = 1}

  c3:addWidget(b1)
  c3:addWidget(b2)

  s1 = GUI.ScrollBar:new()
  s1:begin("vertical")
  s1:scrollContainer(c3)
  s1.fixedW = 24

  c2:addWidget(c3)
  c2:addWidget(s1)

  c1:addWidget(c2)

  self:setRootContainer(c1)

  GUI.addWindow(self)
end

return FieldsWindow
