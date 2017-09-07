local GUIConf = require("ui/base/GUIConf")
local LayersWindow = GUI.Window:new(true, "LAYERS")

function LayersWindow.onLoadField(data)
  FieldManager:loadField(data.field)
end

function LayersWindow:begin()
  self.w = GUIConf.border*20
  self.h = GUIConf.border*15

  -- Containers
  local c1, c2, c3
  -- Scroll bars
  local s1

  local shared_info = {}

  c1 = GUI.VContainer:new()
  c1:begin()
  c2 = GUI.HContainer:new()
  c2:begin(true)
  c3 = GUI.VContainer:new()
  c3:begin(false, true)

  for i, _ in ipairs(FieldManager.currentField.terrainLayers[0]) do
    local layerInfo

    layerInfo = GUI.LayerInfo:new(tostring(i))
    layerInfo:begin(false, shared_info)
    layerInfo.fixedH = 36
    layerInfo.userData = {layer = i}

    layerInfo:click()

    c3:addWidget(layerInfo)
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

return LayersWindow
