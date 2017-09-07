local GUIConf = require("ui/base/GUIConf")
local Skin = require("ui/base/Skin")
local Widget = require("ui/widgets/Widget")

local Button = Widget:new()

function Button:begin(callback, image_path, quad)
	self.callback = callback

	if image_path and quad then
		self.image = love.graphics.newImage(image_path)
		self.quad = love.graphics.newQuad(quad.x, quad.y, quad.w, quad.h, self.image:getDimensions())
	end

    self.bg = Skin:new("gui_images/button.png")
    self.bg_active = Skin:new("gui_images/widget-depressed.png")
end

function Button:down()
	self.active = true
end

function Button:up()
	self.active = false
end

function Button:leave()
	self.active = false
end

function Button:click ()
	if self.callback then
		self.callback(self.userData)
	end
end

function Button:render ()
	iScissor:save()
	iScissor:combineScissor (self.x, self.y, self.w, self.h)

	love.graphics.setColor(255, 255, 255, 255)

	if self.active then
		self.bg_active:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	else
		self.bg:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	end

	if self.image and self.quad then
		-- Viewport of the quad
		local _, _, w, h = self.quad:getViewport()
		love.graphics.draw(self.image, self.quad, self.x+(self.w-w)/2, self.y+(self.h-h)/2)
	end

	love.graphics.print (self.name, self.x+self.w/2-love.graphics.getFont():getWidth(self.name)/2, self.y+self.h/2+GUIConf.textOffset)


	iScissor:restore()
end

return Button
