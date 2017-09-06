local Skin = require("ui/base/Skin")

local Widget = {
}

function Widget:new (name)
	local o = {
		x = 0, y = 0, w = 0, h = 0,
		container = nil,
		invalid = true,
		mouseInside = false,
		bg = Skin:new("gui_images/widget.png"),
		name = ""
	}
	setmetatable (o, {__index=self})

	if name then
		o.name = name
	end

	return o
end

function Widget:input (unicode)
end

function Widget:keyDown (key, isrepeat)
end

function Widget:keyUp (key)
end

function Widget:select ()
end

function Widget:enter ()
end

function Widget:leave ()
end

function Widget:click ()
	-- Now we have keyboard focus
	GUI.setFocus(self)
end

function Widget:focus ()
	self.focused = true
end

function Widget:unfocus ()
	self.focused = nil
end

function Widget:move (x, y)
end

function Widget:down (button)
end

function Widget:up (button)
end

function Widget:mouseMove (x, y)
	if not self.mouseInside and self:isInside (x, y) then
		self:enter()
		self.mouseInside = true
	end

	if not self:isInside(x, y) and self.mouseInside then
		self:leave()
		self.mouseInside = false
	end

	if self:isInside(x, y) then
		self:move(x, y)
	end
end

function Widget:mouseDown (x, y, button)
	if self:isInside(x, y) then
		self:select()
		self:down(button, x, y)
	end
end

function Widget:mouseUp (x, y, button)
	if self:isInside(x, y) then
		self:click()
		self:up(button)
	end
end

function Widget:invalidate ()
	self.invalid = true
end

function Widget:resize()
	self.invalid = false
end

function Widget:update ()
	if self.invalid then
		self:resize()
	end
end

function Widget:render ()
	iScissor:save()
	iScissor:combineScissor (self.x, self.y, self.w, self.h)

	love.graphics.setColor(255, 255, 255, 255)
	self.bg:draw(self.x+1, self.y+1, self.w-2, self.h-2)

	love.graphics.print (self.name, self.x+self.w/2-love.graphics.getFont():getWidth(self.name)/2, self.y+self.h/2-10)

	iScissor:restore()
end

function Widget:isInside (x, y)
	if x >= self.x and x <= self.x+self.w and
	   y >= self.y and y <= self.y+self.h then
	   return true
	end

	return false
end

return Widget
