local GUIConf = require("ui/base/GUIConf")
local ToolsWindow = GUI.Window:new(true, "")

function ToolsWindow.onChangeTool(data)
  data.self.editor:onChangeTool(data.tool)
end

function ToolsWindow:begin(editor)
  self.editor = editor

  self.w = GUIConf.border*5
  self.h = GUIConf.border*15

  -- Containers
  local c1, c2, c3

  c1 = GUI.VContainer:new()
  c1:begin()

  local shared_info = {}

  local tools = {
    {
      image = "gui_images/eraser.png",
      name = "eraser"
    },
    {
      image = "gui_images/pencil.png",
      name = "pencil"
    }
  }

  for k, v in ipairs(tools) do
    local tool = GUI.TileInfo:new()
    tool:begin(self.onChangeTool, v.image, {x=0,y=0,w=24,h=24}, shared_info)
    tool.userData = {self = self, tool = v}

    tool:click()

    c1:addWidget(tool)
  end

  self:setRootContainer(c1)

  GUI.addWindow(self)
end

return ToolsWindow
