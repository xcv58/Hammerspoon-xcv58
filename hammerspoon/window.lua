-----------------------------------------------
-- Set hyper to ctrl + shift
-----------------------------------------------
local hyper = {"cmd", "ctrl", "shift"}

function tolerance(a, b) return math.abs(a - b) < 32 end

local STEP = 10

function resizeWindow(f)
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    frame.x = frame.x + (f.x or 0)
    frame.y = frame.y + (f.y or 0)
    frame.w = frame.w + (f.w or 0)
    frame.h = frame.h + (f.h or 0)
    win:setFrame(frame)
  end

function resizeWindowWider()
    resizeWindow({x = -STEP, w = 2 * STEP})
end

function resizeWindowTaller()
    resizeWindow({y = -STEP, h = 2 * STEP})
end

function resizeWindowShorter()
    resizeWindow({x = STEP, w = -2 * STEP})
end

function resizeWindowThinner()
    resizeWindow({y = STEP, h = -2 * STEP})
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

ischatmode = false
function chatmode()
    ischatmode = not ischatmode
    if ischatmode then
        hs.alert.show('enable chat mode')
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
        hs.alert.show('disable chat mode')
    end
end

-----------------------------------------------
-- hyper h, j, k, l for left, down, up, right half window
-----------------------------------------------
hs.hotkey.bind(hyper, "l", function() resize(1, 0, 2, 1) end)
hs.hotkey.bind(hyper, "h", function() resize(0, 0, 2, 1) end)
hs.hotkey.bind(hyper, "j", function() resize(0, 1, 1, 2) end)
hs.hotkey.bind(hyper, "k", function() resize(0, 0, 1, 2) end)
hs.hotkey.bind(hyper, "m", function() resize(0, 0, 1, 1) end)

-----------------------------------------------
-- hyper g, ; for horizontal, vertical fold window
-----------------------------------------------
local lx = 2
local lw = 3
hs.hotkey.bind(hyper, ";", function()
    resize(lx, 0, lw, 1)
    lx = (lx + 1) % lw
end)

local hy = 0
local hh = 3
hs.hotkey.bind(hyper, "g", function()
    resize(0, hy, 1, hh)
    hy = (hy + 1) % hh
end)

-----------------------------------------------
-- hyper p, n for move between monitors
-----------------------------------------------
hs.hotkey.bind(hyper, "p", function() hs.window.focusedWindow():moveOneScreenEast(0) end)
hs.hotkey.bind(hyper, "n", function() hs.window.focusedWindow():moveOneScreenWest(0) end)

-----------------------------------------------
-- hyper 1, 2 for diagonal quarter window
-----------------------------------------------
hs.hotkey.bind(hyper, "1", function() resize(0, 0, 2, 2) end)
hs.hotkey.bind(hyper, "2", function() resize(1, 0, 2, 2) end)

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
-- hyper f for fullscreen, c for center
-----------------------------------------------
hs.hotkey.bind(hyper, "c", center)
hs.hotkey.bind(hyper, "f", fullscreen)

-----------------------------------------------
-- CMD+Ctrl+f for fullscreen
-----------------------------------------------
hs.hotkey.bind({"cmd", "ctrl"}, "f", fullscreen)
