require "xcv58"
-----------------------------------------------
-- Set hyper to ctrl + shift
-----------------------------------------------
local hyper = {"ctrl", "shift"}
-- local hyper = {"shift", "cmd", "alt", "ctrl"}

-----------------------------------------------
-- Reload config on write
-----------------------------------------------
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", hs.reload):start()
hs.alert.show("Config loaded")

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
-- hyper f for fullscreen, c for center
-----------------------------------------------
hs.hotkey.bind(hyper, "f", fullscreen)
hs.hotkey.bind({"cmd", "ctrl"}, "f", fullscreen)
hs.hotkey.bind(hyper, "c", center)

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

-----------------------------------------------
-- Hyper wsad to switch window focus
-----------------------------------------------
hs.hotkey.bind(hyper, 'w', function() hs.window.focusedWindow():focusWindowNorth() end)
hs.hotkey.bind(hyper, 's', function() hs.window.focusedWindow():focusWindowSouth() end)
hs.hotkey.bind(hyper, 'a', function() hs.window.focusedWindow():focusWindowWest() end)
hs.hotkey.bind(hyper, 'd', function() hs.window.focusedWindow():focusWindowEast() end)
