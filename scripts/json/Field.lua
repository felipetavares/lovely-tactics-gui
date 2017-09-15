local File = require("json/File")
local Field = {}
setmetatable(Field, {__index=File})

function Field:new(filename)
  local o = {}

  -- Read from disk
  if filename then
    o = File:new(filename)
  else
    o = File:new()
  end

  setmetatable(o, {__index=self})

  -- The class is *granted* to
  -- have the fields below
  File.merge(o, {
    id = 0,
    sizeX = 15,
    sizeY = 15,
    prefs = {
      name = "Unamed",
      defaultRegion = 0,
      onStart = {
        path = "",
        param = ""
      },
      transitions = {},
      tags = {}
    },
    battle = {
      parites = {},
      playerParty = -1
    },
    characters = {},
    layers = {}
  })

  o.nowrite.offset = {
    x = love.graphics:getWidth()/2,
    y = love.graphics:getHeight()/2
  }

  o.nowrite.scale = {
    x = 2,
    y = 2
  }

  o.nowrite.update = true
  o.nowrite.nextScheduledUpdate = 0
  o.nowrite.animationSpeed = 0.3
  o.nowrite.animationCounter = 0

  -- Makes sure all layer data is filled in
  o:resizeLayers()
  -- Loads tile images to memory
  o:loadTiles()
  -- Moves tiles to GPU
  o:update()

  return o
end

function Field:screen2World(x, y)
  local scale = self.nowrite.scale
  local offset = self.nowrite.offset

  return (x-offset.x)/scale.x, (y-offset.y)/scale.y
end

function Field:world2Screen(x, y)
  local scale = self.nowrite.scale
  local offset = self.nowrite.offset

  return x*scale.x+offset.x, y*scale.y+offset.y
end

function Field:loadTiles()
  self.nowrite.tilesets = {}

  -- Load all the images used in the field
  for id=0,#Database.terrains do
    local tileData = Database.terrains[id]
    local imageData = Database.animations[tileData.image]

    if self.nowrite.tilesets[imageData.path] == nil then
      self.nowrite.tilesets[imageData.path] = love.graphics.newImage("images/"..imageData.path)
    end
  end

  self.nowrite.quads, self.nowrite.batches = self:makeQuadsAndBatches()
end

function Field:addToBatch(batch, quad, x, y)
  if batch:getCount() == batch:getBufferSize() then
    batch:setBufferSize(batch:getBufferSize()*2)
  end

  batch:add(quad, x, y)
end

function Field:makeQuadsAndBatches()
  local quads = {}
  local batches = {}

  local minBatchSize = 32

  -- Create quads and a sprite batch for each tileset
  for path, tileset in pairs(self.nowrite.tilesets) do
    quads[path] = self:makeQuadsFromImage(tileset)
    batches[path] = love.graphics.newSpriteBatch(tileset, minBatchSize)
  end

  return quads, batches
end

function Field:makeQuadsFromImage(image)
  local x, y = 0, 0
  local w, h = image:getDimensions()
  local dx, dy = Config.grid.tileW/2, Config.grid.tileH/2
  local quads = {}
  local newQuad = love.graphics.newQuad

  while x < w do
    local col = {}

    while y < h do
      table.insert(col, newQuad(x, y, dx, dy, w, h))

      y = y+dy
    end

    table.insert(quads, col)
    x = x+dx
    y = 0
  end

  return quads
end

function Field:updateNextFrame()
  self.nowrite.update = true
end

function Field:animationStep()
  local currentTime = love.timer.getTime()

  if currentTime > self.nowrite.nextScheduledUpdate then
    self.nowrite.nextScheduledUpdate = currentTime+self.nowrite.animationSpeed
    self.nowrite.animationCounter = self.nowrite.animationCounter+1
    return true
  end

  return false
end

function Field:update()
  local batches = self.nowrite.batches

  if self.nowrite.update or self:animationStep() then
    self.nowrite.update = nil

    -- Clear all batches
    for _, batch in pairs(batches) do
      batch:clear()
    end

    for i, layer in ipairs(self.layers) do
      self:updateLayer(layer)
    end
  end
end

function Field:animationOffset(x, y)
  return (x+y)%3
end

function Field:updateLayer(layer)
  local tilesets = self.nowrite.tilesets
  local quads = self.nowrite.quads
  local scale = self.nowrite.scale
  local batches = self.nowrite.batches
  local offset = self.nowrite.offset
  local w, h = Config.grid.tileW, Config.grid.tileH
  local sw, sh = love.graphics:getDimensions()

  for y=1,self.sizeY do
    for x=1,self.sizeX do
      local value = layer.grid[x][y]

      local function sameType (layer, i1, j1, i2, j2)
        if (i1 < 1 or i1 > #layer.grid or i2 < 1 or i2 > #layer.grid) then
          return true
        end
        if (j1 < 1 or j1 > #layer.grid[i1] or j2 < 1 or j2 > #layer.grid[i2]) then
          return true
        end
        local tile1 = layer.grid[i1][j1]
        local tile2 = layer.grid[i2][j2]
        if tile1 >= 0 and tile2 >= 0 then
          return tile1 == tile2
        else
          return false
        end
      end

      if value >= 0 then
        px, py = math.field.tile2Pixel(x, y, layer.info.height)
        px, py = px+offset.x/scale.x, py+offset.y/scale.y

        if self:insideScreen(px, py, sw, sh) then
          local ox, oy
          local rows = math.field.autoTileRows(layer, x, y, sameType)
          local ts = Database.animations[Database.terrains[value].image].path
          local data = Database.animations[Database.terrains[value].image]

          local col = 0
          col = (self.nowrite.animationCounter+self:animationOffset(x, y))%data.cols
          col = col * 2

          ox, oy = data.x/w*2+col, data.y/h*2+rows[1]*2
          self:addToBatch(batches[ts], quads[ts][ox+1][oy+1], px-w/2, py-h/2)

          ox, oy = data.x/w*2+col, data.y/h*2+rows[3]*2
          self:addToBatch(batches[ts], quads[ts][ox+1][oy+2], px-w/2, py)

          ox, oy = data.x/w*2+col, data.y/h*2+rows[4]*2
          self:addToBatch(batches[ts], quads[ts][ox+2][oy+2], px, py)

          ox, oy = data.x/w*2+col, data.y/h*2+rows[2]*2
          self:addToBatch(batches[ts], quads[ts][ox+2][oy+1], px, py-h/2)
        end
      end
    end
  end
end

function Field:render(layer)
  local scale = self.nowrite.scale
  local batches = self.nowrite.batches

  love.graphics.push()
  love.graphics.scale(scale.x, scale.y)

  -- Draw all batches
  for _, batch in pairs(batches) do
    love.graphics.draw(batch)
  end

  love.graphics.pop()
end

function Field:insideScreen(x, y, w, h)
  local tw, th = Config.grid.tileW, Config.grid.tileH

  return x >= -tw and y >= -th and x <= w+tw and y <= h+th
end

function Field:getAt(layer, x, y)
  if x > 0 and y > 0 and layer > 0 and
     x <= self.sizeX and y <= self.sizeY then
    return self.layers[layer].grid[x][y]
  else
    return -2
  end
end

function Field:editAt(layer, x, y, value)
  -- Edit the value
  self.layers[layer].grid[x][y] = value

  self:updateNextFrame()
end

function Field:addLayer(name, type, height, tags, fill)
  table.insert(self.layers, {
    info = {
      name = name or "Unamed",
      type = type or 0,
      height = height or 0,
      tags = tags or 0
    },
    visible = true,
    grid = self:newGrid(fill)
  })

  self:updateNextFrame()
end

function Field:setSize(w, h)
  self.sizeX = w
  self.sizeY = h

  -- Make the layers the right size
  self:resizeLayers()
end

-- The following functions resize layers
-- to match the size in (sizeX, sizeY)
function Field:resizeLayers()
  for _, layer in ipairs(self.layers) do
    for _, row in ipairs(layer.grid) do
      -- Makes row the right size
      self:resizeRow(row)
    end

    -- Add or remove rows as needed
    self:resizeRows(layer.grid)
  end

  self:updateNextFrame()
end

function Field:resizeRows(rows)
  if #rows < self.sizeY then
    -- How many to add
    local d = self.sizeY-#rows

    for i=1,d do
      table.insert(rows, self:newRow())
    end
  elseif #rows > self.sizeY then
    -- How many to remove
    local d = #rows-self.sizeY

    for i=1,d do
      table.remove(rows)
    end
  end
end

function Field:resizeRow(row)
  if #row < self.sizeX then
    -- Delta length
    local d = self.sizeX-#row

    -- -1 is empty space
    for i=1,d do
      table.insert(row, -1)
    end
  elseif #row > self.sizeX then
    local d = #row-self.sizeX

    for i=1,d do
      table.remove(row)
    end
  end
end

function Field:newRow(fill)
  local row = {}

  for i=1,self.sizeX do
    table.insert(row, fill or -1)
  end

  return row
end

function Field:newGrid(fill)
  local grid = {}

  for i=1,self.sizeY do
    table.insert(grid, self:newRow(fill))
  end

  return grid
end

return Field
