local GUIConf = require("ui/base/GUIConf")
local NewFieldWindow = GUI.Window:new(true, "NEW FIELD")

function NewFieldWindow.onCancel(data)
  data.self:close()
end

function NewFieldWindow:begin()
  self.w = GUIConf.border*20
  self.h = GUIConf.border*30

  self:center()

  local buttonWidth = 6

  local c1 = GUI.VContainer:new()
  c1:begin()

  local c2 = GUI.HContainer:new()
  c2:begin(true)
  c2.fixedH = GUIConf.border*3

  local c3 = GUI.VContainer:new()
  c3:begin(true)
  c3.fixedW = GUIConf.border*6

  local c4 = GUI.VContainer:new()
  c4:begin(true)

  local c5 = GUI.HContainer:new()
  c5:begin(true)

  local b1 = GUI.Button:new("Ok")
  b1:begin(nil)
  b1.userData = nil
  b1.fixedW = GUIConf.border*buttonWidth

  local b2 = GUI.Button:new("Cancel")
  b2:begin(self.onCancel)
  b2.userData = {self = self}
  b2.fixedW = GUIConf.border*buttonWidth

  local rows = {
    {"Name", "Unamed"},
    false,
    {"Width", "15"},
    {"Height", "15"}
  }

  for i, r in ipairs(rows) do
    if r == false then
      local spacer1 = GUI.Widget:new(nil, true)
      spacer1.fixedH = GUIConf.border*3
      local spacer2 = GUI.Widget:new(nil, true)
      spacer2.fixedH = GUIConf.border*3

      c3:addWidget(spacer1)
      c4:addWidget(spacer2)
    else
      local label = GUI.Widget:new(r[1]..":", true, 1)
      label.fixedH = GUIConf.border*3

      local value = GUI.TextBox:new()
      value:begin()
      value.text = r[2]
      value.fixedH = GUIConf.border*3

      c3:addWidget(label)
      c4:addWidget(value)
    end
  end

  c2:addWidget(GUI.Widget:new(nil, true))
  c2:addWidget(b2)
  c2:addWidget(b1)

  c5:addWidget(c3)
  c5:addWidget(c4)

  c1:addWidget(c5)
  c1:addWidget(c2)

  self:setRootContainer(c1)

  GUI.addWindow(self)
end

return NewFieldWindow
