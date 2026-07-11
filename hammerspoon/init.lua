local utils = require "utils"
require "window"
require "control"
require "timer"
require "events"
require "chrome"

-- Hold Control + Option to move the window under the cursor.
hs.loadSpoon("Windows")
spoon.Windows:init()

hs.alert.defaultStyle.textSize = 64
-----------------------------------------------
-- Reload config on write
-----------------------------------------------
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", utils.reloadConfig):start()
hs.alert.show("Config loaded")

hs.ipc.cliInstall()

hs.logger.setGlobalLogLevel('debug')
