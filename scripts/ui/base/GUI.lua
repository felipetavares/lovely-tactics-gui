iScissor = require("ui/base/iScissor")
local Window = require("ui/base/Window")
local Widget = require("ui/widgets/Widget")
local Button = require("ui/widgets/Button")
local TextBox = require("ui/widgets/TextBox")
local TileInfo = require("ui/widgets/TileInfo")
local LayerInfo = require("ui/widgets/LayerInfo")
local TileThumbnail = require("ui/widgets/TileThumbnail")
local ScrollBar = require("ui/widgets/ScrollBar")
local VContainer = require("ui/widgets/VContainer")
local HContainer = require("ui/widgets/HContainer")

local Notification = require("ui/base/Notification")
local NotificationManager = require("ui/base/NotificationManager")

local focusedWidget = nil

local GUI = {
  Window = Window,
  Widget = Widget,
  Button = Button,
  TextBox = TextBox,
  TileInfo = TileInfo,
  LayerInfo = LayerInfo,
  TileThumbnail = TileThumbnail,
  ScrollBar = ScrollBar,
  VContainer = VContainer,
  HContainer = HContainer,
  NotificationManager = NotificationManager,
  Notification = Notification
}

local windows = {}

function GUI.setVisible(visible)
  for _, window in ipairs(windows) do
    window.isVisible = visible
  end
end

function GUI.addWindow (window)
  table.insert (windows, 1, window)

  focusedWindow = window

  return true
end

function GUI.render ()
  local w

  for w=#windows, 1, -1 do
    if windows[w].isVisible then
      windows[w]:render()
    end
  end

  iScissor:setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  GUI.NotificationManager.render()
end

function GUI.update ()
  local w

  for w=1, #windows do
    if windows[w] then
      if windows[w].isVisible then
        windows[w]:update()
      end

      if windows[w].closed then
        table.remove (windows, w)
        w = w-1
      end
    end
  end

  GUI.NotificationManager.update()
end

function GUI.mouseDown (x, y, button)
  local w

  for w=1, #windows do
    if windows[w]:mouseDown(x, y, button) then
      if windows[w] ~= focusedWindow then
        GUI.bringUp(w)
      end

      return false
    end
  end

  return true
end

function GUI.mouseUp (x, y, button)
  local w

  for w=1, #windows do
    if windows[w]:mouseUp(x, y, button) then
      if windows[w] ~= focusedWindow then
        GUI.bringUp(w)
      end
      break
    end
  end
end

function GUI.mouseMove (x, y)
  local w

  for w=1, #windows do
    if windows[w]:mouseMove(x, y) then
      --amiga-like behaviour
      --if windows[w] ~= focusedWindow then
      --	GUI.bringUp(w)
      --end
      return true
    end
  end

  return false
end

function GUI.bringUp (w)
  local window = windows[w]

  table.remove(windows,w)
  table.insert(windows, 1, window)

  focusedWindow = window
end

function GUI.setFocus (widget)
  if focusedWidget then
    focusedWidget:unfocus()
  end

  if widget.text then
    widget:focus()

    focusedWidget = widget
  end
end

function GUI.keyDown (key, isrepeat)
  if focusedWidget then
    focusedWidget:keyDown (key, isrepeat)
  end
end

function GUI.keyUp (key)
  if focusedWidget then
    focusedWidget:keyUp (key)
  end
end

function GUI.input (unicode)
  if focusedWidget then
    focusedWidget:input (unicode)
  end
end

function GUI.getFocused ()
  return focusedWidget
end

return GUI
