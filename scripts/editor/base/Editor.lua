local AboutWindow = require("editor/ui/AboutWindow")
local TilesWindow = require("editor/ui/TilesWindow")
local FieldsWindow = require("editor/ui/FieldsWindow")
local MenuWindow = require("editor/ui/MenuWindow")

local CameraMovement = require("editor/base/CameraMovement")

local Editor = {}

function Editor:begin()
  -- Load the map
  FieldManager:loadField(0)

  -- Create the UI
  local menu = MenuWindow:new()
  menu:begin()
  local tiles = TilesWindow:new()
  tiles:begin()
  local fields = FieldsWindow:new()
  fields:begin()
end

function Editor:mouseMove(x, y, mouseOverUI)
  CameraMovement:mouseMove(x, y, mouseOverUI)
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
