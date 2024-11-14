local focus = require('slack.focus')

local logger = hs.logger.new('Slack')

local function slackUp()
  hs.eventtap.keyStroke({}, 'up', 0)
end

local function slackDown()
  hs.eventtap.keyStroke({}, 'down', 0)
end

local function startSlackReminder()
  focus.mainMessageBox()

  hs.timer.doAfter(0.3, function()
    hs.eventtap.keyStrokes("/remind me at ")
  end)
end

local function openSlackThread()
  focus.mainMessageBox()

  hs.timer.doAfter(0.1, function()
    slackUp()
    hs.eventtap.keyStroke({}, 't', 0)
    focus.threadMessageBox(true)
  end)
end

logger.i("Start")
