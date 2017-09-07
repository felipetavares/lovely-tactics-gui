local Skin = require("ui/base/Skin")
local Button = require("ui/widgets/Button")

local TileInfo = Button:new()

function TileInfo:begin(callback, image_path, quad, shared_info)
  Button.begin(self, callback, image_path, quad)
  self.shared_info = shared_info

  self.bg_active = Skin:new("gui_images/widget-selected.png")
end

function TileInfo:click()
  Button.click(self)

  if self.shared_info.focused ~= self then
    self:focus()

    if self.shared_info.focused then
      self.shared_info.focused:unfocus()
    end

    self.shared_info.focused = self
  end
end

function TileInfo:render()
  iScissor:save()
  iScissor:combineScissor (self.x, self.y, self.w, self.h)

  love.graphics.setColor(255, 255, 255, 255)

  if self.focused then
    self.bg_active:draw(self.x+1, self.y+1, self.w-2, self.h-2)
  else
    self.bg:draw(self.x+1, self.y+1, self.w-2, self.h-2)
  end

  if self.image and self.quad then
    -- Viewport of the quad
    local _, _, w, h = self.quad:getViewport()
    love.graphics.draw(self.image, self.quad, self.x+(self.w-w)/2, self.y+(self.h-h)/2)
  end

  iScissor:restore()
end

return TileInfo
