local hyper = {"cmd", "ctrl"}

local INCREASE_VOLUME, DECREASE_VOLUME = 1, -1
local lastTime = -1
local lastDirection = 0
local gap = 1

-- hs.hotkey.bind(hyper, "l", function()
--     hs.caffeinate.systemSleep()
-- end)

function isRecentChange(args)
    local time = hs.timer.localTime()
    local res = time - lastTime < 8
    lastTime = time
    return res
end

function isSameDirection(direction)
    local res = lastDirection == direction
    lastDirection = direction
    return res
end

function increaseGap() gap = math.min(gap + 1, 5) end

function resetGap() gap = 1 end

function changeVolume(direction)
    local recentChange = isRecentChange()
    local sameDirection = isSameDirection(direction)
    if recentChange and sameDirection then
        increaseGap()
    else
        resetGap()
    end
    setVolume(direction * gap)
end

function setVolume(n)
    local output = hs.audiodevice.defaultOutputDevice()

    if output:muted() then setMuted(false) end

    local volume = output:outputVolume()
    local newVolume = volume + n

    output:setVolume(newVolume)

    hs.alert.closeAll(0.2)
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

function increaseVolume() changeVolume(INCREASE_VOLUME) end

function decreaseVolume() changeVolume(DECREASE_VOLUME) end

hs.hotkey.bind(hyper, "k", increaseVolume, nil, increaseVolume)

hs.hotkey.bind(hyper, "j", decreaseVolume, nil, decreaseVolume)

hs.hotkey.bind(hyper, "h", function() setMuted(true) end)

hs.hotkey.bind(hyper, "g", function() setMuted(false) end)

hs.hotkey.bind(hyper, "l", function()
    hs.alert.show("Sleep...")
    local timer = hs.timer.delayed.new(0.5, function()
        hs.caffeinate.systemSleep()
    end)
    timer:start()
end)
