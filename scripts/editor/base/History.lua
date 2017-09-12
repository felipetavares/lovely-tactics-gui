-- From: https://gist.github.com/tylerneylon/81333721109155b2d244
function copy3(obj, seen)
  -- Handle non-tables and previously-seen tables.
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end

  -- New table; mark it as seen an copy recursively.
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy3(k, s)] = copy3(v, s) end
  return res
end

local History = {}

function History:new()
  local o = {
    -- All the historic actions in the file
    stack = {},
    -- Pointer to the current position
    pointer = 1
  }

  setmetatable(o, {__index=self})

  return o
end

function History.makeAction(name, tile, to)
  local ActionTable = {
    eraser = {
      name = "eraser",
      humanName = "Eraser tool",
      tile = {},
      tileCopy = {}
    },
    pencil = {
      name = "pencil",
      humanName = "Pencil tool",
      tile = {},
      to = {},
      tileCopy = {}
    }
  }

  local action = ActionTable[name]

  action.tile = tile
  action.tileCopy = copy3(tile)

  if action.to ~= nil then
    action.to = to
  end

  return action
end

function History:commit(action)
  -- Remove all further actions from this point
  while self.pointer <= #self.stack do
    table.remove(self.stack, self.pointer)
  end

  -- Insert the new action at the current position
  table.insert(self.stack, self.pointer, action)

  -- Move the current position up
  self.pointer = self.pointer + 1
end

function History:undo()
  if self.pointer > 1 then
    self.pointer = self.pointer - 1

    -- Get previous saved action from the list
    local action = self.stack[self.pointer]

    -- Set the editor action to the fetched action
    self:applyUndo(action)
  else
    self:messageUser("Oldest change", "alert")
  end
end

function History:redo()
  -- We are not at the tip of the history
  if #self.stack >= self.pointer then
    -- Get it
    local action = self.stack[self.pointer]

    -- Move to a newer change
    self.pointer = self.pointer + 1

    -- Apply it
    self:applyRedo(action)
  else
    self:messageUser("Latest change", "alert")
  end
end

-- Applies a action to the editor
function History:applyUndo(action)
  local terrainID = -1

  if action.tileCopy.data ~= nil then
    terrainID = action.tileCopy.data.id
  end

  action.tile:setTerrain(terrainID)

  self:messageUser("Undid "..action.humanName)
end

function History:applyRedo(action)
  local terrainID = -1

  if action.to ~= nil then
    terrainID = action.to
  end

  action.tile:setTerrain(terrainID)

  self:messageUser("Redid "..action.humanName)
end

function History:messageUser(message, type)
  local notification = GUI.Notification:new(message, type)

  GUI.NotificationManager.addNotification(notification)
end

return History
