local Widget = require("ui/widgets/Widget")
local GUIConf = require("ui/base/GUIConf")
local Container = Widget:new()

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

function Container:addWidgetAt(widget, p)
  widget.container = self

  table.insert(self.widgets, p, widget)

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

  local pX = self.x+GUIConf.border/2
  local pY = self.y+GUIConf.border/2
  local pW = self.w-GUIConf.border
  local pH = self.h-GUIConf.border

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

  local calcH = 0

  for wid=1, #self.widgets do
    if self.widgets[wid].fixedH then
      calcH = calcH + self.widgets[wid].fixedH
    else
      calcH = calcH + 36
    end
  end

  if calcH > self.fullH then
    self.fullH = calcH
  end

  if self.invalid then
    self:resize()
  end

  for wid=1, #self.widgets do
    self.widgets[wid]:update()
  end
end

return Container
