local Module = {}

local initClickPosition = nil

function love.mousepressed(x, y, button)
	gui.mouseDown(x, y, button)

	local wx, wy = FieldManager.renderer:screen2World(love.graphics:getWidth(), love.graphics:getHeight())

	initClickPosition = {
		x = x, y = y,
		wx = wx, wy = wy,
	}
end

function love.resize(w, h)
	ScreenManager.width = w
	ScreenManager.height = h
end

function love.mousereleased(x, y, button)
	gui.mouseUp(x, y, button)
end

function love.keypressed(key, isrepeat)
	gui.keyDown(key, isrepeat)
end

function love.keyreleased(key)
	gui.keyUp(key)
end

function love.textinput(unicode)
	gui.input(unicode)
end

-- Local functions
local function doCloseWindow(window)
	window:close()
end

local function createAboutWindow()	
	-- Containers
	local c1,c2
	-- Buttons and raw widgets (labels)
	local b1,w1,w2
	-- Text Box
	-- The window itself
	local window

	window = gui.Window:new(true, "About")

	-- Vertical Container
	c1 = gui.VContainer:new()
	c1:begin()

	b1 = gui.Button:new('Thanks!')
	b1:begin(doCloseWindow)
	b1.userData = window
	b1.fixedH = 36

	w1 = gui.Widget:new('Lovely Tactics Hex')
	w1.fixedH = 36

	w2 = gui.Widget:new('Mad Programmer & GloamingCat')

	c1:addWidget(w1)
	c1:addWidget(w2)
	c1:addWidget(b1)

	window:setRootContainer(c1)

	gui.addWindow(window)
end

local function onLoadField(data)
	local fieldID = data.field

	FieldManager:loadField(fieldID)
end

local function createFieldsWindow()
	local window = gui.Window:new(true, "FIELDS")
	
	window.w = gui.border*20
	window.h = gui.border*15

	-- Containers
	local c1, c2, c3
	-- Scroll bars
	local s1
	-- Buttons
	local b1, b2

	c1 = gui.VContainer:new()
	c1:begin()
	c2 = gui.HContainer:new()
	c2:begin(true)
	c3 = gui.VContainer:new()
	c3:begin(false, true)

	b1 = gui.Button:new("0")
	b1:begin(onLoadField)
	b1.fixedH = 36
	b1.userData = {field = 0}

	b2 = gui.Button:new("1")
	b2:begin(onLoadField)
	b2.fixedH = 36
	b2.userData = {field = 1}

	c3:addWidget(b1)
	c3:addWidget(b2)

	s1 = gui.ScrollBar:new()
	s1:begin("vertical")
	s1:scrollContainer(c3)
	s1.fixedW = 24

	c2:addWidget(c3)
	c2:addWidget(s1)

	c1:addWidget(c2)
	
	window:setRootContainer(c1)

	gui.addWindow(window)
end

local function createMenuWindow()
	local window = gui.Window:new(true, "MENU")
	
	window.w = gui.border*12
	window.h = gui.border*20

	-- Containers
	local c1
	-- Labels
	local w1
	-- Buttons
	local b1, b2, b3, b4, b5

	c1 = gui.VContainer:new()
	c1:begin()

	w1 = gui.Widget:new("")
	b1 = gui.Button:new("About...")
	b1:begin(createAboutWindow)
	b1.userData = window
	b1.fixedH = 36

	b2 = gui.Button:new("Save...")
	b2:begin()
	b2.fixedH = 36

	b3 = gui.Button:new("Save as...")
	b3:begin()
	b3.fixedH = 36

	b4 = gui.Button:new("Load...")
	b4:begin()
	b4.fixedH = 36

	b5 = gui.Button:new("New...")
	b5:begin()
	b5.fixedH = 36

	c1:addWidget(b5)
	c1:addWidget(b2)
	c1:addWidget(b3)
	c1:addWidget(b4)
	c1:addWidget(w1)
	c1:addWidget(b1)

	window:setRootContainer(c1)

	gui.addWindow(window)
end

local function loadTileList()
	local images = {
		"images/Terrain/HexV.png",
	}
	local tile_list = {}

	-- Default tile sizes
	local tw = 36
	local th = 22

	for i, img_path in pairs(images) do
		local w, h = love.graphics.newImage(img_path):getDimensions()
		local y = 0, x

		while y < h do
			x = 0
			while x < w do
				table.insert(tile_list, {path = img_path, quad = {x = x, y = y, w = tw, h = th}})

				x = x+tw
			end

			y = y+th
		end		
	end

	return tile_list
end

local function createTilesWindow()
	local window = gui.Window:new(true, "TILES")
	
	window.w = gui.border*20
	window.h = gui.border*40

	-- Containers
	local c1, c2, c3, c4, c5
	-- Labels
	-- Scrollbar
	local s1
	-- Tex boxes
	local t1
	-- Buttons
	local b1

	c1 = gui.VContainer:new()
	c1:begin()
	c2 = gui.HContainer:new()
	c2:begin()
	c3 = gui.VContainer:new()
	c3:begin(false, true)
	c4 = gui.HContainer:new()
	c4:begin(true)
	c4.fixedH = 36
	c5 = gui.HContainer:new()
	c5:begin(true)
	c5.fixedH = 36

	for i=1,4 do
		local tab = gui.Button:new("#"..tostring(i))
		tab:begin()

		c5:addWidget(tab)
	end

	local tile_list = loadTileList() 
	local row_size = 3
	local shared_info = {
		focused = nil
	}
	
	for i=0,#tile_list/row_size do
		local row = gui.HContainer:new()
		row:begin(true)
		row.fixedH = 50

		for j=1,row_size do
			local tile = tile_list[i*row_size+j]
			
			if tile then
				local tmp = gui.TileInfo:new()
				tmp:begin(false, tile.path, tile.quad, shared_info)
				row:addWidget(tmp)
			end
		end

		c3:addWidget(row)
	end

	s1 = gui.ScrollBar:new()
	s1:begin("vertical")
	s1.fixedW = 24
	s1:scrollContainer(c3)

	b1 = gui.Button:new()
	b1:begin(false, "gui/magnifier.png", {x = 0, y = 0, w = 24, h = 24})
	b1.fixedW = 36
	t1 = gui.TextBox:new()
	t1:begin()

	c4:addWidget(t1)
	c4:addWidget(b1)

	c2:addWidget(c3)
	c2:addWidget(s1)

	c1:addWidget(c5)
	c1:addWidget(c2)
	c1:addWidget(c4)

	window:setRootContainer(c1)

	gui.addWindow(window)
end

require("lovely-tactics-hex/scripts/core/base/globals")

local function begin()
	-- Set a nice font
	love.graphics.setFont(love.graphics.newFont("gui/FogSans.otf", 14))

	Config.screen.nativeWidth = love.graphics:getWidth()
	Config.screen.nativeHeight = love.graphics:getHeight()

	ScreenManager:init()
	FieldManager:loadField(1)

	createTilesWindow()
	createFieldsWindow()
	createMenuWindow()
end

local function update()
	local x,y

	x = love.mouse.getX()
	y = love.mouse.getY()
	w = love.graphics:getWidth()
	h = love.graphics:getHeight()
	
	-- Fake events for mousemove
	-- since Löve2d don't provides one
	if not gui.mouseMove(x, y) then
		if love.mouse.isDown(1) then
			-- Movement in world space
			local ix, iy = FieldManager.renderer:screen2World(initClickPosition.x, initClickPosition.y)
			local fx, fy = FieldManager.renderer:screen2World(x, y)
			local dx, dy = fx-ix, fy-iy

			local wx, wy = initClickPosition.wx-dx, initClickPosition.wy-dy
			FieldManager.renderer:moveTo(wx, wy)
		end
	end

	-- GUI update
	gui.update()

	-- Update the map
	FieldManager:update()
end

local function render()
	love.graphics.setScissor(0,0,love.graphics:getWidth(),love.graphics:getHeight())
	love.graphics.clear(128, 60, 100, 255)

	ScreenManager:draw()	
	gui.render()
end

Module.begin = begin
Module.update = update
Module.render = render

return Module
