local utf8 = require("3rd_party/utf8")
local Widget = require("ui/widgets/Widget")
local GUIConf = require("ui/base/GUIConf")
local Skin = require("ui/base/Skin")

local TextBox = Widget:new()

function TextBox:begin(text)
	self.cursor = 0

	if text then
		self.text = tostring(text)
	else
		self.text = ""
	end

    self.bg = Skin:new("gui_images/widget-depressed.png")
    self.bg_active = Skin:new("gui_images/widget-selected.png")
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
		self.bg_active:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	else
		self.bg:draw(self.x+1, self.y+1, self.w-2, self.h-2)
	end

	love.graphics.print (self.text, self.x+GUIConf.border/2+2, self.y+self.h/2-love.graphics.getFont():getHeight("")/2)

    if self.focused then
      local cursorPosition

      if self.cursor == 0 then
          cursorPosition = GUIConf.border/2+2
      else
          cursorPosition = GUIConf.border/2+2+love.graphics.getFont():getWidth(utf8.sub(self.text,0,self.cursor))
      end

      love.graphics.rectangle ("fill", self.x+cursorPosition, self.y+self.h/4-1,
                                       2, self.h-self.h/2)
    end

	iScissor:restore()
end

return TextBox
