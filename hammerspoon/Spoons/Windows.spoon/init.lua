--- === Windows ===
---
--- Control the Windows, [instructions](TODO).
--- Inspired by https://gist.github.com/kizzx2/e542fa74b80b7563045a
---
--- Download: TODO
local obj = {}
obj.__index = obj
obj.name = "Windows"
obj.version = "0.0.1"
obj.author = "xcv58 <hammerspoon_windows@xcv58.com>"
obj.homepage = "https://github.com/xcv58/Hammerspoon-xcv58"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- Windows.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new("Windows")
local logger = obj.logger

local function get_window_under_mouse()
  -- Invoke `hs.application` because `hs.window.orderedWindows()` doesn't do it and breaks itself
  local _ = hs.application

  local my_pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
  local my_screen = hs.mouse.getCurrentScreen()

  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return my_screen == w:screen() and my_pos:inside(w:frame())
  end)
end

local dragging_win = nil
local dragging_mode = 1

local drag_event = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function(e)
  if dragging_win then
    local dx = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
    local dy = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)
    local mods = hs.eventtap.checkKeyboardModifiers()

    -- Ctrl + Alt to move the window under cursor
    if dragging_mode == 1 and mods.ctrl and mods.alt then
      -- Alt + Shift to resize the window under cursor
      dragging_win:move({dx, dy}, nil, false, 0)
    elseif mods.alt and mods.shift then
      local sz = dragging_win:size()
      local w1 = sz.w + dx
      local h1 = sz.h + dy
      dragging_win:setSize(w1, h1)
    end
  end
  return nil
end)

local flags_event = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
  local flags = e:getFlags()
  if flags.ctrl and flags.alt and dragging_win == nil then
    dragging_win = get_window_under_mouse()
    dragging_mode = 1
    drag_event:start()
  elseif flags.alt and flags.shift and dragging_win == nil then
    dragging_win = get_window_under_mouse()
    dragging_mode = 2
    drag_event:start()
  else
    drag_event:stop()
    dragging_win = nil
  end
  return nil
end)

--- Windows:init()
--- Method
--- init.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The Windows object
function obj:init()
  self.logger.e("init")
  self._init_done = true
  flags_event:start()
  return self
end

return obj
