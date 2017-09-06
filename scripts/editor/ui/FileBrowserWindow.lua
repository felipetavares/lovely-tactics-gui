local GUIConf = require("ui/base/GUIConf")
local FileBrowserWindow = GUI.Window:new(true, "FILES")

function FileBrowserWindow.onCancel(self)
  self:close()
end

function FileBrowserWindow.onOpenDirectory(data)
  data.self:openDirectory(data.directory)
end

function FileBrowserWindow.onParentDirectory(self)
  self:openDirectory(self:getParentDirectory(self.currentDirectory))
end

function FileBrowserWindow:getParentDirectory(directory)
  local index = directory:reverse():find("/", 1)

  if index ~= nil then
    return directory:sub(1, -index-1)
  end

  return ""
end

function FileBrowserWindow:openDirectory(directory)
  self.currentDirectory = directory

  self.directoryTextBox.text = directory
  self.fileListContainer.widgets = {}
  self.fileListContainer.fullH = nil
  self.fileListContainer.offY = 0
  self.fileListScrollBar.position = 0

  local items = love.filesystem.getDirectoryItems(directory)

  for i,item in ipairs(items) do
    local fullItemPath = self.currentDirectory.."/"..item

    if love.filesystem.isDirectory(fullItemPath) then
      local itemButton = GUI.Button:new(item)
      itemButton:begin(self.onOpenDirectory)
      itemButton.fixedH = 36
      itemButton.userData = {self = self, directory = self.currentDirectory.."/"..item}

      self.fileListContainer:addWidget(itemButton)
    else
      local itemWidget = GUI.Widget:new(item)
      itemWidget.fixedH = 36

      self.fileListContainer:addWidget(itemWidget)
    end
  end

  self.fileListContainer:invalidate()
end

function FileBrowserWindow:begin(directory)
  self.w = GUIConf.border*50
  self.h = GUIConf.border*30

  self:center()

  -- Containers
  local c1, c2, c4, c5
  -- Widgets
  local w1
  -- Buttons
  local b3, b4, b5, b6, b7, b8
  -- TextBoxes
  local t1

  c1 = GUI.VContainer:new()
  c1:begin()
  c2 = GUI.HContainer:new()
  c2:begin(false)
  self.fileListContainer = GUI.VContainer:new()
  self.fileListContainer:begin(false, true)
  c4 = GUI.HContainer:new()
  c4:begin(true)
  c4.fixedH = 36
  c5 = GUI.HContainer:new()
  c5:begin(true)
  c5.fixedH = 36

  t1 = GUI.TextBox:new()
  t1:begin()
  t1.fixedH = 36

  self.directoryTextBox = GUI.TextBox:new()
  self.directoryTextBox:begin()
  self.directoryTextBox.fixedH = 36
  self.directoryTextBox.text = directory

  b3 = GUI.Button:new("Cancel")
  b3:begin(self.onCancel)
  b3.userData = self
  b3.fixedW = GUIConf.border*6

  b4 = GUI.Button:new("Open")
  b4:begin(self.onAction)
  b4.userData = self
  b4.fixedW = GUIConf.border*6

  b5 = GUI.Button:new()
  b5:begin(self.onBack, "gui_images/arrow-back.png", {x = 0, y = 0, w = 24, h = 24})
  b5.userData = self
  b5.fixedW = GUIConf.border*3

  b6 = GUI.Button:new()
  b6:begin(self.onForward, "gui_images/arrow-forward.png", {x = 0, y = 0, w = 24, h = 24})
  b6.userData = self
  b6.fixedW = GUIConf.border*3

  b7 = GUI.Button:new()
  b7:begin(self.onParentDirectory, "gui_images/arrow-up.png", {x = 0, y = 0, w = 24, h = 24})
  b7.userData = self
  b7.fixedW = GUIConf.border*3

  b8 = GUI.Button:new()
  b8:begin(self.onGoForward, "gui_images/new-folder.png", {x = 0, y = 0, w = 24, h = 24})
  b8.userData = self
  b8.fixedW = GUIConf.border*3

  w1 = GUI.Widget:new()

  c4:addWidget(t1)
  c4:addWidget(b3)
  c4:addWidget(b4)

  self.fileListScrollBar = GUI.ScrollBar:new()
  self.fileListScrollBar:begin("vertical")
  self.fileListScrollBar:scrollContainer(self.fileListContainer)
  self.fileListScrollBar.fixedW = 24

  c2:addWidget(self.fileListContainer)
  c2:addWidget(self.fileListScrollBar)

  c5:addWidget(b5)
  c5:addWidget(b6)
  c5:addWidget(b7)
  c5:addWidget(self.directoryTextBox)
  c5:addWidget(b8)

  c1:addWidget(c5)
  c1:addWidget(c2)
  c1:addWidget(c4)

  self:setRootContainer(c1)

  self:openDirectory(directory)

  GUI.addWindow(self)
end

return FileBrowserWindow
