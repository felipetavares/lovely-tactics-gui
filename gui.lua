--[=[
	How widgets are resized to the right size?
	The system queries for the wanted size of the element.
	The element(widget) can return values either in percent or in pixels.
	The system puts the element in the closest possible size.

	If the element returns no preferred size, the system
	automatically resizes it to the remaining space.
--]=]

-- GUI Skinning
local Skin = require "gui_skin"

local focusedWidget = nil

local Module = {}
Module.border = 12

local windows = {}

local Widget = {
}

local Window = {	
}

local Rectangle = {
}

function Rectangle:new (x, y, w, h)
	local o = {
		x = x,
		y = y,
		w = w,
		h = h
	}

	setmetatable (o, {__index=self})

	return o
end

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

-- Interpolated value
local iv = {
	
}

function iv:new (time)
	local o = {
		time = time,
		x0 = 0,
		x1 = 0,
		y0 = 0,
		y1 = 0
	}
	setmetatable (o, {__index=self})

	return o
end

function iv:set (value)
	self.y0 = self:get()
	self.y1 = value
	self.x0 = love.timer.getTime()
	self.x1 = self.x0+self.time
end

function iv:get ()
	local x = love.timer.getTime()

	if self.x1 == self.x0 then
		return 0
	end

	if x > self.x1 then
		return self.y1
	end

	if x < self.x0 then
		return self.y0
	end

	return self.y0 + (self.y1-self.y0)*(x-self.x0)/(self.x1-self.x0)
end

function Widget:new (name)
	local o = {
		x = 0, y = 0, w = 0, h = 0,
		container = nil,
		invalid = true,
		mouseInside = false,
		color = {
			r = iv:new(0.5),
			g = iv:new(0.5),
			b = iv:new(0.5)
		},
		bg = Skin:new("gui/widget.png"),
		bg_dep = Skin:new("gui/widget-depressed.png"),
		bg_sel = Skin:new("gui/widget-selected.png"),
		bg_bt = Skin:new("gui/button.png"),
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
	gui.setFocus(self)
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

local TextBox = Widget:new()

function TextBox:begin(text)
	self.cursor = 0

	if text then
		self.text = tostring(text)
	else
		self.text = ""
	end
end

function TextBox:input (unicode)
	if self.cursor > utf8.len(self.text) then
		self.text = self.text..unicode
	else if self.cursor == 0 then
		self.text = unicode..self.text
	else
		self.text = utf8.sub(self.text, 0, self.cursor)..unicode..utf8.sub(self.text,self.cursor+1,utf8.len(self.text))
	end
	end
	
	self.cursor = self.cursor+1
end

function TextBox:keyUp (key)
	if key == "backspace" then
		if utf8.len(self.text) == 1 then
			self.text = ""
			self.cursor = 0
		elseif utf8.len(self.text) == 0 then
			self.text = ""
			self.cursor = 0
		else
			self.text = utf8.sub(self.text, 0, utf8.len(self.text)-1)
			self.cursor = self.cursor-1
		end
	end

	if key == "left" then
		if self.cursor > 0 then
			self.cursor = self.cursor-1
		end
	end

	if key == "right" then
		if self.cursor < utf8.len(self.text) then
			self.cursor = self.cursor+1
		end
	end

	if key == "home" then
		self.cursor = 0
	end

	if key == "end" then
		self.cursor = utf8.len(self.text)
	end
end

function TextBox:render ()
	iScissor:save()
	iScissor:combineScissor (self.x, self.y, self.w, self.h)

	love.graphics.setColor(255, 255, 255, 255)

	if self.focused then
		self.bg_sel:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	else
		self.bg_dep:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	end

	love.graphics.print (self.text, self.x+Module.border/2+2, self.y+self.h/2-love.graphics.getFont():getHeight("")/2)

	local cursorPosition

	if self.cursor == 0 then
		cursorPosition = Module.border/2+2
	else
		cursorPosition = Module.border/2+2+love.graphics.getFont():getWidth(utf8.sub(self.text,0,self.cursor))
	end

	love.graphics.rectangle ("fill", self.x+cursorPosition, self.y+self.h/4-1,
									 2, self.h-self.h/2)

	iScissor:restore()
end
Module.TextBox = TextBox

local ScrollBar = Widget:new()

function ScrollBar:begin(type)
	self.position = 0
	self.isclicked = false
	self.type = type

	self.bg_scroll = Skin:new("gui/scrollbar-bg.png")
	self.fg_scroll = Skin:new("gui/scrollbar-fg.png")

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
Module.ScrollBar = ScrollBar

local CheckBox = Widget:new()

function CheckBox:begin(callback)
	self.callback = callback
	self.checked = false
end

function CheckBox:click ()
	self.checked = not self.checked

	if self.callback then
		self.callback(self.userData, self.checked)
	end
end

function CheckBox:render ()
	if self.checked == true then
		love.graphics.setColor (255, 0, 0, 255)
	else
		love.graphics.setColor (self.color.r:get(), self.color.g:get(), self.color.b:get(), 255)
	end

	love.graphics.rectangle ("fill", self.x+1, self.y+1,
									 self.w-2, self.h-2)

	love.graphics.setColor (0, 0, 0, 255)
	love.graphics.print (self.name, self.x+self.w/2-love.graphics.getFont():getWidth(self.name)/2, self.y+self.h/2-8)

	if self.focused then
		love.graphics.setColor (255, 0, 0, 255)
		love.graphics.rectangle ("line", self.x, self.y,
											 self.w, self.h)
	end
end
Module.CheckBox = CheckBox

local Button = Widget:new()

function Button:begin(callback, image_path, quad)
	self.callback = callback

	if image_path and quad then
		self.image = love.graphics.newImage(image_path)
		self.quad = love.graphics.newQuad(quad.x, quad.y, quad.w, quad.h, self.image:getDimensions())
	end
end

function Button:down()
	self.depress_background = true
end

function Button:up()
	self.depress_background = false
end

function Button:leave()
	self.depress_background = false
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

	if self.depress_background then
		self.bg_dep:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	else
		self.bg_bt:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	end

	if self.image and self.quad then
		-- Viewport of the quad
		local _, _, w, h = self.quad:getViewport()
		love.graphics.draw(self.image, self.quad, self.x+(self.w-w)/2, self.y+(self.h-h)/2)
	end

	love.graphics.print (self.name, self.x+self.w/2-love.graphics.getFont():getWidth(self.name)/2, self.y+self.h/2-10)


	iScissor:restore()
end
Module.Button = Button

local TileInfo = Button:new()

function TileInfo:begin(callback, image_path, quad, shared_info)
	Button.begin(self, callback, image_path, quad)
	self.shared_info = shared_info
end

function TileInfo:click()
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
		self.bg_sel:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	else
		self.bg_bt:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	end

	if self.image and self.quad then
		-- Viewport of the quad
		local _, _, w, h = self.quad:getViewport()
		love.graphics.draw(self.image, self.quad, self.x+(self.w-w)/2, self.y+(self.h-h)/2)
	end

	iScissor:restore()
end
Module.TileInfo = TileInfo

-- Special type of widget
local Container = Widget:new()

local VContainer = Container:new()

local HContainer = Container:new()

function HContainer:resize ()
	local wid

	local border = 0

	if not self.noborder then
		border = Module.border
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

function VContainer:resize ()
	local wid

	local border = 0

	if not self.noborder then
		border = Module.border
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

function Container:begin (noborder, renderbg)
	self.widgets = {}
	self.invertWidgets = {}

	self.noborder = noborder
	self.renderbg = renderbg

	self.offX = 0
	self.offY = 0

	self.mouseInside = false
end

function Container:invalidate ()
	local wid

	for wid=1, #self.widgets do
		self.widgets[wid]:invalidate()
	end

	self.invalid = true
end

function Container:mouseDown (x, y, button)
	if not self:isInside(x, y) then
		return
	end

	local wid

	for wid=1, #self.widgets do
		self.widgets[wid]:mouseDown (x, y, button)
	end
end

function Container:mouseUp (x, y, button)
	if not self:isInside(x, y) then
		return
	end

	local wid

	for wid=1, #self.widgets do
		if self.widgets[wid] then
			self.widgets[wid]:mouseUp (x, y, button)
		end
	end
end

function Container:mouseMove (x, y)
	if not self.mouseInside and self:isInside (x, y) then
		self:enter()
		self.mouseInside = true
	end

	if not self:isInside(x, y) and self.mouseInside then
		self:leave()
		self.mouseInside = false
	end

	if not self:isInside(x, y) then
		return
	end

	local wid

	for wid=1, #self.widgets do
		self.widgets[wid]:mouseMove (x, y, button)
	end
end

function Container:addWidget (widget)
	widget.container = self

	table.insert (self.widgets, widget)

	self.invertWidgets = table.invert(self.widgets)

	return true
end

function Container:render ()
	local wid

	for wid=1, #self.widgets do
		iScissor:save()
		iScissor:combineScissor (self.x, self.y, self.w, self.h)
			if self.renderbg then
				self.bg:draw(self.x, self.y, self.w, self.h)
			end
			self.widgets[wid]:render()
		iScissor:restore()
	end
end

function Container:resize ()
	local wid

	local pX = self.x+Module.border/2
	local pY = self.y+Module.border/2
	local pW = self.w-Module.border
	local pH = self.h-Module.border

	for wid=1, #self.widgets do
		self.widgets[wid].x = pX
		self.widgets[wid].y = pY
		self.widgets[wid].w = self.w/#self.widgets
		self.widgets[wid].h = pH

		pW = pW - self.widgets[wid].w
		pX = pX - self.widgets[wid].w

		self.widgets[wid].invalid = false
	end

	self.invalid = false
end

function Container:leave ()
	local wid

	for wid=1, #self.widgets do
		self.widgets[wid]:leave()
	end
end

function Container:update ()
	local wid

	if not self.fullH then
		self.fullH = self.h
	end

	-- Less than 36 pixels per thing
	if self.fullH/#self.widgets < 36 then
		-- Calculate the size for everything
		self.fullH = 0

		for wid=1, #self.widgets do
			if self.widgets[wid].fixedH then
				self.fullH = self.fullH + self.widgets[wid].fixedH
			else
				self.fullH = self.fullH + 36
			end
		end
	end

	if self.invalid then
		self:resize()
	end

	for wid=1, #self.widgets do
		self.widgets[wid]:update()
	end
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
		return
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
		bg = Skin:new("gui/window.png"),
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

	love.graphics.print(self.name, self.x+self.w/2-love.graphics.getFont():getWidth(self.name)/2, self.y+Module.border/2-3)

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

local function addWindow (window)
	table.insert (windows, 1, window)
	
	focusedWindow = window

	return true
end
Module.addWindow = addWindow

local function render ()
	local w

	for w=#windows, 1, -1 do
		if windows[w].isVisible then
			windows[w]:render()
		end
	end
end
Module.render = render

local function update ()
	local w

	for w=1, #windows do
		if windows[w] then
			if windows[w].isVisible then
				windows[w]:update()
			end

			if windows[w].closed then
				table.remove (windows, w)
				w = w-1
			end
		end
	end	
end
Module.update = update

local function mouseDown (x, y, button)
	local w

	for w=1, #windows do
		if windows[w]:mouseDown(x, y, button) then
			if windows[w] ~= focusedWindow then
				gui.bringUp(w)
			end
			break
		end
	end
end
Module.mouseDown = mouseDown

local function mouseUp (x, y, button)
	local w

	for w=1, #windows do
		if windows[w]:mouseUp(x, y, button) then
			if windows[w] ~= focusedWindow then
				gui.bringUp(w)
			end
			break
		end
	end
end
Module.mouseUp = mouseUp

local function mouseMove (x, y)
	local w

	for w=1, #windows do
		if windows[w]:mouseMove(x, y) then
			--amiga-like behaviour
			--if windows[w] ~= focusedWindow then
			--	gui.bringUp(w)
			--end
			break
		end
	end
end
Module.mouseMove = mouseMove

local function bringUp (w)
	local window = windows[w]

	table.remove(windows,w)
	table.insert(windows, 1, window)

	focusedWindow = window
end
Module.bringUp = bringUp

local function setFocus (widget)
	if focusedWidget then
		focusedWidget:unfocus()
	end

	if widget.text then
		widget:focus()

		focusedWidget = widget		
	end
end
Module.setFocus = setFocus

local function keyDown (key, isrepeat)
	if focusedWidget then
		focusedWidget:keyDown (key, isrepeat)
	end
end
Module.keyDown = keyDown

local function keyUp (key)
	if focusedWidget then
		focusedWidget:keyUp (key)
	end
end
Module.keyUp = keyUp

local function input (unicode)
	if focusedWidget then
		focusedWidget:input (unicode)
	end
end
Module.input = input

local function getFocused ()
	return focusedWidget
end
Module.getFocused = getFocused

Module.Widget = Widget
Module.VContainer = VContainer
Module.HContainer = HContainer
Module.Window = Window
Module.windows = windows

return Module
