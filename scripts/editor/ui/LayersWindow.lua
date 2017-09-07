local GUIConf = require("ui/base/GUIConf")
local LayersWindow = GUI.Window:new(true, "LAYERS")

function LayersWindow.onSelectLayer(data)
  data.self.editor:onSelectLayer(data.layer)
end

function LayersWindow:updateLayers()
  local shared_info = {}

  self.layersContainer.widgets = {}

  for i, _ in ipairs(FieldManager.currentField.terrainLayers[0]) do
    local layerInfo

    layerInfo = GUI.LayerInfo:new(tostring(i))
    layerInfo:begin(self.onSelectLayer, shared_info)
    layerInfo.fixedH = 36
    layerInfo.userData = {layer = i, self = self}

    layerInfo:click()

    self.layersContainer:addWidget(layerInfo)
  end

  self.layersContainer:invalidate()
end

function LayersWindow:begin(editor)
  self.editor = editor

  self.w = GUIConf.border*20
  self.h = GUIConf.border*15

  -- Containers
  local c1, c2
  -- Scroll bars
  local s1

  c1 = GUI.VContainer:new()
  c1:begin()
  c2 = GUI.HContainer:new()
  c2:begin(true)
  self.layersContainer = GUI.VContainer:new()
  self.layersContainer:begin(false, true)

  self:updateLayers()

  s1 = GUI.ScrollBar:new()
  s1:begin("vertical")
  s1:scrollContainer(self.layersContainer)
  s1.fixedW = 24

  c2:addWidget(self.layersContainer)
  c2:addWidget(s1)

  c1:addWidget(c2)

  self:setRootContainer(c1)

  GUI.addWindow(self)
end

return LayersWindow
