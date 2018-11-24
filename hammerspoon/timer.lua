local hyper = {"cmd", "ctrl"}

local timer = nil

canvas = nil
fadeTime = 0.5
timeTimer = nil

local function updateTime(x)
    x.text = os.date("%I:%M:%S")
end

local function stopTimer()
    if timeTimer then
        timeTimer:stop()
        timeTimer = nil
    end
end

local function toggleTimer()
    local builtInScreen = hs.screen'Color LCD'
    local cres = builtInScreen:fullFrame()
    if canvas then
        canvas:delete(fadeTime)
        canvas = nil
        stopTimer()
        return
    end

    local textSize = math.min(cres.w, cres.h) / 3.5
    textSize = math.max(textSize, 36)
    local width = 5 * textSize
    local height = 1.3 * textSize

    canvas = hs.canvas.new({
        x = cres.x + (cres.w - width) / 2,
        y = cres.y + (cres.h - height) / 2,
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
        roundedRectRadii = {xRadius = 8, yRadius = 8},
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
end

hs.hotkey.bind(hyper, "t", toggleTimer)
toggleTimer()
