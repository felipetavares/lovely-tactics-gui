local CameraMovement = {}

local initialClickPosition = nil
local field = nil
local move = nil

function CameraMovement:setField(value)
  field = value
end

function CameraMovement:setInitialClick(x, y)
  -- Camera
  local cam = field.nowrite.offset

  -- Save the position
  initialClickPosition = {
    x = x, y = y,
    cx = cam.x, cy = cam.y,
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
    move = true
  end
end

function CameraMovement:keyUp(key)
  if key == "space" then
    move = nil
  end
end

function CameraMovement:mouseMove(x, y, overUI)
  if not overUI and
     initialClickPosition and
     (move or
     (love.mouse.isDown(1) and love.keyboard.isDown("lctrl", "rctrl")) or
       love.mouse.isDown(3)) then

    local offset = field.nowrite.offset

    local newCam = {
      x = initialClickPosition.cx+(x-initialClickPosition.x),
      y = initialClickPosition.cy+(y-initialClickPosition.y)
    }

    offset.x, offset.y = newCam.x, newCam.y

    field:updateNextFrame()
  end
end

return CameraMovement
