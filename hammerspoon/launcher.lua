local logger = hs.logger.new('Launcher')

local hyper = {"cmd", "shift"}

local browsers = {
    {
        "com.google.Chrome", "Safari", "Firefox"
    }
}
local editorAndIDEs = {
    {
	    "Antigravity", "com.microsoft.VSCode", "Cursor", "org.vim.MacVim", "Xcode"
    }
}
local chromeApps = {{
    "Gmail",
    "Google Calendar",
	"Gemini"
}}
local chats = {{"Telegram", "Slack", "Messages"}}
local tweets = {{"Tweetbot"}}
local terminals = {{"iTerm2", "iTerm.app"}}
local reminders = {{"Reminders", "Quip"}}
local debuggers = {{"com.postmanlabs.mac"}}

-- Collect all app names for the watcher to track
local allAppGroups = {browsers, editorAndIDEs, chromeApps, chats, tweets, terminals, reminders, debuggers}

-- Cache of running applications by name/bundleID
local runningAppsCache = {}

-- Map to track which cache keys are associated with a specific app name
-- Format: appName -> {key1 = true, key2 = true}
local appKeysByName = {}

-- Build a set of all app identifiers we care about for quick lookup
local trackedApps = {}
for _, group in ipairs(allAppGroups) do
    local appNames = group[1]
    if appNames then
        for _, appName in ipairs(appNames) do
            trackedApps[appName] = true
        end
    end
end

-- Helper function to check if an app matches any of our tracked identifiers
-- Returns all matching keys (both name and bundleID if applicable)
local function getTrackedAppKeys(app)
    if not app then return {} end
    
    local keys = {}
    local name = app:name()
    local bundleID = app:bundleID()
    
    -- Check if name is tracked
    if name and trackedApps[name] then
        table.insert(keys, name)
    end
    -- Check if bundleID is tracked
    if bundleID and trackedApps[bundleID] then
        table.insert(keys, bundleID)
    end
    
    return keys
end

-- Add app to cache with all its identifiers
local function addAppToCache(app)
    if not app then return end
    
    local name = app:name()
    local bundleID = app:bundleID()
    local addedKeys = {}
    
    -- Cache by name if it's in our tracked list
    if name and trackedApps[name] then
        runningAppsCache[name] = app
        addedKeys[name] = true
        -- logger.d("Cached app by name: " .. name)
    end
    
    -- Also cache by bundleID if it's in our tracked list
    if bundleID and trackedApps[bundleID] then
        runningAppsCache[bundleID] = app
        addedKeys[bundleID] = true
        -- logger.d("Cached app by bundleID: " .. bundleID)
    end
    
    -- Update reverse mapping
    if name then
        appKeysByName[name] = addedKeys
    end
end

-- Remove app from cache
local function removeAppFromCache(app, appName)
    local name = appName
    if not name and app then
        name = app:name()
    end
    
    -- If we found a name, remove all keys associated with it
    if name and appKeysByName[name] then
        for key, _ in pairs(appKeysByName[name]) do
            runningAppsCache[key] = nil
        end
        appKeysByName[name] = nil
    end
    
    -- Fallback: try to remove by app object properties if name lookup failed
    if app then
        local bID = app:bundleID()
        if bID then runningAppsCache[bID] = nil end
        
        local n = app:name()
        if n then runningAppsCache[n] = nil end
    end
end

-- Initialize the cache with currently running apps
local function initializeCache()
    runningAppsCache = {}
    appKeysByName = {}
    local runningApps = hs.application.runningApplications()
    for _, app in ipairs(runningApps) do
        addAppToCache(app)
    end
end

-- Application watcher to keep cache updated
local appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if eventType == hs.application.watcher.launched then
        -- Delay slightly to ensure app object is fully initialized
        hs.timer.doAfter(0.5, function()
            local freshApp = hs.application.get(appName)
            if freshApp then
                addAppToCache(freshApp)
            elseif app then
                addAppToCache(app)
            end
        end)
    elseif eventType == hs.application.watcher.terminated then
        removeAppFromCache(app, appName)
    end
end)

-- Start the watcher and initialize cache
initializeCache()
appWatcher:start()

hs.hotkey.bind(hyper, "s", function() toggleApps(browsers) end)
hs.hotkey.bind(hyper, "a", function()
    -- logger.d("toggleAndOpenApps a")
    toggleAndOpenApps(chromeApps)
end)
hs.hotkey.bind(hyper, "l", function()
    -- logger.d("toggleAndOpenApps l")
    toggleAndOpenApps({{"ChatGPT"}})
end)
hs.hotkey.bind(hyper, "x", function()
    -- logger.d("toggleAndOpenApps x")
    toggleApps(editorAndIDEs)
end)
hs.hotkey.bind(hyper, "w", function()
    -- logger.d("toggleAndOpenApps w")
    toggleApps(chats)
end)
-- hs.hotkey.bind(hyper, "o", function() toggleApps(tweets) end)
-- hs.hotkey.bind(hyper, "j", function() toggleApps(terminals) end)

-- hs.hotkey.bind(hyper, "k", function() toggleApps(debuggers) end)
-- hs.hotkey.bind(hyper, "r", function() toggleApps(reminders) end)

local canvas = nil
local indicatorTimer = nil
-- macOS-style colors
local normalColor = {alpha = 0.9, white = 1}
local highlightColor = {alpha = 1, white = 1}
local highlightBgColor = {alpha = 1, hex = "#007AFF"} -- macOS accent blue
local dimColor = {alpha = 0.6, white = 1}

hs.application.enableSpotlightForNameSearches(true)

-- Helper to get app icon
local function getAppIcon(appName)
    local app = hs.application.get(appName)
    if app then
        return app:bundleID()
    end
    -- Try to find by name in applications
    local appPath = hs.application.pathForBundleID(appName)
    if appPath then
        return appName
    end
    return nil
end

local function showIndicator(appNames, index)
    if canvas then
        canvas:hide(0)
        canvas = nil
    end
    
    local frame = hs.screen.mainScreen():fullFrame()
    
    -- Sizing constants (macOS HIG inspired)
    local itemHeight = 44
    local itemPadding = 8
    local cornerRadius = 14
    local horizontalPadding = 20
    local verticalPadding = 16
    local iconSize = 28
    local fontSize = 17
    
    local contentHeight = (#appNames * itemHeight) + ((#appNames - 1) * itemPadding)
    local width = 280
    local height = contentHeight + (verticalPadding * 2)
    
    local f = {
        x = frame.x + frame.w / 2 - width / 2,
        y = frame.y + frame.h / 2 - height / 2,
        w = width,
        h = height
    }
    
    canvas = hs.canvas.new(f)
    
    -- Background with rounded corners (dark translucent, macOS style)
    canvas:appendElements({
        action = "fill",
        fillColor = {alpha = 0.85, red = 0.11, green = 0.11, blue = 0.12},
        type = "rectangle",
        roundedRectRadii = {xRadius = cornerRadius, yRadius = cornerRadius},
        trackMouseEnterExit = false
    })
    
    -- Subtle border
    canvas:appendElements({
        action = "stroke",
        strokeColor = {alpha = 0.3, white = 1},
        strokeWidth = 0.5,
        type = "rectangle",
        roundedRectRadii = {xRadius = cornerRadius, yRadius = cornerRadius}
    })
    
    for i, appName in ipairs(appNames) do
        local isSelected = (index == i)
        local yOffset = verticalPadding + ((i - 1) * (itemHeight + itemPadding))
        
        -- Highlight background for selected item (pill shape)
        if isSelected then
            canvas:appendElements({
                action = "fill",
                fillColor = highlightBgColor,
                type = "rectangle",
                roundedRectRadii = {xRadius = 8, yRadius = 8},
                frame = {
                    x = horizontalPadding - 4,
                    y = yOffset,
                    w = width - (horizontalPadding * 2) + 8,
                    h = itemHeight
                }
            })
        end
        
        -- Try to get and display app icon
        local bundleID = getAppIcon(appName)
        if bundleID then
            local icon = hs.image.imageFromAppBundle(bundleID)
            if icon then
                canvas:appendElements({
                    type = "image",
                    image = icon,
                    frame = {
                        x = horizontalPadding + 8,
                        y = yOffset + (itemHeight - iconSize) / 2,
                        w = iconSize,
                        h = iconSize
                    },
                    imageScaling = "scaleProportionally"
                })
            end
        end
        
        -- Display name (clean up bundle IDs for display)
        local displayName = appName
        if appName:match("^com%.") then
            -- Extract readable name from bundle ID
            displayName = appName:match("([^%.]+)$") or appName
            displayName = displayName:gsub("^%l", string.upper)
        end
        
        -- App name text
        canvas:appendElements({
            action = "fill",
            type = "text",
            text = displayName,
            textFont = ".AppleSystemUIFont",
            textSize = fontSize,
            textColor = isSelected and highlightColor or (i < index and dimColor or normalColor),
            textAlignment = "left",
            frame = {
                x = horizontalPadding + iconSize + 16,
                y = yOffset + (itemHeight - fontSize - 6) / 2,
                w = width - horizontalPadding - iconSize - 24,
                h = itemHeight
            }
        })
    end
    
    -- Show with slight fade in
    canvas:alpha(0)
    canvas:show()
    canvas:alpha(1)
    
    -- Cancel previous timer if it exists
    if indicatorTimer then
        indicatorTimer:stop()
        indicatorTimer = nil
    end

    -- Auto-hide after delay
    indicatorTimer = hs.timer.doAfter(0.8, function()
        if canvas then
            canvas:hide(0.2)
            hs.timer.doAfter(0.2, function()
                if canvas then
                    canvas:delete()
                    canvas = nil
                end
                indicatorTimer = nil
            end)
        end
    end)
    
    return canvas
end

local function getAppNames(appList) return appList[1] end

local function getLastUsedApp(appList) return appList["LAST_USED_APP"] end

local function setLastUsedApp(appList, app) appList["LAST_USED_APP"] = app end

local function table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

-- Fast lookup using cache with fallback to direct API lookup
local function getAppFromCache(appName)
    local cached = runningAppsCache[appName]
    -- Validate the cached app is still valid (not terminated)
    if cached then
        -- Check if the app object is still valid by trying to get its pid AND checking isRunning
        -- pid() returns nil if not running, or -1 in some dead states
        -- kind() == 1 means standard app (appears in dock)
        local success, pid = pcall(function() return cached:pid() end)
        local isRunning = cached:isRunning()
        local isRegular = (cached:kind() == 1)
        
        if success and pid and pid > 0 and isRunning and isRegular then
            return cached
        else
            -- App is no longer valid, remove from cache
            -- logger.d("Invalidating cache for " .. appName)
            runningAppsCache[appName] = nil
        end
    end
    
    -- Fallback: try to get app directly (slower but reliable)
    local app = hs.application.get(appName)
    if app and app:isRunning() and app:pid() > 0 and app:kind() == 1 then
        -- Update cache for next time
        addAppToCache(app)
        return app
    end
    
    return nil
end

local function filterOpenApps(apps)
    local map, names = {}, {}

    for _, app in ipairs(apps) do
        -- logger.d("filterOpenApps app " .. app)
        local appObj = getAppFromCache(app)
        -- logger.d("filterOpenApps end " .. app)
        if appObj then
            map[app] = appObj
            names[#names + 1] = app
        end
    end

    return map, names, #names
end

local function openFirstApp(apps, appList)
    for _, app in ipairs(apps) do
        local result = hs.application.launchOrFocus(app)
        if result then
            -- hs.alert.show("Open " .. app)
            return setLastUsedApp(appList, app)
        end
    end
    -- return hs.alert.show("No app found in:\n" .. table.concat(apps, "\n"))
end

local function toggleNextApp(current, totalCount, nameArray, map, appList)
    -- logger.d("toggleNextApp: " .. current .. " total: " .. totalCount)
    local index = math.fmod(current, totalCount) + 1
    local appName = nameArray[index]
    local appObj = map[appName]
    setLastUsedApp(appList, appName)
    -- logger.d("setLastUsedApp: " .. appName)
    if appObj:isFrontmost() then
        appObj:hide()
    else
        -- Unhide first in case the app is hidden
        appObj:unhide()
        -- Use activate(true) to bring all windows to front
        appObj:activate(true)
        
        -- Try multiple methods to ensure focus
        hs.timer.doAfter(0.05, function()
            -- Get windows and focus the first visible one
            local windows = appObj:allWindows()
            for _, win in ipairs(windows) do
                if win:isVisible() and win:isStandard() then
                    win:focus()
                    win:raise()
                    break
                end
            end
            
            -- Fallback to main window
            local mainWindow = appObj:mainWindow()
            if mainWindow then
                mainWindow:focus()
                mainWindow:raise()
            end
        end)
        
        showIndicator(nameArray, index)
    end
end

function toggleApps(appList)
    -- logger.d("toggleApps, appList: " .. table_to_string(appList))
    local appNames = getAppNames(appList)
    local lastUsedApp = getLastUsedApp(appList)
    if lastUsedApp then
        -- logger.d("lastUsedApp: " .. lastUsedApp)
    end

    -- logger.d("filterOpenApps start")
    local appMap, nameArray, totalCount = filterOpenApps(appNames)
    -- logger.d("filterOpenApps done")

    if totalCount == 0 then return openFirstApp(appNames, appList) end

    local foundLastUsed = false
    local currentIndex = 1

    for idx, appName in ipairs(nameArray) do
        if lastUsedApp == appName then
            local appObj = appMap[appName]
            if appObj:isFrontmost() then
                -- logger.d(appName .. "is frontmost")
                foundLastUsed = true
                currentIndex = idx
                break
            else
                -- logger.d(appName .. "is not frontmost, index: " .. idx)
                return toggleNextApp(idx - 1, totalCount, nameArray, appMap, appList)
            end
        end
    end

    if foundLastUsed then
        return toggleNextApp(currentIndex, totalCount, nameArray, appMap, appList)
    end

    currentIndex = 0
    for idx, appName in ipairs(nameArray) do
        if appMap[appName]:isFrontmost() then
            currentIndex = idx
            break
        end
    end

    return toggleNextApp(currentIndex, totalCount, nameArray, appMap, appList)
end

function toggleAndOpenApps(appList)
    -- logger.d("toggleAndOpenApps, appList: " .. table_to_string(appList))
    local appNames = getAppNames(appList)

    for _, app in ipairs(appNames) do
        -- logger.d("read app status: " .. app)
        local appObj = getAppFromCache(app)
        if not appObj then
            local result = hs.application.launchOrFocus(app)
            if result then
                -- hs.alert.show("Open " .. app)
            return setLastUsedApp(appList, app)
            end
        end
    end
    return toggleApps(appList)
end
