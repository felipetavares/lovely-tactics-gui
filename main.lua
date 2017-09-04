function love.load ()
	print("GUI Demo - Lovely Tactics Hex")

	--love.window.setMode(0, 0, {fullscreen=true, resizable=false})
	love.window.setMode(800, 600, {fullscreen=false, resizable=true})

	-- Fast terminal out
	io.stdout:setvbuf("no")

	-- UTF8 module [EXTERNAL]
	utf8 	= love.filesystem.load("utf8.lua")()
	
	-- GUI
	gui 	= love.filesystem.load("gui.lua")()
	-- App code
	code 	= love.filesystem.load("code.lua")()

	love.window.setTitle ("GUI Demo - Lovely Tactics Hex")

	code.begin()
end

function love.update ()
	code.update()
end

function love.draw ()
	code.render()
end

-- Helper
function table.invert(t)
  local u = { }
  for k, v in pairs(t) do u[v] = k end
  return u
end
