local iv = require("ui/base/iv")
local Skin = require("ui/base/Skin")
local GUIConf = require("ui/base/GUIConf")

local Notification = {}

function Notification:new(message, type)
  local notificationTime = 5
  local transitionTime = {
    x = 0.5,
    y = 0.5
  }

  local iconPath = "gui_images/notification-info.png"

  if type == "alert" then
    iconPath = "gui_images/notification-alert.png"
  elseif type == "error" then
    iconPath = "gui_images/notification-error.png"
  end

  local o = {
    x = iv:new(transitionTime.x), y = iv:new(transitionTime.y),
    w = 0, h = 0,
    skin = Skin:new("gui_images/notification.png"),
    icon = love.graphics.newImage(iconPath),
    killTime = love.timer.getTime()+notificationTime,
    leaveTime = transitionTime.x,
    movingToDeath = false,
    message = message,
    opacity = 255,
    level = 1
  }

  setmetatable(o, {__index=self})

  o.h = GUIConf.border*4
  o:calculateWidth()
  o:calculateInitialPosition()
  o:calculateFinalPosition()

  return o
end

function Notification:calculateInitialPosition()
  local w, h = love.graphics:getDimensions()

  self.x:setNow(w+self.w)
  self.y:setNow(h-self.h-GUIConf.border)
end

function Notification:calculateFinalPosition()
  local w, h = love.graphics:getDimensions()

  self.x:set(w-self.w-GUIConf.border)
  self.y:set(h-(self.h+GUIConf.border)*self.level)
end

function Notification:calculateWidth()
  local font = love.graphics.getFont()

  self.w = font:getWidth(self.message)+GUIConf.border*5
end

function Notification:update()
  if self.killTime-love.timer.getTime() < self.leaveTime and not self.movingToDeath then
    local w, h = love.graphics:getDimensions()
    self.movingToDeath = true

    self.x:set(w)
  end
end

function Notification:resize(w, h)
  self:calculateFinalPosition()
end

function Notification:moveUp()
  self.y:set(self.y.y1-self.h-GUIConf.border)
  self.opacity = self.opacity*0.5
  self.level = self.level + 1
end

function Notification:render()
  love.graphics.setColor(255, 255, 255, self.opacity)

  local x, y = self.x:get(), self.y:get()

  -- Round text coords so the text isn't blurry
  local tx, ty = math.round(x+GUIConf.border*4),
                 math.round(y+GUIConf.border*2+GUIConf.textOffset)

  self.skin:draw(x, y, self.w, self.h)
  love.graphics.draw(self.icon, x+GUIConf.border, y+GUIConf.border)
  love.graphics.print(self.message, tx, ty)
end

return Notification
