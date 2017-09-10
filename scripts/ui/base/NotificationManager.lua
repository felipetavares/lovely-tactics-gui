local NotificationManager = {}

local notifications = {}

function NotificationManager.addNotification(notification)
  for _, v in ipairs(notifications) do
    v:moveUp()
  end

  table.insert(notifications, notification)
end

function NotificationManager.render()
  for _, v in ipairs(notifications) do
    v:render()
  end
end

function NotificationManager.update()
  for _, v in ipairs(notifications) do
    v:update()
  end

  local currentTime = love.timer.getTime()

  for i=#notifications,1,-1 do
    if notifications[i].killTime < currentTime then
      table.remove(notifications, i)
    end
  end
end

function NotificationManager.resize(w, h)
  for _, v in ipairs(notifications) do
    v:resize(w, h)
  end
end

return NotificationManager
