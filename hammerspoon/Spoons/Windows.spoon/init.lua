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

local function getWindowUnderMouse()
  -- Invoke `hs.application` because `hs.window.orderedWindows()` doesn't do it and breaks itself
  local _ = hs.application

  local mousePosition = hs.geometry.new(hs.mouse.absolutePosition())

  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return mousePosition:inside(w:frame())
  end)
end

local dragging_win = nil
local dragging_mode = 1
local drag_event

local function isDraggingWithCurrentModifiers(mods)
  if dragging_mode == 1 then
    return mods.ctrl and mods.alt
  end
  return mods.alt and mods.shift
end

local function stopDragging()
  drag_event:stop()
  dragging_win = nil
end

local function startDragging(mode)
  dragging_win = getWindowUnderMouse()
  if not dragging_win then return end

  dragging_mode = mode
  drag_event:start()
end

drag_event = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function(e)
  if not dragging_win then return nil end

  local mods = hs.eventtap.checkKeyboardModifiers()
  if not isDraggingWithCurrentModifiers(mods) then
    stopDragging()
    return nil
  end

  local dx = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
  local dy = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)
  if dx == 0 and dy == 0 then return nil end

  if dragging_mode == 1 then
    dragging_win:move({dx, dy}, nil, false, 0)
  else
    local size = dragging_win:size()
    dragging_win:setSize(size.w + dx, size.h + dy)
  end
  return nil
end)

local flags_event = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(e)
  local flags = e:getFlags()
  if dragging_win then
    if not isDraggingWithCurrentModifiers(flags) then stopDragging() end
    return nil
  end

  if flags.ctrl and flags.alt then
    startDragging(1)
  elseif flags.alt and flags.shift then
    startDragging(2)
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
  self.logger.d("init")
  self._init_done = true
  flags_event:start()
  return self
end

return obj
