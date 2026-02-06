require "utils"
require "window"
-- require "launcher"
require "control"
require "timer"
require "events"
require "slack"

hs.alert.defaultStyle.textSize = 64
-----------------------------------------------
-- Reload config on write
-----------------------------------------------
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

-- ModalMgr Spoon is available but not currently used.
-- hs.loadSpoon("ModalMgr")

-- Define default Spoons which will be loaded later
if not hspoon_list then
  hspoon_list = {"Calendar", "Shortcuts", "Windows" -- "CircleClock",
  }
end

-- Load those Spoons
for _, v in pairs(hspoon_list) do
  hs.loadSpoon(v)
end

-- hs.loadSpoon("Microphone"):bindHotKeys()

hs.ipc.cliInstall()

hs.logger.setGlobalLogLevel('debug')