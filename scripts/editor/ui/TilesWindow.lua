local GUIConf = require("ui/base/GUIConf")
local TilesWindow = GUI.Window:new(true, "TILES")

function TilesWindow:loadTileList(query)
  local tile_list = {}
  local tw, th = Config.grid.tileW, Config.grid.tileH

  for i=0,#Database.terrains do
    local terrain = Database.terrains[i]

    if query == nil or terrain.name:lower():find(query:lower()) then
      local image = Database.animations[terrain.image]

      table.insert(tile_list, {
        path = "images/"..image.path,
        quad = {
          x = image.x,
          y = image.y,
          w = tw,
          h = th
        },
        animation = image,
        terrain = terrain
      })
    end
  end

  return tile_list
end

function TilesWindow:loadPreviewAutotileList(animation)
  local tile_list = {}
  local tw, th = 36, 22

  local image = animation

  local x, y = image.x, image.y
  local w, h = image.x+image.width, image.y+image.height

  while y < h do
    x = image.x

    while x < w do
      table.insert(tile_list, {
        path = "images/"..image.path,
        quad = {
          x = x,
          y = y,
          w = tw,
          h = th
        },
        animation = image
      })

      x = x+tw
    end

    y = y+th
  end

  return tile_list
end

function TilesWindow.switchToTileset(data)
  data.self.currentTileset = data.n
  data.self:showTileset(data.container)
end

function TilesWindow:previewAutotile(animation, previewContainer)
  previewContainer.widgets = {}

  local tile_list = self:loadPreviewAutotileList(animation)
  local row_size = 3
  local shared_info = {
    focused = nil
  }

  local fullH = -GUIConf.border*4

  for i=0,#tile_list/row_size do
    local row = GUI.HContainer:new()
    row:begin(true)
    row.fixedH = GUIConf.border*5

    fullH = fullH + row.fixedH

    for j=1,row_size do
      local tile = tile_list[i*row_size+j]

      if tile then
        local tmp = GUI.TileThumbnail:new()
        tmp:begin(false, tile.path, tile.quad)
        tmp.userData = {
          self = self,
          animation = tile.animation,
          row = row,
          previewContainer = previewContainer
        }
        row:addWidget(tmp)
      end
    end

    previewContainer:addWidget(row)
  end

  previewContainer.fullH = nil
  previewContainer.fixedH = fullH
  previewContainer:invalidate()
end

function TilesWindow:tileInformation(data, container)
  local terrain = data.terrain
  local animationStatus = ""
  local image = Database.animations[terrain.image]

  if image.cols > 1 then
    animationStatus = "animated"
  else
    animationStatus = "static"
  end

  local w1 = GUI.Widget:new(terrain.name, true)
  w1.fixedH = 36

  local w2 = GUI.Widget:new(animationStatus, true)
  w2.fixedH = 36

  container:addWidget(w1)
  container:addWidget(w2)

  container.fixedH = w1.fixedH+w2.fixedH+GUIConf.border/2
  container:invalidate()
end

function TilesWindow.onSelectAutotile(data)
  data.self.setBrushCallback(data.self.editor, {
    tile = data.terrainID
  })

  local preview = GUI.VContainer:new()
  preview:begin(false, true)

  if data.self.currentPreview ~= nil then
    for i, widget in ipairs(data.container.widgets) do
      if widget == data.self.currentPreview.row then
        table.remove(data.container.widgets, i)
        break
      end
    end
  end

  --data.self:previewAutotile(data.animation, preview)
  data.self:tileInformation(data, preview)

  for i, widget in ipairs(data.container.widgets) do
    if widget == data.row then
      data.container:addWidgetAt(preview, i+1)
      break
    end
  end

  data.self.currentPreview = {
    container = data.container,
    row = preview
  }

  data.container.fullH = nil
  data.container:invalidate()
end

function TilesWindow:showTileset(container, query)
  container.widgets = {}

  local tile_list = self:loadTileList(query)
  local row_size = 3
  local shared_info = {
    focused = nil
  }

  for i=0,#tile_list/row_size do
    local row = GUI.HContainer:new()
    row:begin(true)
    row.fixedH = GUIConf.border*5

    for j=1,row_size do
      local tile = tile_list[i*row_size+j]

      if tile then
        local tmp = GUI.TileInfo:new()
        -- Use self.onSelectAutotile to turn autotile preview on
        tmp:begin(self.onSelectAutotile, tile.path, tile.quad, shared_info)
        tmp.userData = {
          self = self,
          animation = tile.animation,
          terrainID = tile.terrain.id,
          terrain = tile.terrain,
          row = row,
          container = container
        }
        row:addWidget(tmp)
        tmp.fixedW = GUIConf.border*5
      end
    end

    container:addWidget(row)
  end

  container:invalidate()
  container.fullH = nil
end

function TilesWindow.searchTileset(data)
  data.self:showTileset(data.container, data.text.text)
end

function TilesWindow:begin(editor, setBrushCallback)
  self.editor = editor
  self.setBrushCallback = setBrushCallback

  self.currentTileset = 1

  self.w = GUIConf.border*20
  self.h = GUIConf.border*30

  -- Containers
  local c1, c2, c3, c4, c5
  -- Labels
  -- Scrollbar
  local s1
  -- Tex boxes
  local t1
  -- Buttons
  local b1

  c1 = GUI.VContainer:new()
  c1:begin()
  c2 = GUI.HContainer:new()
  c2:begin()
  c3 = GUI.VContainer:new()
  c3:begin(false, true)
  c4 = GUI.HContainer:new()
  c4:begin(true)
  c4.fixedH = 36
  c5 = GUI.HContainer:new()
  c5:begin(true)
  c5.fixedH = 36

  for i=1,4 do
    local tab = GUI.Button:new("#"..tostring(i))
    tab:begin(self.switchToTileset)
    tab.userData = {
      self = self,
      n = i,
      container = c3
    }

    c5:addWidget(tab)
  end

  self:showTileset(c3)

  s1 = GUI.ScrollBar:new()
  s1:begin("vertical")
  s1.fixedW = 24
  s1:scrollContainer(c3)

  t1 = GUI.TextBox:new()
  t1:begin()

  b1 = GUI.Button:new()
  b1:begin(self.searchTileset, "gui_images/magnifier.png", {x = 0, y = 0, w = 24, h = 24})
  b1.fixedW = 36
  b1.userData = {
    self = self,
    container = c3,
    text = t1
  }

  c4:addWidget(t1)
  c4:addWidget(b1)

  c2:addWidget(c3)
  c2:addWidget(s1)

  c1:addWidget(c5)
  c1:addWidget(c2)
  c1:addWidget(c4)

  self:setRootContainer(c1)

  GUI.addWindow(self)
end

return TilesWindow
