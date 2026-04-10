-- Set hyper to Cmd + Ctrl + Shift
local hyper = {"cmd", "ctrl", "shift"}

local function tolerance(a, b) return math.abs(a - b) < 32 end

local STEP = 10
local ischatmode = false
local chatModeWidth = 0

local function windowAlert(msg)
    hs.alert.closeAll(0.1)
    hs.alert.show(msg, 0.42)
end

local function getFocusedWindow()
    local win = hs.window.focusedWindow()
    if not win then
        hs.alert.show("No focused window")
    end
    return win
end

local function getStepX()
    local win = getFocusedWindow()
    if not win then return 0 end
    local f = win:screen():frame()
    return f.w / STEP
end

local function getStepY()
    local win = getFocusedWindow()
    if not win then return 0 end
    local f = win:screen():frame()
    return f.h / STEP
end

local function resizeWindow(f)
    local win = getFocusedWindow()
    if not win then return end
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
    win:setFrame(newFrame, 0.1)
end

local function windowHeightMax()
    local win = getFocusedWindow()
    if not win then return end
    local f = win:screen():frame()
    local frame = win:frame()
    frame.y = 0
    frame.h = f.h
    win:setFrame(frame, 0.1)
end

local function windowWidthMax()
    local win = getFocusedWindow()
    if not win then return end
    local f = win:screen():frame()
    local frame = win:frame()
    frame.x = 0
    frame.w = f.w
    win:setFrame(frame, 0.1)
end

local function resizeWindowWider()
    local delta = getStepX()
    resizeWindow({x = delta / -2, w = delta})
end

local function resizeWindowTaller()
    local delta = getStepY()
    resizeWindow({y = delta / -2, h = delta})
end

local function resizeWindowShorter()
    local delta = getStepX()
    resizeWindow({x = delta / 2, w = -delta})
end

local function resizeWindowThinner()
    local delta = getStepY()
    resizeWindow({y = delta / 2, h = -delta})
end

local function moveWindowLeft() resizeWindow({x = -getStepX()}) end

local function moveWindowRight() resizeWindow({x = getStepX()}) end

local function moveWindowTop() resizeWindow({y = -getStepY()}) end

local function moveWindowBottom() resizeWindow({y = getStepY()}) end

local function resize(x, y, w, h)
    local win = getFocusedWindow()
    if not win then return end
    local f = win:frame()
    local max = win:screen():frame()
    local ww = max.w / w
    local hh = max.h / h
    local xx = max.x + (x * ww)
    local yy = max.y + (y * hh)

    if ischatmode and x == 0 then
        xx = xx + chatModeWidth
        ww = ww - chatModeWidth
    end

    if tolerance(f.x, xx) and tolerance(f.y, yy) and tolerance(f.w, ww) and
        tolerance(f.h, hh) then
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
    return win:setFrame(f, 0.1)
end

local function fullscreen()
    local win = getFocusedWindow()
    if not win then return end
    local f = win:frame()
    local max = win:screen():frame()
    if ischatmode then
        f.x = max.x + chatModeWidth
        f.w = max.w - chatModeWidth
    else
        f.x = max.x
        f.w = max.w
    end
    f.y = max.y
    f.h = max.h
    win:setFrame(f, 0.1)
    windowAlert("Fullscreen")
end

local function center()
    local win = getFocusedWindow()
    if not win then return end
    local f = win:frame()
    local max = win:screen():frame()
    f.x = (max.w - max.x - f.w) / 2
    f.y = (max.h - max.y - f.h) / 2
    win:setFrame(f, 0.1)
    windowAlert("Center")
end

local magicRatio = 0.618
local function golden()
    local win = getFocusedWindow()
    if not win then return end
    local f = win:frame()
    local max = win:screen():frame()
    f.w = max.w * magicRatio
    f.h = max.h * magicRatio
    f.x = (max.w - max.x - f.w) / 2
    f.y = (max.h - max.y - f.h) / 2
    win:setFrame(f, 0.1)
    windowAlert("Golden")
end

local function chatmode()
    ischatmode = not ischatmode
    if ischatmode then
        hs.alert.show("enable chat mode")
        local win = getFocusedWindow()
        if not win then return end
        local f = win:frame()
        local max = win:screen():frame()
        chatModeWidth = max.w * 0.18
        f.x = max.x
        f.y = max.y
        f.w = chatModeWidth
        f.h = max.h
        win:setFrame(f, 0.1)
    else
        hs.alert.show("disable chat mode")
    end
end

-----------------------------------------------
-- hyper h, j, k, l for left, down, up, right half window
-----------------------------------------------
local function leftHalf() resize(0, 0, 2, 1) windowAlert("Left Half") end
local function bottomHalf() resize(0, 1, 1, 2) windowAlert("Bottom Half") end
local function topHalf() resize(0, 0, 1, 2) windowAlert("Top Half") end
local function rightHalf() resize(1, 0, 2, 1) windowAlert("Right Half") end
hs.hotkey.bind(hyper, "h", leftHalf)
hs.hotkey.bind(hyper, "j", bottomHalf)
hs.hotkey.bind(hyper, "k", topHalf)
hs.hotkey.bind(hyper, "l", rightHalf)
hs.hotkey.bind(hyper, "m", function() resize(0, 0, 1, 1) windowAlert("Max") end)

-- hyper ; for vertical fold window
local lx = 2
local lw = 3
hs.hotkey.bind(hyper, ";", function()
    resize(lx, 0, lw, 1)
    lx = (lx + 1) % lw
    windowAlert("Thirds")
end)

-- hyper g for golden window
hs.hotkey.bind(hyper, "g", golden)

-----------------------------------------------
-- hyper 1, 2 for diagonal quarter window
-----------------------------------------------
local function topLeftCorner() resize(0, 0, 2, 2) end
local function topRightCorner() resize(1, 0, 2, 2) end
hs.hotkey.bind(hyper, "1", topLeftCorner, nil, topLeftCorner)
hs.hotkey.bind(hyper, "2", topRightCorner, nil, topRightCorner)

-----------------------------------------------
-- Hyper i to show window hints
-----------------------------------------------
hs.hotkey.bind(hyper, "i", function() hs.hints.windowHints() end)

hs.hotkey.bind(hyper, "q", function() chatmode() end)

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
hs.hotkey.bind({"cmd", "ctrl"}, "f", fullscreen)

-- Set hotkey modal
local function getIndicator()
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
        fillColor = {alpha = 0.8, black = 1},
        type = "rectangle"
    }, {
        action = "fill",
        type = "text",
        textColor = {red = 1},
        textSize = 64,
        textAlignment = "center",
        text = "Escape to exit"
    })
end
local indicator = nil

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

winHotkeyModal:bind("", "escape", function() winHotkeyModal:exit() end)

winHotkeyModal:bind("", "1", "", topLeftCorner, nil, topLeftCorner)
winHotkeyModal:bind("", "2", "", topRightCorner, nil, topRightCorner)

winHotkeyModal:bind("", "h", "", moveWindowLeft, nil, moveWindowLeft)
winHotkeyModal:bind("", "j", "", moveWindowBottom, nil, moveWindowBottom)
winHotkeyModal:bind("", "k", "", moveWindowTop, nil, moveWindowTop)
winHotkeyModal:bind("", "l", "", moveWindowRight, nil, moveWindowRight)

winHotkeyModal:bind("ctrl", "h", "", resizeWindowShorter, nil,
                    resizeWindowShorter)
winHotkeyModal:bind("ctrl", "j", "", resizeWindowThinner, nil,
                    resizeWindowThinner)
winHotkeyModal:bind("ctrl", "k", "", resizeWindowTaller, nil, resizeWindowTaller)
winHotkeyModal:bind("ctrl", "l", "", resizeWindowWider, nil, resizeWindowWider)

winHotkeyModal:bind("shift", "h", "", resizeWindowShorter, nil,
                    resizeWindowShorter)
winHotkeyModal:bind("shift", "j", "", resizeWindowThinner, nil,
                    resizeWindowThinner)
winHotkeyModal:bind("shift", "k", "", windowHeightMax)
winHotkeyModal:bind("shift", "l", "", windowWidthMax)

winHotkeyModal:bind("", "c", "", center)
winHotkeyModal:bind("", "f", "", fullscreen)

winHotkeyModal:bind("", "w", "", resizeWindowTaller, nil, resizeWindowTaller)
winHotkeyModal:bind("", "a", "", resizeWindowShorter, nil, resizeWindowShorter)
winHotkeyModal:bind("", "s", "", resizeWindowThinner, nil, resizeWindowThinner)
winHotkeyModal:bind("", "d", "", resizeWindowWider, nil, resizeWindowWider)

winHotkeyModal:bind("", "g", "", golden)

-----------------------------------------------
-- Cmd+Alt+Ctrl r to resize focused window to 1440x900 and center it
-----------------------------------------------
hs.hotkey.bind(hyper, "R", function()
    local win = getFocusedWindow()
    if not win then return end
    local f = win:frame()
    f.w = 1440
    f.h = 900
    local screen = win:screen()
    local max = screen:frame()
    f.x = max.x + (max.w / 2) - (f.w / 2)
    f.y = max.y + (max.h / 2) - (f.h / 2)
    win:setFrame(f, 0)
    windowAlert("1440x900")
end)
