local CameraMovement = {}

local initialClickPosition = nil

function CameraMovement:setInitialClick(x, y)
  local w, h = love.graphics:getWidth(), love.graphics:getHeight()

  -- Camera position in world coordinates
  local wx, wy = FieldManager.renderer:screen2World(w, h)

  initialClickPosition = {
    x = x, y = y,
    camX = wx, camY = wy,
  }
end

function CameraMovement:mouseUp()
  initialClickPosition = nil
end

function CameraMovement:mouseDown(x, y, button)
  if button == 1 or button == 3 then
    self:setInitialClick(x, y)
  end
end

function CameraMovement:keyDown(key)
  if key == "space" then
    self:setInitialClick(love.mouse:getPosition())
  end
end

function CameraMovement:mouseMove(x, y, overUI)
  if not overUI and
     initialClickPosition and
     ((love.mouse.isDown(1) and love.keyboard.isDown("lctrl", "rctrl")) or
       love.mouse.isDown(3) or
       love.keyboard.isDown("space")) then
    local w = love.graphics:getWidth()
    local h = love.graphics:getHeight()

    -- Movement in world space
    -- Initial
    local ix, iy = FieldManager.renderer:screen2World(initialClickPosition.x, initialClickPosition.y)
    -- Final
    local fx, fy = FieldManager.renderer:screen2World(x, y)
    -- Delta
    local dx, dy = fx-ix, fy-iy

    -- New position in world space (old+delta)
    local wx, wy = initialClickPosition.camX-dx, initialClickPosition.camY-dy
    FieldManager.renderer:moveTo(wx, wy)
  end
end

return CameraMovement
