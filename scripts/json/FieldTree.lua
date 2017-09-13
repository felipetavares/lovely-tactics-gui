local FieldTree = require("json/File")

function FieldTree:new(filename)
  local o = JSON.load(filename)
end
