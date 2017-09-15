require("core/base/globals")
GUI = require("ui/base/GUI")

local Editor = require("editor/base/Editor")

function begin()
  --ScreenManager:init()
  Editor:begin()
end

function love.load ()
  --love.window.setMode(800, 600, {fullscreen=false, resizable=true})

  -- Fast terminal out
  io.stdout:setvbuf("no")

  love.window.setTitle ("Lovely Tactics Hex")

  -- Set a nice font
  love.graphics.setFont(love.graphics.newFont("fonts/FogSans.otf", 16))

  -- Hack the configuration values to make our resolution work with
  -- GloamingCat's map rendering
  Config.screen.nativeWidth = love.graphics:getWidth()
  Config.screen.nativeHeight = love.graphics:getHeight()

  begin()
end

function love.mousemoved(x, y)
  local mouseOverUI = true

  if not GUI.mouseMove(x, y) then
    mouseOverUI = false
  end

  Editor:mouseMove(x, y, mouseOverUI)
end

function love.update ()
  Editor:update()
  GUI:update()
end

function love.draw ()
  love.graphics.setScissor(0,0,love.graphics:getWidth(),love.graphics:getHeight())
  love.graphics.clear(128, 60, 180)

  Editor:draw()
  GUI.render()

  love.graphics.print(tostring(love.timer.getFPS()), 0, 0)
end

-- Input

function love.mousepressed(x, y, button)
  local mouseOverUI = true

  if GUI.mouseDown(x, y, button) then
    mouseOverUI = false
  end

  Editor:mouseDown(x, y, button, mouseOverUI)
end

function love.resize(w, h)
  --ScreenManager.width = w
  --ScreenManager.height = h
  --FieldManager.renderer:resizeCanvas()
  Editor:resize(w, h)
  GUI.NotificationManager.resize(w, h)
end

function love.mousereleased(x, y, button)
  GUI.mouseUp(x, y, button)
  Editor:mouseUp()
end

function love.keypressed(key, isrepeat)
  GUI.keyDown(key, isrepeat)
  Editor:keyDown(key)
end

function love.keyreleased(key)
  GUI.keyUp(key)
  Editor:keyUp(key)
end

function love.textinput(unicode)
  GUI.input(unicode)
end

-- Helper

function table.invert(t)
  local u = { }
  for k, v in pairs(t) do u[v] = k end
  return u
end
