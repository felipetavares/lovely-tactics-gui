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

function iv:setNow (value)
	self.y0 = value
	self.y1 = value
	self.x0 = love.timer.getTime()
	self.x1 = self.x0+self.time
end

function iv:get ()
  local x = love.timer.getTime()-self.x0

  local d = self.x1-self.x0
  local b = self.y0
  local c = self.y1-self.y0

  if x == 0 then
    return self.y0
  end

  x = x/d

  if x == 1 then
    return self.y1
  end

  local p = d * 0.3 * 1.5
  local s = p / 4

  if x < 1 then
    local postFix = c * math.pow(2, 10*(x-1))

    x = x-1

    return -0.5*(postFix * math.sin((x*d-s)*(2*math.pi)/p)) + b
  end

  local postFix = c * math.pow(2, -10*(x-1))

  x = x -1

  return postFix * math.sin((x*d-s)*(2*math.pi)/p )*0.5 + c + b;
end

return iv
