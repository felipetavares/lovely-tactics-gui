local GUIConf = require("ui/base/GUIConf")
local Container = require("ui/widgets/Container")

local VContainer = Container:new()

function VContainer:resize ()
	local wid

	local border = 0

	if not self.noborder then
		border = GUIConf.border
	end

	local pX = self.x+self.offX+border/2
	local pY = self.y+self.offY+border/2-2
	local pW = self.w-border
	local pH = self.h-border

	local unfixedH = self.fullH-border
	local unfixedN = #self.widgets

	for wid=1, #self.widgets do
		if self.widgets[wid].fixedH then
			unfixedH = unfixedH - self.widgets[wid].fixedH
			unfixedN = unfixedN - 1
		end
	end

	for wid=1, #self.widgets do
		self.widgets[wid].x = pX
		self.widgets[wid].y = pY
		self.widgets[wid].w = pW

		if self.widgets[wid].fixedH then
			self.widgets[wid].h = self.widgets[wid].fixedH
		else
			self.widgets[wid].h = unfixedH/unfixedN
		end

		pH = pH - self.widgets[wid].h
		pY = pY + self.widgets[wid].h
	end

	self.invalid = false
end

return VContainer
