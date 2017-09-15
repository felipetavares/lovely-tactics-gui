local File = {}

function File.merge(a, b)
  for k, v in pairs(b) do
    if type(v) == "table" then
      if not a[k] then
        a[k] = v
      else
        File.merge(a[k], v)
      end
    else
      if not a[k] then
        a[k] = v
      end
    end
  end
end

function File:new(filename)
  local o = {}

  if filename then
    local data = love.filesystem.read(filename)
    o = JSON.decode(data)

    assert(o, "Could not load "..filename)
  end

  setmetatable(o, {__index=File})

  -- Data that shall not be written to disk
  o.nowrite = {
    filename = filename
  }

  return o
end

function File:write(filename)
  -- Makes sure self.nowrite is not written
  local nowrite = self.nowrite
  self.nowrite = nil

  -- If we have a filename arg. use it
  if not filename then
    filename = nowrite.filename
  end

  -- Open file
  local file = io.open(filename, "w")

  assert(file, "Could not open "..filename)

  -- Set as default
  io.output(file)

  -- Write
  io.write(JSON.encode(self, {indent = true}))

  -- Close
  io.close(file)

  self.nowrite = nowrite
end

function File:read(filename)
  -- TODO
end

return File
