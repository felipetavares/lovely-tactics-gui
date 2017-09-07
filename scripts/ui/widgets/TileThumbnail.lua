local Skin = require("ui/base/Skin")
local Button = require("ui/widgets/Button")

local TileThumbnail = Button:new()

function TileThumbnail:begin(callback, image_path, quad)
  Button.begin(self, callback, image_path, quad)
end

function TileThumbnail:click()
end

function TileThumbnail:render()
  iScissor:save()
  iScissor:combineScissor (self.x, self.y, self.w, self.h)

  love.graphics.setColor(255, 255, 255, 255)

  if self.image and self.quad then
    -- Viewport of the quad
    local _, _, w, h = self.quad:getViewport()
    love.graphics.draw(self.image, self.quad, self.x+(self.w-w)/2, self.y+(self.h-h)/2)
  end

  iScissor:restore()
end

return TileThumbnail
