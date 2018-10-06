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

canvas = nil
fadeTime = 0.5
timeTimer = nil

local function updateTime(x)
    x.text = os.date("%I:%M:%S")
end

local function resetTimer()
    if timeTimer then
        timeTimer:stop()
        timeTimer = nil
    end
end

hs.hotkey.bind(hyper, "t", function()
    local builtInScreen = hs.screen'Color LCD'
    local cres = builtInScreen:fullFrame()
    if canvas then
        canvas:delete(fadeTime)
        canvas = nil
        resetTimer()
        return
    end

    local textSize = math.min(cres.w, cres.h) / 3.5
    textSize = math.max(textSize, 36)
    local width = 5 * textSize
    local height = 1.3 * textSize

    canvas = hs.canvas.new({
        x = (cres.w - width) / 2,
        y = (cres.h - height) / 2,
        h = height,
        w = width,
    }):show(fadeTime)
    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    canvas:level(hs.canvas.windowLevels.desktopIcon)

    canvas[1] = {
        id = "rectangle",
        type = "rectangle",
        fillColor = {hex="#000", alpha=0.61},
        action = "fill",
    }
    canvas[2] = {
        id = "text",
        type = "text",
        textSize = textSize,
        textAlignment = "center",
        textFont = "Courier",
        textLineBreak = "charWrap",
    }
    local text = canvas[2]

    updateTime(text)
    if timeTimer then
        timeTimer:start()
    else
        timeTimer = hs.timer.doEvery(1, function() updateTime(text) end)
    end
end)
