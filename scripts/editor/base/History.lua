local History = {}

function History:new(field)
  local o = {
    -- All the historic actions in the file
    stack = {},
    -- Pointer to the current position
    pointer = 1,
    -- Reference to the render field
    field = field
  }

  setmetatable(o, {__index=self})

  return o
end

function History.makeAction(name, tile, to)
  local ActionTable = {
    eraser = {
      name = "eraser",
      humanName = "Eraser tool",
      tile = {}
    },
    pencil = {
      name = "pencil",
      humanName = "Pencil tool",
      tile = {}
    }
  }

  local action = ActionTable[name]

  action.tile = tile

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
  local tile = action.tile

  self.field:editAt(tile.layer, tile.x, tile.y, tile.old)

  self:messageUser("Undid "..action.humanName)
end

function History:applyRedo(action)
  local tile = action.tile

  self.field:editAt(tile.layer, tile.x, tile.y, tile.new)

  self:messageUser("Redid "..action.humanName)
end

function History:messageUser(message, type)
  local notification = GUI.Notification:new(message, type)

  GUI.NotificationManager.addNotification(notification)
end

return History
