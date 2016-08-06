local hyper = {"cmd", "ctrl"}

-- hs.hotkey.bind(hyper, "l", function()
--     hs.caffeinate.systemSleep()
-- end)

function setVolume(n)
    output = hs.audiodevice.defaultOutputDevice()

    if output:muted() then
        setMuted(false)
    end

    volume = output:outputVolume()
    newVolume = volume + n

    output:setVolume(newVolume)

    hs.alert.show("Volume: " .. math.floor(output:outputVolume()))
end

function setMuted(mute)
    output = hs.audiodevice.defaultOutputDevice()
    output:setMuted(mute)
    if mute then
        hs.alert.show("Mute")
    else
        hs.alert.show("Not Mute")
    end
end

hs.hotkey.bind(hyper, "k", function()
    setVolume(1)
end)

hs.hotkey.bind(hyper, "j", function()
    setVolume(-1)
end)

hs.hotkey.bind(hyper, "h", function()
    setMuted(true)
end)

hs.hotkey.bind(hyper, "g", function()
    setMuted(false)
end)
