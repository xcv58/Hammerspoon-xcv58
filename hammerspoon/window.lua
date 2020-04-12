-- Set hyper to ⌘ + ⌃ + ⇧
local hyper = {"⌘", "⌃", "⇧"}

function tolerance(a, b) return math.abs(a - b) < 32 end

local STEP = 10

function getStepX()
    local win = hs.window.focusedWindow()
    local f = win:screen():frame()
    return f.w / STEP
end

function getStepY()
    local win = hs.window.focusedWindow()
    local f = win:screen():frame()
    return f.h / STEP
end

function resizeWindow(f)
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local newFrame = {
      x = frame.x + (f.x or 0),
      y = frame.y + (f.y or 0),
      w = frame.w + (f.w or 0),
      h = frame.h + (f.h or 0)
    }
    if newFrame.w <= 0 then
      newFrame.w = 0
      newFrame.x = frame.x
    end
    if newFrame.h <= 0 then
      newFrame.h = 0
      newFrame.y = frame.y
    end
    win:setFrame(newFrame)
end

function windowHeightMax()
    local win = hs.window.focusedWindow()
    local f = win:screen():frame()
    local frame = win:frame()
    frame.y = 0
    frame.h = f.h
    win:setFrame(frame)
end

function windowWidthMax()
    local win = hs.window.focusedWindow()
    local f = win:screen():frame()
    local frame = win:frame()
    frame.x = 0
    frame.w = f.w
    win:setFrame(frame)
end

function resizeWindowWider()
    local delta = getStepX()
    resizeWindow({x = delta / -2, w = delta})
end

function resizeWindowTaller()
    local delta = getStepY()
    resizeWindow({y = delta / -2, h = delta})
end

function resizeWindowShorter()
    local delta = getStepX()
    resizeWindow({x = delta / 2, w = -delta})
end

function resizeWindowThinner()
    local delta = getStepY()
    resizeWindow({y = delta / 2, h = -delta})
end

function moveWindowLeft()
  resizeWindow({x = -getStepX()})
end

function moveWindowRight()
  resizeWindow({x = getStepX()})
end

function moveWindowTop()
  resizeWindow({y = -getStepY()})
end

function moveWindowBottom()
  resizeWindow({y = getStepY()})
end

-- TODO: Add comments
function resize(x, y, w, h)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local max = win:screen():frame()
    local ww = max.w / w
    local hh = max.h / h
    local xx = max.x + (x * ww)
    local yy = max.y + (y * hh)

    if ischatmode and x == 0 then
        xx = xx + CHAT_MODE_WIDTH
        ww = ww - CHAT_MODE_WIDTH
    end

    if tolerance(f.x, xx) and tolerance(f.y, yy) and tolerance(f.w, ww) and tolerance(f.h, hh) then
        if w > h then
            x = (x + 1) % w
        elseif h > w then
            y = (y + 1) % h
        else
            x = (x == 0) and 0.9999 or 0
            y = (y == 0) and 0.9999 or 0
        end
        return resize(x, y, w, h)
    end
    f.x = xx
    f.y = yy
    f.w = ww
    f.h = hh
    return win:setFrame(f)
end

function fullscreen()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local max = win:screen():frame()
    if ischatmode then
        f.x = max.x + CHAT_MODE_WIDTH
        f.w = max.w - CHAT_MODE_WIDTH
    else
        f.x = max.x
        f.w = max.w
    end
    f.y = max.y
    f.h = max.h
    win:setFrame(f)
end

function center()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local max = win:screen():frame()
    f.x = (max.w - max.x - f.w) / 2
    f.y = (max.h - max.y - f.h) / 2
    win:setFrame(f)
end

local magicRatio = 0.618
function golden()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local max = win:screen():frame()
    f.w = max.w * magicRatio
    f.h = max.h * magicRatio
    f.x = (max.w - max.x - f.w) / 2
    f.y = (max.h - max.y - f.h) / 2
    win:setFrame(f)
end

ischatmode = false
function chatmode()
    ischatmode = not ischatmode
    if ischatmode then
        hs.alert.show("enable chat mode")
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local max = win:screen():frame()
        CHAT_MODE_WIDTH = max.w * 0.18
        f.x = max.x
        f.y = max.y
        f.w = CHAT_MODE_WIDTH
        f.h = max.h
        win:setFrame(f)
    else
        hs.alert.show("disable chat mode")
    end
end

-----------------------------------------------
-- hyper h, j, k, l for left, down, up, right half window
-----------------------------------------------
function leftHalf() resize(0, 0, 2, 1) end
function bottomHalf() resize(0, 1, 1, 2) end
function topHalf() resize(0, 0, 1, 2) end
function rightHalf() resize(1, 0, 2, 1) end
hs.hotkey.bind(hyper, "h", leftHalf)
hs.hotkey.bind(hyper, "j", bottomHalf)
hs.hotkey.bind(hyper, "k", topHalf)
hs.hotkey.bind(hyper, "l", rightHalf)
hs.hotkey.bind(hyper, "m", function() resize(0, 0, 1, 1) end)

-- hyper ; for vertical fold window
local lx = 2
local lw = 3
hs.hotkey.bind(hyper, ";", function()
    resize(lx, 0, lw, 1)
    lx = (lx + 1) % lw
end)

-- hyper g for golden window
hs.hotkey.bind(hyper, "g", golden)

-----------------------------------------------
-- hyper p, n for move between monitors
-----------------------------------------------
hs.hotkey.bind(hyper, "p", function() hs.window.focusedWindow():moveOneScreenEast(0) end)
hs.hotkey.bind(hyper, "n", function() hs.window.focusedWindow():moveOneScreenWest(0) end)

-----------------------------------------------
-- hyper 1, 2 for diagonal quarter window
-----------------------------------------------
function topLeftCorner() resize(0, 0, 2, 2) end
function topRightCorner() resize(1, 0, 2, 2) end
hs.hotkey.bind(hyper, "1", topLeftCorner, nil, topLeftCorner)
hs.hotkey.bind(hyper, "2", topRightCorner, nil, topRightCorner)

-----------------------------------------------
-- Hyper i to show window hints
-----------------------------------------------
hs.hotkey.bind(hyper, "i", function() hs.hints.windowHints() end)


hs.hotkey.bind(hyper, "q", function() chatmode() end)

-- -----------------------------------------------
-- -- Hyper wsad to set window size
-- -----------------------------------------------
hs.hotkey.bind(hyper, "w", resizeWindowTaller, nil, resizeWindowTaller)
hs.hotkey.bind(hyper, "a", resizeWindowShorter, nil, resizeWindowShorter)
hs.hotkey.bind(hyper, "s", resizeWindowThinner, nil, resizeWindowThinner)
hs.hotkey.bind(hyper, "d", resizeWindowWider, nil, resizeWindowWider)

-----------------------------------------------
-- hyper f for fullscreen, x to center x axis
-----------------------------------------------
hs.hotkey.bind(hyper, "x", center)
hs.hotkey.bind(hyper, "f", fullscreen)

-----------------------------------------------
-- CMD+Ctrl+f for fullscreen
-----------------------------------------------
hs.hotkey.bind({"⌘", "⌃"}, "f", fullscreen)

-- Set hotkey modal
function getIndicator()
  local frame = hs.screen.mainScreen():fullFrame()
  local width = 600
  local height = 90
  local f = {
    x = frame.x + frame.w / 2 - width / 2,
    y = frame.y + height * 2,
    w = width,
    h = height
  }
  return hs.canvas.new(f):appendElements({
    action = "fill",
    fillColor = { alpha = 0.8, black = 1 },
    type = "rectangle",
  }, {
    action = "fill",
    type = "text",
    textColor = { red = 1 },
    textSize = 64,
    textAlignment = "center",
    text = "Escape to exit"
  })
end
local inidcator = nil

local winHotkeyModal = hs.hotkey.modal.new(hyper, "o")
function winHotkeyModal:entered()
  hs.alert.closeAll()
  hs.alert.show("Open window hotkey modal")
  indicator = getIndicator():show(1)
end

function winHotkeyModal:exited()
  hs.alert.closeAll()
  hs.alert.show("Exit window hotkey modal")
  indicator:delete(0.2)
  indicator = nil
end

winHotkeyModal:bind("", "escape", function()
  winHotkeyModal:exit()
end)

winHotkeyModal:bind("", "1", "", topLeftCorner, nil, topLeftCorner)
winHotkeyModal:bind("", "2", "", topRightCorner, nil, topRightCorner)

winHotkeyModal:bind("", "h", "", moveWindowLeft, nil, moveWindowLeft)
winHotkeyModal:bind("", "j", "", moveWindowBottom, nil, moveWindowBottom)
winHotkeyModal:bind("", "k", "", moveWindowTop, nil, moveWindowTop)
winHotkeyModal:bind("", "l", "", moveWindowRight, nil, moveWindowRight)

winHotkeyModal:bind("⌃", "h", "", resizeWindowShorter, nil, resizeWindowShorter)
winHotkeyModal:bind("⌃", "j", "", resizeWindowThinner, nil, resizeWindowThinner)
winHotkeyModal:bind("⌃", "k", "", resizeWindowTaller, nil, resizeWindowTaller)
winHotkeyModal:bind("⌃", "l", "", resizeWindowWider, nil, resizeWindowWider)

winHotkeyModal:bind("⇧", "h", "", resizeWindowShorter, nil, resizeWindowShorter)
winHotkeyModal:bind("⇧", "j", "", resizeWindowThinner, nil, resizeWindowThinner)
winHotkeyModal:bind("⇧", "k", "", windowHeightMax)
winHotkeyModal:bind("⇧", "l", "", windowWidthMax)

winHotkeyModal:bind("", "c", "", center)
winHotkeyModal:bind("", "f", "", fullscreen)

winHotkeyModal:bind("", "w", "", resizeWindowTaller, nil, resizeWindowTaller)
winHotkeyModal:bind("", "a", "", resizeWindowShorter, nil, resizeWindowShorter)
winHotkeyModal:bind("", "s", "", resizeWindowThinner, nil, resizeWindowThinner)
winHotkeyModal:bind("", "d", "", resizeWindowWider, nil, resizeWindowWider)

winHotkeyModal:bind("", "g", "", golden)
