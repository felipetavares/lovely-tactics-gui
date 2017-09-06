local GUIConf = require("ui/base/GUIConf")
local TilesWindow = GUI.Window:new(true, "TILES")

function TilesWindow:loadTileList()
  local tilesets = {
    {"images/Terrain/HexV.png"},
    {"images/Terrain/Sand.png"},
    {"images/Terrain/Water.png"},
    {"images/Terrain/HexV old.png"}
  }

  local images = tilesets[self.currentTileset]

  local tile_list = {}

  -- Default tile sizes
  local tw = 36
  local th = 22

  for i, img_path in pairs(images) do
    local w, h = love.graphics.newImage(img_path):getDimensions()
    local y = 0, x

    while y < h do
      x = 0
      while x < w do
        table.insert(tile_list, {path = img_path, quad = {x = x, y = y, w = tw, h = th}})

        x = x+tw
      end

      y = y+th
    end
  end

  return tile_list
end

function TilesWindow.switchToTileset(data)
  data.self.currentTileset = data.n
  data.self:showTileset(data.container)
end

function TilesWindow:showTileset(container)
  container.widgets = {}

  local tile_list = self:loadTileList()
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
        tmp:begin(false, tile.path, tile.quad, shared_info)
        row:addWidget(tmp)
      end
    end

    container:addWidget(row)
  end

  container:invalidate()
  container.fullH = nil
end

function TilesWindow:begin()
  self.currentTileset = 1

  self.w = GUIConf.border*20
  self.h = GUIConf.border*40

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

  b1 = GUI.Button:new()
  b1:begin(false, "gui_images/magnifier.png", {x = 0, y = 0, w = 24, h = 24})
  b1.fixedW = 36
  t1 = GUI.TextBox:new()
  t1:begin()

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
