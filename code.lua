local Module = {}

function love.mousepressed(x, y, button)
	gui.mouseDown(x, y, button)
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

local function createToolbarWindow()
	local window = gui.Window:new(true, "TOOLBAR")
	
	window.w = 200

	-- Containers
	local c1
	-- Labels
	local w1
	-- Buttons
	local b1

	c1 = gui.VContainer:new()
	c1:begin()

	w1 = gui.Widget:new("TOOL LIST")
	b1 = gui.Button:new("About")
	b1:begin(createAboutWindow)
	b1.userData = window
	b1.fixedH = 36

	c1:addWidget(b1)
	c1:addWidget(w1)
	
	window:setRootContainer(c1)

	gui.addWindow(window)
end

local function createTilesetWindow()
	local window = gui.Window:new(true, "TILESET")
	
	window.w = 200

	-- Containers
	local c1, c2, c3, c4
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

	local tile_list = {
		"tiles/plain.png",
		"tiles/sand.png",
		"tiles/water.png",
		"tiles/road.png"
	}

	for i=0,#tile_list/3 do
		local line = gui.HContainer:new()
		line:begin(true)
		line.fixedH = 50

		for j=1,3 do
			local tmp = gui.Button:new()
			tmp:begin(false, tile_list[i*3+j], {x = 0, y = 155, w = 36, h = 22})
			line:addWidget(tmp)
		end

		c3:addWidget(line)
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

	c1:addWidget(c2)
	c1:addWidget(c4)

	window:setRootContainer(c1)

	gui.addWindow(window)
end

local function begin()
	-- Set a nice font
	love.graphics.setFont(love.graphics.newFont("gui/FogSans.otf", 14))

	createTilesetWindow()
	createToolbarWindow()
end

local function update()
	local x,y

	x = love.mouse.getX()
	y = love.mouse.getY()

	-- Fake events for mousemove
	-- since Löve2d don't provides one
	gui.mouseMove(love.mouse.getX(), love.mouse.getY())

	-- GUI update
	gui.update()
end

local function render()
	love.graphics.setScissor(0,0,love.graphics:getWidth(),love.graphics:getHeight())
	love.graphics.clear(128, 60, 100, 255)

	gui.render()
end

Module.begin = begin
Module.update = update
Module.render = render

return Module
