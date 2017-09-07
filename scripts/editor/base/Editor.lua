local GUIConf = require("ui/base/GUIConf")

local TilesWindow = require("editor/ui/TilesWindow")
local FieldsWindow = require("editor/ui/FieldsWindow")
local LayersWindow = require("editor/ui/LayersWindow")
local MenuWindow = require("editor/ui/MenuWindow")

local CameraMovement = require("editor/base/CameraMovement")

local Editor = {}

local function getTileAt(field, x, y, z)
  local ret = nil

  for k, v in ipairs(field.terrainLayers[z]) do
    if v ~= nil and v.grid[x] ~= nil then
      ret = v.grid[x][y]
    end
  end

  return ret
end

function Editor:onSetBrush(brush)
  self.brush = brush
end

function Editor:begin()
  -- Load the map
  FieldManager:loadField(0)

  -- Create the UI
  self.tilesWindow = TilesWindow:new()
  self.tilesWindow:begin(self, self.onSetBrush)
  self.tilesWindow.x, self.tilesWindow.y = GUIConf.border, GUIConf.border

  self.fieldsWindow = FieldsWindow:new()
  self.fieldsWindow:begin()
  self.fieldsWindow.x, self.fieldsWindow.y = GUIConf.border, self.tilesWindow.h+GUIConf.border*2

  self.layersWindow = LayersWindow:new()
  self.layersWindow:begin()
  self.layersWindow.x, self.layersWindow.y = love.graphics:getWidth()-self.layersWindow.w-GUIConf.border, GUIConf.border
end

function Editor:resize(w, h)
  self.layersWindow.x, self.layersWindow.y = w-self.layersWindow.w-GUIConf.border, GUIConf.border

  self.layersWindow.rootContainer:invalidate()
end

function Editor:mouseMove(x, y, mouseOverUI)
  CameraMovement:mouseMove(x, y, mouseOverUI)

  if self.brush and love.mouse.isDown(1) and not love.keyboard.isDown("lctrl", "rctrl") then
    local w, h = love.graphics:getDimensions()

    -- Get the world coordinates
    local wx, wy = FieldManager.renderer:screen2World(x, y)
    -- Get the tile coordinates
    local tx, ty, h = math.field.pixel2Tile(wx, wy, -wy)
    -- Round
    tx, ty = math.round(tx), math.round(ty)

    -- Get the tile
    local tile = getTileAt(FieldManager.currentField, tx, ty, 0)

    if tile ~= nil then
      tile:setTerrain(-1)
    end
  end
end

function Editor:update(x, y)
  FieldManager:update()
end

function Editor:draw()
  ScreenManager:draw()
end

function Editor:mouseDown(x, y, button)
  CameraMovement:mouseDown(x, y, button)
end

function Editor:mouseUp()
  CameraMovement:mouseUp()
end

return Editor
