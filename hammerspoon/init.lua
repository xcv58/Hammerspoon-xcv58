require "utils"
require "window"
require "luncher"
require "control"

hs.alert.defaultStyle.textSize = 64
-----------------------------------------------
-- Reload config on write
-----------------------------------------------
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
