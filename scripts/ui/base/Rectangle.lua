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

return Rectangle
