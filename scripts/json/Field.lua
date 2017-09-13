local File = require("json/File")
local Field = File:new()

local FieldClass = require("core/field/Field")
local List = require('core/datastruct/List')

function Field:new(filename)
  local o = {}

  -- Read from disk
  if filename then
    o = File.new(self, filename)
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

  -- Makes sure all layer data is filled in
  o:resizeLayers()

  return o
end

function Field:editAt(layer, x, y, value)
  -- Edit the value
  self.layers[layer][x][y] = value

  -- Pass the changes to the display
  self:syncTile(layer, x, y)
end

-- layn is the layer index
function Field:syncTile(layi, x, y)
  -- FIXME: hardcoded terrinLayers and height=0
  local layer = FieldManager.currentField.terrainLayers[0][layi]

  layer.grid[x][y]:setTerrain(self.layers[layi][x][y])
end

-- Send the entire field to the field manager
-- This is a stripped down version of
-- FieldManager:loadField without the JSON loading.
-- Instead it uses self as a source of data
-- FIXME: This should be moved to FieldManager
function Field:sync()
  FieldManager.updateList = List()
  FieldManager.characterList = List()

  if FieldManager.renderer then
    FieldManager.renderer:deactivate()
  end

  FieldManager.renderer = FieldManager:createCamera(self.sizeX, self.sizeY, #self.layers)

  FieldManager.currentField = FieldClass(self)
  FieldManager.currentField:mergeLayers(self.layers)

  for tile in FieldManager.currentField:gridIterator() do
    tile:createNeighborList()
  end

  collectgarbage("collect")
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

  -- FIXME: needs to sync
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

    for i=1,d do
      table.remove(row)
    end
  elseif #row > self.sizeX then
    local d = #row-self.sizeX

    -- -1 is empty space
    for i=1,d do
      table.insert(row, -1)
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
