local GUIConf = require("ui/base/GUIConf")
local LayersWindow = GUI.Window:new(true, "LAYERS")

function LayersWindow.onSelectLayer(data)
  data.self.currentLayer = data.layer

  data.self.editor:onSelectLayer(data.layer)
end

function LayersWindow:updateLayers()
  local shared_info = {}

  self.layersContainer.widgets = {}

  for i, layer in ipairs(self.editor.field.layers) do
    local layerInfo

    layerInfo = GUI.LayerInfo:new(layer.info.name)
    layerInfo:begin(self.onSelectLayer, shared_info)
    layerInfo.fixedH = 36
    layerInfo.userData = {layer = i, self = self}

    if self.currentLayer == nil or self.currentLayer == i then
      layerInfo:click()
    end

    self.layersContainer:addWidget(layerInfo)
  end

  self.layersContainer:invalidate()
end

function LayersWindow.onNewLayer(data)
  self = data.self

  self.editor.field:addLayer("Water", 0, 0, {}, 2)

  self:updateLayers()
end

function LayersWindow:begin(editor)
  self.editor = editor

  self.w = GUIConf.border*20
  self.h = GUIConf.border*15

  -- Containers
  local c1, c2, c3
  -- Scroll bars
  local s1
  -- Buttons
  local b1

  local spacer = GUI.Widget:new(nil, true)
  spacer.fixedH = GUIConf.border

  c1 = GUI.VContainer:new()
  c1:begin()
  c2 = GUI.HContainer:new()
  c2:begin(true)
  self.layersContainer = GUI.VContainer:new()
  self.layersContainer:begin(false, true)
  c3 = GUI.HContainer:new()
  c3:begin(true)
  c3.fixedH = GUIConf.border*3

  self:updateLayers()

  s1 = GUI.ScrollBar:new()
  s1:begin("vertical")
  s1:scrollContainer(self.layersContainer)
  s1.fixedW = 24

  c2:addWidget(self.layersContainer)
  c2:addWidget(s1)

  b1 = GUI.Button:new()
  b1:begin(self.onNewLayer, "gui_images/plus.png", {x=0,y=0,w=24,h=24})
  b1.userData = {self = self}
  b1.fixedW = GUIConf.border*3

  c3:addWidget(b1)

  c1:addWidget(c2)
  c1:addWidget(spacer)
  c1:addWidget(c3)

  self:setRootContainer(c1)

  GUI.addWindow(self)
end

return LayersWindow
