local hyper = {"cmd", "ctrl"}

-- hs.hotkey.bind(hyper, "l", function()
--     hs.caffeinate.systemSleep()
-- end)

function setVolume(n)
    output = hs.audiodevice.defaultOutputDevice()

    volume = output:outputVolume()
    newVolume = volume + n

    output:setVolume(newVolume)

    hs.alert.show("Volume: " .. math.floor(output:outputVolume()))
end

hs.hotkey.bind(hyper, "k", function()
    setVolume(1)
end)

hs.hotkey.bind(hyper, "j", function()
    setVolume(-1)
end)
