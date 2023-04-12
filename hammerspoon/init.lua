require "utils"
-- require "window"
require "launcher"
require "control"
require "timer"
require "events"
require "slack"

local docs = require('GoogleDocsCodePaste')

-- Bind this to whatever mods + key you want:
hs.hotkey.bind({'cmd', 'alt'}, 'v', docs.pasteToGoogleDocs)

hs.alert.defaultStyle.textSize = 64
-----------------------------------------------
-- Reload config on write
-----------------------------------------------
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

-- ModalMgr Spoon must be loaded explicitly, because this repository heavily relies upon it.
hs.loadSpoon("ModalMgr")

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