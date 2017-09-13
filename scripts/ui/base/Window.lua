local GUIConf = require("ui/base/GUIConf")
local Skin = require("ui/base/Skin")

local Window = {
}

function Window:center()
  self.x = math.round((love.graphics:getWidth()-self.w)/2)
  self.y = math.round((love.graphics:getHeight()-self.h)/2)
end

function Window:onBar (x, y)
	if x >= self.x and x <= self.x+self.w and
	   y >= self.y and y <= self.y+24 then
	   return true
	end

	return false
end

function Window:isInside (x, y)
	if x >= self.x and x <= self.x+self.w and
	   y >= self.y and y <= self.y+self.h then
	   return true
	end

	return false
end

function Window:setRootContainer (container)
	container.container = self
	self.rootContainer = container
end

function Window:mouseDown (x, y, button)
	if not self.isVisible then
		return false
	end

	if self:isInside (x,y) then
		if self:onBar (x, y) then
			self.moving = true
			self.barX = x-self.x
			self.barY = y-self.y
		end

		if self.rootContainer then
			self.rootContainer:mouseDown(x, y, button)
		end

		return true
	else
		return false
	end
end

function Window:mouseUp (x, y, button)
	if not self.isVisible then
		return false
	end

	self.moving = false

	if self:isInside (x,y) then
		if self.rootContainer then
			self.rootContainer:mouseUp(x, y, button)
		end

		return true
	end

	return false
end

function Window:mouseMove (x, y)
	if not self.isVisible then
		return false
	end

	if self.moving then
		self.x = x-self.barX
		self.y = y-self.barY
		if self.rootContainer then
			self.rootContainer:invalidate()
		end
	end

	if self.rootContainer then
		self.rootContainer:mouseMove(x, y)
	end

	if self:isInside (x,y) then
		return true
	end

	return false
end

function Window:new (visible, name)
	local o = {
		isVisible = true,
		x = love.graphics.getWidth()/4, y = love.graphics.getHeight()/4,
		w = love.graphics.getWidth()/2, h = love.graphics.getHeight()/2,
		bg = Skin:new("gui_images/window.png"),
		rootContainer = nil,
		name = name
	}

	if visible then
		o.isVisible = visible
	end

	setmetatable (o, {__index=self})

	return o
end

function Window:render ()
	if not self.isVisible then
		return
	end

	iScissor:setScissor(self.x, self.y, self.w, self.h)

	love.graphics.setColor (255, 255, 255, 255)
	self.bg:draw(self.x, self.y, self.w, self.h)

	love.graphics.print(self.name, math.round(self.x+self.w/2-love.graphics.getFont():getWidth(self.name)/2), math.round(self.y+GUIConf.border+GUIConf.textOffset+2))

	self.rootContainer:render()
end

function Window:close ()
	self.closed = true
end

function Window:update ()
	if not self.isVisible then
		return
	end

	self.rootContainer.x = self.x
	self.rootContainer.y = self.y+24
	self.rootContainer.w = self.w
	self.rootContainer.h = self.h-24

	self.rootContainer:update()
end

return Window
