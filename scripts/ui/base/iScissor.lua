local Rectangle = require("ui/base/Rectangle")

local iScissor = {
  -- Stack of scissors for save/restore
  stack = {},
  scissor = nil
}

function iScissor:apply ()
	if self.scissor then
		love.graphics.setScissor (self.scissor.x, self.scissor.y, self.scissor.w, self.scissor.h)
	end
end

-- Combine the new & old scissor
function iScissor:combineScissor (x,y,w,h)
	local scissor = Rectangle:new(x,y,w,h)
	local finalScissor = Rectangle:new(0,0,0,0)

	if scissor.x > self.scissor.x then
		finalScissor.x = scissor.x
	else
		finalScissor.x = self.scissor.x
	end

	if scissor.x+scissor.w < self.scissor.x+self.scissor.w then
		finalScissor.w = (scissor.x+scissor.w)-finalScissor.x
	else
		finalScissor.w = (self.scissor.x+self.scissor.w)-finalScissor.x
	end

	if scissor.y > self.scissor.y then
		finalScissor.y = scissor.y
	else
		finalScissor.y = self.scissor.y
	end

	if scissor.y+scissor.h < self.scissor.y+self.scissor.h then
		finalScissor.h = (scissor.y+scissor.h)-finalScissor.y
	else
		finalScissor.h = (self.scissor.y+self.scissor.h)-finalScissor.y
	end

	if finalScissor.w < 0 or finalScissor.h < 0 then
		self.scissor = self.scissor
	else
		self.scissor = finalScissor
	end

	self:apply()
end

-- Set the current scissor
function iScissor:setScissor (x, y, w, h)
	self.scissor = Rectangle:new(x,y,w,h)
	self:apply()
end

-- Save the current scissor
function iScissor:save ()
	table.insert(self.stack,self.scissor)
end

-- Load the current scissor
function iScissor:restore ()
	if #self.stack > 0 then
		self.scissor = table.remove(self.stack)
	end
	self:apply()
end

return iScissor
