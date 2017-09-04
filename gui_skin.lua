--[=[
A gui_skin is a (usually) 12x12 image divided in 9 cells (3x3)
that can be used to draw gui elements	
]=]--

local Module = {}

function Module:new(image_path)
	local image = love.graphics.newImage(image_path)
	local img_w, img_h = image:getDimensions()
	local cell_w = img_w/3
	local cell_h = img_h/3

	local o = {
		cell_w = cell_w,
		cell_h = cell_h,
		-- The image to be used
		image = image,
		-- Quads for each of the 9 cells
		-- We don't use a matrix here because the drawing
		-- calls for each of the quads are quite different
		-- Top left
		q_tl = love.graphics.newQuad(0, 0, cell_w, cell_h, img_w, img_h),
		-- Top right
		q_tr = love.graphics.newQuad(cell_w*2, 0, cell_w, cell_h, img_w, img_h),
		-- Bottom left
		q_bl = love.graphics.newQuad(0, cell_h*2, cell_w, cell_h, img_w, img_h),
		-- Bottom right
		q_br = love.graphics.newQuad(cell_w*2, cell_h*2, cell_w, cell_h, img_w, img_h),
		-- Left center
		q_lc = love.graphics.newQuad(0, cell_h, cell_w, cell_h, img_w, img_h),
		-- Right center
		q_rc = love.graphics.newQuad(cell_w*2, cell_h, cell_w, cell_h, img_w, img_h),
		-- Top center
		q_tc = love.graphics.newQuad(cell_w, 0, cell_w, cell_h, img_w, img_h),
		-- Bottom center
		q_bc = love.graphics.newQuad(cell_w, cell_h*2, cell_w, cell_h, img_w, img_h),
		-- Center
		q_c = love.graphics.newQuad(cell_w, cell_h, cell_w, cell_h, img_w, img_h),
	}
	setmetatable(o, {__index=self})

	return o
end

-- Draws a skin at a given position in a given size
function Module:draw(x, y, w, h)
	-- Scales for the parts that stretch
	local scale_w = (w-self.cell_w*2)/self.cell_w 
	local scale_h = (h-self.cell_h*2)/self.cell_h

	-- Top
	love.graphics.draw(self.image, self.q_tl, x, y)
	love.graphics.draw(self.image, self.q_tr, x+w-self.cell_w, y)
	love.graphics.draw(self.image, self.q_tc, x+self.cell_w, y, 0, scale_w, 1)
	-- Middle
	love.graphics.draw(self.image, self.q_lc, x, y+self.cell_h, 0, 1, scale_h)
	love.graphics.draw(self.image, self.q_c, x+self.cell_w, y+self.cell_h, 0, scale_w, scale_h)
	love.graphics.draw(self.image, self.q_rc, x+w-self.cell_w, y+self.cell_h, 0, 1, scale_h)
	-- Bottom
	love.graphics.draw(self.image, self.q_bl, x, y+h-self.cell_h)
	love.graphics.draw(self.image, self.q_br, x+w-self.cell_w, y+h-self.cell_h)
	love.graphics.draw(self.image, self.q_bc, x+self.cell_w, y+h-self.cell_h, 0, scale_w, 1)
end

return Module
