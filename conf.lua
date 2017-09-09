function love.conf(t)
  love.filesystem.setRequirePath('lovely-tactics-hex/scripts/?.lua;/?.lua;scripts/?.lua')

  JSON = require('core/save/JsonParser')
  Config = JSON.load('lovely-tactics-hex/data/system/config')

  t.identity = Config.name 
  --t.window.title = Config.name
  --t.window.icon = 'images/icon32.png'
  --t.window.width = Config.screen.nativeWidth * Config.screen.widthScale
  --t.window.height = Config.screen.nativeHeight * Config.screen.heightScale
  t.window.fullscreentype = 'desktop'
  t.window.vsync = true
  t.modules.joystick = false
  t.modules.physics = false
end
