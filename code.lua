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

local function createTilesetWindow()
	local window = gui.Window:new(true, "TILESET")
	
	-- Containers
	local c1
	-- Labels
	local w1

	c1 = gui.VContainer:new()
	c1:begin()

	w1 = gui.Widget:new("TILES WIDGET")

	c1:addWidget(w1)
	
	window:setRootContainer(c1)

	gui.addWindow(window)
end

local function createAboutWindow()	
	-- Containers
	local c1,c2
	-- Buttons and raw widgets (labels)
	local b1,w1,w2
	-- Text Box
	local t1
	-- The window itself
	local window

	window = gui.Window:new(true, "About Window")

	-- Vertical Container
	c1 = gui.VContainer:new()
	c1:begin()

	b1 = gui.Button:new('OK')
	b1:begin(doCloseWindow)
	b1.userData = window
	b1.fixedH = 24

	w1 = gui.Widget:new('ABOUT')
	w1.fixedH = 24

	w2 = gui.Widget:new('GUI DEMO')

	t1 = gui.TextBox:new("Hello Lovely Tactics!")
	t1:begin()
	t1.fixedH = 24

	c1:addWidget(w1)
	c1:addWidget(w2)
	c1:addWidget(t1)
	c1:addWidget(b1)

	window:setRootContainer(c1)

	gui.addWindow(window)
end

local function begin()
	-- Set a nice font
	love.graphics.setFont(love.graphics.newFont("gui/arcadeclassic.ttf", 14))

	createTilesetWindow()
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
