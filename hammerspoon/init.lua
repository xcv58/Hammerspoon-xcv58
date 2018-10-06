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

-- ModalMgr Spoon must be loaded explicitly, because this repository heavily relies upon it.
hs.loadSpoon("ModalMgr")

-- Define default Spoons which will be loaded later
if not hspoon_list then
  hspoon_list = {
   "Calendar",
    "CircleClock",
  }
end

-- Load those Spoons
for _, v in pairs(hspoon_list) do
  hs.loadSpoon(v)
end
