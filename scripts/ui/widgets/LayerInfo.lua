local GUIConf = require("ui/base/GUIConf")
local Skin = require("ui/base/Skin")
local Button = require("ui/widgets/Button")

local LayerInfo = Button:new()

function LayerInfo:begin(callback, shared_info)
  Button.begin(self, callback)
  self.shared_info = shared_info

  self.bg_active = Skin:new("gui_images/widget-selected.png")
end

function LayerInfo:click()
  Button.click(self)

  if self.shared_info.focused ~= self then
    self:focus()

    if self.shared_info.focused then
      self.shared_info.focused:unfocus()
    end

    self.shared_info.focused = self
  end
end

function LayerInfo:render()
  iScissor:save()
  iScissor:combineScissor (self.x, self.y, self.w, self.h)

  love.graphics.setColor(255, 255, 255, 255)

  if self.focused then
    self.bg_active:draw(self.x+1, self.y+1, self.w-2, self.h-2)
  else
    self.bg:draw(self.x+1, self.y+1, self.w-2, self.h-2)
  end

  love.graphics.print (self.name, math.round(self.x+self.w/2-love.graphics.getFont():getWidth(self.name)/2), math.round(self.y+self.h/2+GUIConf.textOffset))

  iScissor:restore()
end

return LayerInfo
