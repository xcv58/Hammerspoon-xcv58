local hyper = {"cmd", "ctrl"}

local INCREASE_VOLUME, DECREASE_VOLUME = 1, -1
local lastTime = -1
local lastDirection = 0
local gap = 1

-- hs.hotkey.bind(hyper, "l", function()
--     hs.caffeinate.systemSleep()
-- end)

function isRecentChange (args)
    local time = hs.timer.localTime()
    local res = time - lastTime < 8
    lastTime = time
    return res
end

function isSameDirection (direction)
    local res = lastDirection == direction
    lastDirection = direction
    return res
end

function increaseGap ()
    gap = math.min(gap + 1, 5)
end

function resetGap ()
    gap = 1
end

function changeVolume (direction)
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
    output = hs.audiodevice.defaultOutputDevice()

    if output:muted() then
        setMuted(false)
    end

    volume = output:outputVolume()
    newVolume = volume + n

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

function increaseVolume()
    changeVolume(INCREASE_VOLUME)
end

function decreaseVolume()
    changeVolume(DECREASE_VOLUME)
end

hs.hotkey.bind(hyper, "k", increaseVolume, nil, increaseVolume
)

hs.hotkey.bind(hyper, "j", decreaseVolume, nil, decreaseVolume)

hs.hotkey.bind(hyper, "h", function()
    setMuted(true)
end)

hs.hotkey.bind(hyper, "g", function()
    setMuted(false)
end)

hs.hotkey.bind(hyper, "l", function()
    hs.caffeinate.startScreensaver()
end)


local timer = nil
function showTime (args)
    hs.alert.show("test", hs.alert.defaultStype, hs.screen.mainScreen(), 1)
end

mouseCircle = nil
mouseCircleTimer = nil


hs.hotkey.bind(hyper, "y", function()
    -- hs.dialog.alert("rest")
    -- if timer then
    --     timer:stop()
    --     timer = nil
    -- else
    --     timer = hs.timer.doEvery(2, showTime)
    -- end
    -- Delete an existing highlight if it exists
    if mouseCircle then
        mouseCircle:delete()
        if mouseCircleTimer then
            mouseCircleTimer:stop()
        end
    end
    -- Get the current co-ordinates of the mouse pointer
    mousepoint = hs.mouse.getAbsolutePosition()
    -- Prepare a big red circle around the mouse pointer
    -- mouseCircle = hs.drawing.circle(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80))
    mouseCircle = hs.drawing.text(hs.geometry.rect(mousepoint.x-40, mousepoint.y-40, 80, 80), "test")
    -- mouseCircle:setStrokeColor({["red"]=1,["blue"]=0,["green"]=0,["alpha"]=1})
    -- mouseCircle:setFill(false)
    -- mouseCircle:setStrokeWidth(5)
    mouseCircle:show()

    -- Set a timer to delete the circle after 3 seconds
    mouseCircleTimer = hs.timer.doAfter(3, function() mouseCircle:delete() end)
end)
