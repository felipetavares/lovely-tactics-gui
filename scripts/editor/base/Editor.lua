local GUIConf = require("ui/base/GUIConf")

local TilesWindow = require("editor/ui/TilesWindow")
local FieldsWindow = require("editor/ui/FieldsWindow")
local LayersWindow = require("editor/ui/LayersWindow")
local MenuWindow = require("editor/ui/MenuWindow")
local ToolsWindow = require("editor/ui/ToolsWindow")

local Field = require("json/Field")

local CameraMovement = require("editor/base/CameraMovement")
local History = require("editor/base/History")

local Editor = {}

function Editor:getTileAt(field, x, y, z)
  local ret = nil

  local layer = field.terrainLayers[z][self.paintLayer]

  if layer ~= nil and layer.grid[x] ~= nil then
    ret = layer.grid[x][y]
  end

  return ret
end

function Editor:toggleHideWindows()
  -- Hide or show all windows (notifications are not windows)
  GUI.setVisible(not self.tilesWindow.isVisible)

  local message = "UI [off]"

  if self.tilesWindow.isVisible then
    message = "UI [on]"
  end

  local notification = GUI.Notification:new(message)

  GUI.NotificationManager.addNotification(notification)
end

function Editor:onSetBrush(brush)
  self.brush = brush

  local notification = GUI.Notification:new("Using brush "..self.brush.name)

  GUI.NotificationManager.addNotification(notification)
end

function Editor:onLoadField()
  self.layersWindow:updateLayers()
end

function Editor:onSelectLayer(layer)
  self.paintLayer = layer

  local notification = GUI.Notification:new("Using layer #"..tostring(layer))

  GUI.NotificationManager.addNotification(notification)
end

function Editor:onChangeTool(tool)
  self.tool = tool

  local notification = GUI.Notification:new("Using "..tool.name)

  GUI.NotificationManager.addNotification(notification)
end

function Editor:begin()
  FieldManager:init()

  local fieldFile = "data/fields/0.json"

  -- Testing saving and loading maps
  self.field = Field:new(fieldFile)

  -- The last parameter is the type used to fill
  --self.field:addLayer("Sand", 0, 0, {}, 1)
  --self.field:addLayer("Grass", 0, 0, {}, 0)

  self.field:write(fieldFile)

  -- Let the camera use the field
  CameraMovement:setField(self.field)

  -- Create the history
  self.history = History:new(self.field)

  -- Create the UI
  self.tilesWindow = TilesWindow:new()
  self.tilesWindow:begin(self, self.onSetBrush)
  self.tilesWindow.x, self.tilesWindow.y = GUIConf.border, GUIConf.border

  self.fieldsWindow = FieldsWindow:new()
  self.fieldsWindow:begin(self, self.onLoadField)
  self.fieldsWindow.x, self.fieldsWindow.y = GUIConf.border, self.tilesWindow.h+GUIConf.border*2

  self.layersWindow = LayersWindow:new()
  self.layersWindow:begin(self)
  self.layersWindow.x, self.layersWindow.y = love.graphics:getWidth()- self.layersWindow.w-GUIConf.border, GUIConf.border

  self.toolsWindow = ToolsWindow:new()
  self.toolsWindow:begin(self)
  self.toolsWindow.x, self.toolsWindow.y = love.graphics:getWidth()-self.toolsWindow.w-GUIConf.border, self.layersWindow.h+GUIConf.border*2

  self.cursor = love.graphics.newImage("gui_images/hex-selector.png")
end

function Editor:resize(w, h)
  self.layersWindow.x, self.layersWindow.y = w-self.layersWindow.w-GUIConf.border, GUIConf.border
  self.toolsWindow.x, self.toolsWindow.y = love.graphics:getWidth()-self.toolsWindow.w-GUIConf.border, self.layersWindow.h+GUIConf.border*2

  self.toolsWindow.rootContainer:invalidate()
  self.layersWindow.rootContainer:invalidate()
end

function Editor:tileUnderMouse(x, y)
  -- Get the world coordinates
  local wx, wy = self.field:screen2World(x, y)
  -- Get the tile coordinates
  local otx, oty, h = math.field.pixel2Tile(wx, wy, -wy)
  -- Round
  local tx, ty = math.round(otx), math.round(oty)

  -- Get the tile

  return tx, ty
end

function Editor:mouseMove(x, y, mouseOverUI)
  CameraMovement:mouseMove(x, y, mouseOverUI)

  local tx, ty = self:tileUnderMouse(x, y)

  self.cursorPosition = nil

  love.mouse.setVisible(mouseOverUI)

  if not mouseOverUI then
    if self.paintLayer then
      -- Get the screen coords for the tile
      local sx, sy = math.field.tile2Pixel(tx, ty, self.field.layers[self.paintLayer].info.height)
      sx, sy = self.field:world2Screen(sx, sy)

      -- Move the cursor there
      self.cursorPosition = {
        x = sx,
        y = sy
      }

      -- Edit the tile if need be
      self:paint(tx, ty)
    end
  end
end

function Editor:paint(tx, ty)
  local value = self.field:getAt(self.paintLayer, tx, ty)

  if self.paintLayer and
     love.mouse.isDown(1) and
     not (love.keyboard.isDown("lctrl", "rctrl") or love.mouse.isDown(3)) and
     self.tool ~= nil then
    if self.tool.name == "eraser" then
      if value >= 0 then
        self.history:commit(History.makeAction("eraser", {
            layer = self.paintLayer,
            x = tx,
            y = ty,
            old = value,
            new = -1
          }))
        self.field:editAt(self.paintLayer, tx, ty, -1)
      end
    elseif self.tool.name == "pencil" then
      if self.brush ~= nil then
        if value ~= self.brush.tile and value ~= -2 then
          self.history:commit(History.makeAction("pencil", {
            layer = self.paintLayer,
            x = tx,
            y = ty,
            old = value,
            new = self.brush.tile
          }))
          self.field:editAt(self.paintLayer, tx, ty, self.brush.tile)
        end
      end
    end
  end
end

function Editor:update(x, y)
  self.field:update()
end

function Editor:draw()
  self.field:render()

  if self.cursor ~= nil and self.cursorPosition ~= nil then
    local mx, my = love.mouse:getPosition()
    local x, y = self.cursorPosition.x, self.cursorPosition.y
    local w, h = Config.grid.tileW, Config.grid.tileH

    love.graphics.draw(self.cursor, x, y, nil, nil, nil, w, h)
    love.graphics.draw(self.tool.cursor, mx, my-32)
  end
end

function Editor:mouseDown(x, y, button, mouseOverUI)
  CameraMovement:mouseDown(x, y, button)

  -- local tile = self:tileUnderMouse(x, y)

  -- if tile ~= nil and not mouseOverUI then
  --   self:paint(tile)
  -- end
end

function Editor:mouseUp()
  CameraMovement:mouseUp()
end

function Editor:keyUp(key)
  CameraMovement:keyUp(key)
end

function Editor:keyDown(key)
  CameraMovement:keyDown(key)

  if love.keyboard.isDown("lctrl", "rctrl") then
    -- Undo
    if key == "z" then
      self.history:undo()
    -- Redo
    elseif key == "y" then
      self.history:redo()
    end
  elseif love.keyboard.isDown("tab") then
    self:toggleHideWindows()
  end
end

return Editor
