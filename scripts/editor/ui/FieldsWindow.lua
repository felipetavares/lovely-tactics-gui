local GUIConf = require("ui/base/GUIConf")
local FieldsWindow = GUI.Window:new(true, "FIELDS")

function FieldsWindow.onLoadField(data)
  FieldManager:loadField(data.field)

  local x, y = math.field.pixelCenter(FieldManager.currentField)
  FieldManager.renderer:moveTo(x, y)

  data.self.editorOnLoadField(data.self.editor)
end

function FieldsWindow:begin(editor, onLoadField)
  self.editor = editor
  self.editorOnLoadField = onLoadField

  self.fieldTree = JSON.load("data/fields/fieldTree").root

  self.w = GUIConf.border*20
  self.h = GUIConf.border*15

  -- Containers
  local c1, c2, c3, c4
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
  c4 = GUI.HContainer:new()
  c4:begin(true)
  c4.fixedH = GUIConf.border*3

  b1 = GUI.Button:new()
  b1:begin(nil, "gui_images/plus.png", {x=0,y=0,w=24,h=24})
  b1.userData = nil
  b1.fixedW = GUIConf.border*3

  b2 = GUI.Button:new()
  b2:begin(nil, "gui_images/save.png", {x=0,y=0,w=24,h=24})
  b2.userData = nil
  b2.fixedW = GUIConf.border*3

  c4:addWidget(b1)
  c4:addWidget(GUI.Widget:new(nil, true))
  c4:addWidget(b2)

  for i, fieldInfo in ipairs(self.fieldTree.children) do
    local fieldButton

    fieldButton = GUI.Button:new(fieldInfo.data.name)
    fieldButton:begin(self.onLoadField)
    fieldButton.fixedH = 36
    fieldButton.userData = {field = fieldInfo.data.id, self = self}

    c3:addWidget(fieldButton)
  end

  s1 = GUI.ScrollBar:new()
  s1:begin("vertical")
  s1:scrollContainer(c3)
  s1.fixedW = 24

  c2:addWidget(c3)
  c2:addWidget(s1)

  local spacer = GUI.Widget:new("", true)
  spacer.fixedH = GUIConf.border

  c1:addWidget(c2)
  c1:addWidget(spacer)
  c1:addWidget(c4)

  self:setRootContainer(c1)

  GUI.addWindow(self)
end

return FieldsWindow
