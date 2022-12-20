--- === Shortcuts ===
---
---
local obj = {}
obj.__index = obj
obj.name = "Shortcuts"
obj.version = "0.0.1"
obj.author = "xcv58 <hammerspoon_windows@xcv58.com>"
obj.homepage = "https://github.com/xcv58/Hammerspoon-xcv58"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- Windows.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new("Shortcuts")
local logger = obj.logger
-- local hyper = {"⌘", "⌃", "⇧"}
local hyper = {"⌘", "⌃"}

local doWithTimeOut = [[
  on doWithTimeout(uiScript, timeoutSeconds)
    set endDate to (current date) + timeoutSeconds
    repeat
      try
        run script "tell application \"System Events\"
  " & uiScript & "
  end tell"
        exit repeat
      on error errorMessage
        if ((current date) > endDate) then
          error "Can not " & uiScript
        end if
      end try
    end repeat
  end doWithTimeout
]]

local function clickSoundIcon()
  local script = string.format([[
    tell application "System Events" to click menu bar item 5 of menu bar 1 of process "Control Center"
  ]])
  hs.osascript.applescript(script)
end

local function clickShortcutsItem(item)
  local script = string.format([[
    set timeoutSeconds to 2.0
    set uiScript to "click menu bar item \"Shortcuts\" of menu bar 1 of application process \"Control Center\""
    my doWithTimeout(uiScript, timeoutSeconds)

    set timeoutSeconds to 2.0
    set uiScript to "click checkbox \"%s\" of window \"Control Center\" of application process \"Control Center\""
    my doWithTimeout(uiScript, timeoutSeconds)
    %s
  ]], item, doWithTimeOut)
  hs.osascript.applescript(script)
end

local function turnOnMeeting()
  logger.d('turnOnMeeting')
  clickShortcutsItem("Meeting")
end

local function turnOfMeeting()
  logger.d('turnOfMeeting')
  clickShortcutsItem("Stop Meeting")
end

hs.hotkey.bind(hyper, "m", turnOnMeeting)
hs.hotkey.bind(hyper, "n", turnOfMeeting)
hs.hotkey.bind(hyper, "x", clickSoundIcon)

--- Shortcuts:init()
--- Method
--- init.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The Shortcuts object
function obj:init()
  self.logger.i("init")
  return self
end

return obj
