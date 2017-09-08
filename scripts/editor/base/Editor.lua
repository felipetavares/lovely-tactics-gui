local GUIConf = require("ui/base/GUIConf")

local TilesWindow = require("editor/ui/TilesWindow")
local FieldsWindow = require("editor/ui/FieldsWindow")
local LayersWindow = require("editor/ui/LayersWindow")
local MenuWindow = require("editor/ui/MenuWindow")

local CameraMovement = require("editor/base/CameraMovement")

local Editor = {}

function Editor:getTileAt(field, x, y, z)
  local ret = nil

  local layer = field.terrainLayers[z][self.paintLayer]

  if layer ~= nil and layer.grid[x] ~= nil then
    ret = layer.grid[x][y]
  end

  return ret
end

function Editor:onSetBrush(brush)
  self.brush = brush
end

function Editor:onLoadField()
  self.layersWindow:updateLayers()
end

function Editor:onSelectLayer(layer)
  self.paintLayer = layer
end

function Editor:begin()
  -- Load the map
  FieldManager:loadField(0)

  -- Create the UI
  self.tilesWindow = TilesWindow:new()
  self.tilesWindow:begin(self, self.onSetBrush)
  self.tilesWindow.x, self.tilesWindow.y = GUIConf.border, GUIConf.border

  self.fieldsWindow = FieldsWindow:new()
  self.fieldsWindow:begin(self, self.onLoadField)
  self.fieldsWindow.x, self.fieldsWindow.y = GUIConf.border, self.tilesWindow.h+GUIConf.border*2

  self.layersWindow = LayersWindow:new()
  self.layersWindow:begin(self)
  self.layersWindow.x, self.layersWindow.y = love.graphics:getWidth()-self.layersWindow.w-GUIConf.border, GUIConf.border

  self.cursor = love.graphics.newImage("gui_images/hex-selector.png")
end

function Editor:resize(w, h)
  self.layersWindow.x, self.layersWindow.y = w-self.layersWindow.w-GUIConf.border, GUIConf.border

  self.layersWindow.rootContainer:invalidate()
end

function Editor:tileUnderMouse(x, y)
  -- Get the world coordinates
  local wx, wy = FieldManager.renderer:screen2World(x, y)
  -- Get the tile coordinates
  local otx, oty, h = math.field.pixel2Tile(wx, wy, -wy)
  -- Round
  local tx, ty = math.round(otx), math.round(oty)

  -- Get the tile
  local tile = self:getTileAt(FieldManager.currentField, tx, ty, 0)

  return tile
end

function Editor:mouseMove(x, y, mouseOverUI)
  CameraMovement:mouseMove(x, y, mouseOverUI)

  local tile = self:tileUnderMouse(x, y)

  self.cursorPosition = nil

  love.mouse.setVisible(not tile or mouseOverUI)

  if tile ~= nil then
    -- Get the screen coords for the tile
    local sx, sy = math.field.tile2Pixel(tile:coordinates())
    sx, sy = FieldManager.renderer:world2Screen(sx, sy)

    -- Move the cursor there
    self.cursorPosition = {
      x = sx,
      y = sy
    }

    if self.paintLayer and self.brush and love.mouse.isDown(1) and not love.keyboard.isDown("lctrl", "rctrl") then
      tile:setTerrain(self.brush.tile)
    end
  end
end

function Editor:update(x, y)
  FieldManager:update()
end

function Editor:draw()
  ScreenManager:draw()

  if self.cursor ~= nil and self.cursorPosition ~= nil then
    love.graphics.draw(self.cursor, self.cursorPosition.x, self.cursorPosition.y, nil, nil, nil, Config.grid.tileW, Config.grid.tileH)
  end
end

function Editor:mouseDown(x, y, button)
  CameraMovement:mouseDown(x, y, button)

  local tile = self:tileUnderMouse(x, y)

  if tile ~= nil then
    if self.paintLayer and self.brush and love.mouse.isDown(1) and not love.keyboard.isDown("lctrl", "rctrl") then
      tile:setTerrain(self.brush.tile)
    end
  end
end

function Editor:mouseUp()
  CameraMovement:mouseUp()
end

return Editor
