local Skin = require("ui/base/Skin")
local Widget = require("ui/widgets/Widget")

local ScrollBar = Widget:new()

function ScrollBar:begin(type)
	self.position = 0
	self.isclicked = false
	self.type = type

	self.bg_scroll = Skin:new("gui_images/scrollbar-bg.png")
	self.fg_scroll = Skin:new("gui_images/scrollbar-fg.png")

	if not self.type then
		self.type = "horizontal"
	end
end

function ScrollBar:getHandleSize()
	return math.min((self.linkedContainer.h/self.linkedContainer.fullH)*self.h, self.h)
end

function ScrollBar:getHandlePos()
	return self.y+(self.h-self:getHandleSize())*self.position
end

function ScrollBar:move (x, y)
	if self.justclicked == true then
		self.justclicked = false

		self.click_position = {
			x = x, y = y
		}
		self.click_value = self.position
	end

	if self.isclicked == true then
		if self.type == "horizontal" then
			self.position = (x-self.x)/self.w
		else
			local handle_size = self:getHandleSize()
			local handle_pos = self:getHandlePos()

			if handle_size < self.h then
				local delta = (y-self.click_position.y)/(self.h-handle_size)
				self.position = self.click_value+delta

				if self.position < 0 then
					self.position = 0
				elseif self.position > 1 then
					self.position = 1
				end
			end
		end

		if self.linkedContainer then
			self.linkedContainer.offY = -self.position*(self.linkedContainer.fullH-self.linkedContainer.h)
			self.linkedContainer:invalidate()
		end
	end
end

function ScrollBar:down (button, x, y)
	if button == 1 then
		local handle_size = self:getHandleSize()
		local handle_pos = self:getHandlePos()


		if y > handle_pos and y < handle_pos+handle_size then
			self.isclicked = true
			self.justclicked = true
		end
	end
end

function ScrollBar:up (button)
	if button == 1 then
		self.isclicked = false
		self.justclicked = false
	end
end

function ScrollBar:leave ()
	Widget.leave (self)

	self.isclicked = false
end

function ScrollBar:scrollContainer (container)
	self.linkedContainer = container
end

function ScrollBar:render ()
	iScissor:save()
	iScissor:combineScissor (self.x, self.y, self.w, self.h)

	love.graphics.setColor(255, 255, 255, 255)
	self.bg_scroll:draw(self.x+1, self.y+1, self.w-2, self.h-2)

	if self.type == "horizontal" then
		-- TODO: Horizontal drawing code
	else
		local handle_size = self:getHandleSize()
		self.fg_scroll:draw(self.x+1, self.y+(self.h-handle_size)*self.position, self.w-2, handle_size)
	end

	iScissor:restore()
end

return ScrollBar
