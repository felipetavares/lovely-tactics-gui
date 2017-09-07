local CameraMovement = {}

local initialClickPosition = nil

function CameraMovement:mouseUp()
  initialClickPosition = nil
end

function CameraMovement:mouseDown(x, y, button)
  if button == 1 then
    local w, h = love.graphics:getWidth(), love.graphics:getHeight()

    -- Camera position in world coordinates
    local wx, wy = FieldManager.renderer:screen2World(w, h)

    initialClickPosition = {
      x = x, y = y,
      camX = wx, camY = wy,
    }
  end
end

function CameraMovement:mouseMove(x, y, overUI)
  if love.mouse.isDown(1) and
     not overUI and
     initialClickPosition and
     love.keyboard.isDown("lctrl", "rctrl") then
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
