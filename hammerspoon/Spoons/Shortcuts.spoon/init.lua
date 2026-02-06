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
    tell application "System Events" to tell process "Control Center"
	set i to 1
	repeat with anElement in menu bar items of menu bar 1
		if description of anElement is "Sound" then
			exit repeat
		end if
		set i to i + 1
	end repeat
	click (menu bar item i) of menu bar 1
end tell
delay 0.5

tell application "System Events" to tell process "Control Center"
	set i to 1
	repeat with anElement in checkbox of scroll area 1 of group 1 of window 1
		set identifier to value of attribute "AXIdentifier" of anElement
		if identifier contains "AirPods Pro 2023 May" then
			exit repeat
		end if
		set i to i + 1
	end repeat
	tell its window "Control Center" to click checkbox i of scroll area 1 of group 1
end tell
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

local function turnOffMeeting()
  logger.d('turnOffMeeting')
  clickShortcutsItem("Stop Meeting")
end

hs.hotkey.bind(hyper, "m", turnOnMeeting)
hs.hotkey.bind(hyper, "n", turnOffMeeting)
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
