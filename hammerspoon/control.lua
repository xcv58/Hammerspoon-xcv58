local hyper = {"cmd", "ctrl"}

hs.hotkey.bind(hyper, "l", function()
    hs.caffeinate.systemSleep()
end)
