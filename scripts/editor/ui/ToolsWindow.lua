local GUIConf = require("ui/base/GUIConf")
local ToolsWindow = GUI.Window:new(true, "")

function ToolsWindow:begin()
  self.w = GUIConf.border*20
  self.h = GUIConf.border*15

  -- Containers
  local c1, c2, c3
  -- Scroll bars
  local s1

  c1 = GUI.VContainer:new()
  c1:begin()
  c2 = GUI.HContainer:new()
  c2:begin(true)
  c3 = GUI.VContainer:new()
  c3:begin(false, true)

  for i, fieldInfo in ipairs(self.fieldTree.children) do
    local fieldButton

    fieldButton = GUI.Button:new(fieldInfo.data.name)
    fieldButton:begin(self.onLoadField)
    fieldButton.fixedH = 36
    fieldButton.userData = {field = fieldInfo.data.id}

    c3:addWidget(fieldButton)
  end

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

return ToolsWindow
