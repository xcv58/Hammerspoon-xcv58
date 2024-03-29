local hyper = {"cmd", "ctrl"}

local timer = nil

local canvas = nil
local fadeTime = 0.5
local timeTimer = nil

local loaded = nil

local screenIndex = 0

local logger = hs.logger.new('Timer')

local function timerHandler()
    if timeTimer then
        stopTimer()
        startTimer()
    end
end

local function updateTime(x) x.text = os.date("%H:%M:%S") end

function stopTimer()
    if canvas then
        canvas:delete(fadeTime)
        canvas = nil
    end
    if timeTimer then
        timeTimer:stop()
        timeTimer = nil
    end
end

local function getScreen()
    local allScreens = hs.screen.allScreens()
    screenIndex = screenIndex + 1
    local screen = allScreens[screenIndex]
    logger.d("screenIndex: " .. tostring(screenIndex))
    if not screen then
        logger.d("reset screenIndex")
        screenIndex = 1
        return allScreens[screenIndex]
    end
    return screen
end

function startTimer()
    local screen = getScreen()
    if not screen then return end
    local cres = screen:fullFrame()
    local width = math.min(cres.w, cres.h) * 0.89
    local textSize = width / 5
    local height = 1.3 * textSize

    canvas = hs.canvas.new({
        x = cres.x + (cres.w - width) / 2,
        y = cres.y + (cres.h - height) / 2,
        h = height,
        w = width
    }):show(fadeTime)
    canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
    canvas:level(hs.canvas.windowLevels.desktopIcon)

    canvas[1] = {
        id = "rectangle",
        type = "rectangle",
        fillColor = {hex = "#000", alpha = 0.61},
        action = "fill",
        roundedRectRadii = {xRadius = 8, yRadius = 8}
    }
    canvas[2] = {
        id = "text",
        type = "text",
        textSize = textSize,
        textAlignment = "center",
        textFont = "Courier",
        textLineBreak = "charWrap"
    }
    local text = canvas[2]

    updateTime(text)
    if timeTimer then
        timeTimer:start()
    else
        timeTimer = hs.timer.doEvery(1, function() updateTime(text) end)
    end

    if not loaded then
        loaded = hs.screen.watcher.new(timerHandler):start()
        hs.caffeinate.watcher.new(timerHandler):start()
    end
end

function toggleTimer()
    if canvas then
        canvas:delete(fadeTime)
        canvas = nil
        stopTimer()
    else
        startTimer()
    end
end

hs.hotkey.bind(hyper, "t", toggleTimer)

startTimer()
