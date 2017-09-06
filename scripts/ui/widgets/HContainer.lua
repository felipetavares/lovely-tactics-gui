local GUIConf = require("ui/base/GUIConf")
local Container = require("ui/widgets/Container")

local HContainer = Container:new()

function HContainer:resize ()
	local wid

	local border = 0

	if not self.noborder then
		border = GUIConf.border
	end

	local pX = self.x+self.offX+border/2
	local pY = self.y+self.offY+border/2
	local pW = self.w-border
	local pH = self.h-border

	local unfixedW = self.w-border
	local unfixedN = #self.widgets

	for wid=1, #self.widgets do
		if self.widgets[wid].fixedW then
			unfixedW = unfixedW - self.widgets[wid].fixedW
			unfixedN = unfixedN - 1
		end
	end

	for wid=1, #self.widgets do
		self.widgets[wid].x = pX
		self.widgets[wid].y = pY

		if self.widgets[wid].fixedW then
			self.widgets[wid].w = self.widgets[wid].fixedW
		else
			self.widgets[wid].w = unfixedW/unfixedN
		end

		self.widgets[wid].h = pH

		pW = pW - self.widgets[wid].w
		pX = pX + self.widgets[wid].w
	end

	self.invalid = false
end

return HContainer
