local logger = hs.logger.new('Launcher')

local hyper = {"cmd", "shift"}

local browsers = {
    {
        "Google Chrome", "Google Chrome Dev", "Safari",
        "com.google.Chrome.canary", "Firefox"
    }
}
local editorAndIDEs = {
    {
        "com.microsoft.VSCode", "Visual Studio Code", "com.github.atom",
        "org.vim.MacVim", "org.gnu.Emacs", "com.jetbrains.intellij.ce",
        "com.jetbrains.intellij", "Xcode"
    }
}
local emails = {{
    "Gmail",
    "Google Calendar"
}}
local chats = {{"Slack", "WeChat", "Telegram", "Messages", "FaceTime", "Quip"}}
local tweets = {{"Tweetbot"}}
local terminals = {{"iTerm2", "iTerm.app"}}
local reminders = {{"Reminders", "Quip"}}
local debuggers = {{"com.postmanlabs.mac"}}

hs.hotkey.bind(hyper, "s", function() toggleApps(browsers) end)
hs.hotkey.bind(hyper, "a", function() toggleApps(emails) end)
hs.hotkey.bind(hyper, "x", function() toggleApps(editorAndIDEs) end)
hs.hotkey.bind(hyper, "w", function() toggleApps(chats) end)
-- hs.hotkey.bind(hyper, "o", function() toggleApps(tweets) end)
hs.hotkey.bind(hyper, "j", function() toggleApps(terminals) end)

-- hs.hotkey.bind(hyper, "k", function() toggleApps(debuggers) end)
-- hs.hotkey.bind(hyper, "r", function() toggleApps(reminders) end)

local canvas = nil
local normalColor = {alpha = 0.8964, white = 1}
local highlightColor = {alpha = 0.8964, red = 1}

local function showIndicator(appNames, index)
    if canvas then
        canvas:hide(0)
        canvas:delete(0)
        canvas = nil
    end
    local frame = hs.screen.mainScreen():fullFrame()
    local width = 800
    local height = 60 * #appNames
    local f = {
        x = frame.x + frame.w / 2 - width / 2,
        y = frame.y + frame.h / 2,
        w = width,
        h = height
    }
    canvas = hs.canvas.new(f)
    canvas:appendElements({
        action = "fill",
        fillColor = {alpha = 0.8, black = 1},
        type = "rectangle",
        trackMouseEnterExit = true
    })
    for i, appName in pairs(appNames) do
        canvas:appendElements({
            action = "fill",
            type = "text",
            absolutePosition = fasle,
            frame = {
                x = "0%",
                y = (100 / #appNames * (i - 1)) .. "%",
                h = "100%",
                w = "100%"
            },
            textColor = (index == i and highlightColor or normalColor),
            textSize = 42,
            textAlignment = "center",
            text = appName
        })
    end
    canvas:show()
    canvas:hide(1)
    return canvas
end

function getAppNames(appList) return appList[1] end

function getLastUsedApp(appList) return appList["LAST_USED_APP"] end

function setLastUsedApp(appList, app) appList["LAST_USED_APP"] = app end

function table_to_string(tbl)
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

function toggleApps(appList)
    logger.d("toggleApps, appList: " .. table_to_string(appList))
    local appNames = getAppNames(appList)
    local lastUsedApp = getLastUsedApp(appList)
    if lastUsedApp then
        logger.d("lastUsedApp: " .. lastUsedApp)
    end

    local appMap, nameArray, totalCount = filterOpenApps(appNames)

    if totalCount == 0 then return openFirstApp(appNames) end

    local foundLastUsed, index = false, 1

    for _, appName in pairs(nameArray) do
        if lastUsedApp == appName then
            local appObj = appMap[appName]
            if appObj:isFrontmost() then
                logger.d(appName .. "is frontmost")
                foundLastUsed = true
                index = _
                break
            else
                logger.d(appName .. "is not frontmost, index: " .. _)
                return toggleNextApp(_ - 1, totalCount, nameArray, appMap, appList)
            end
        end
    end

    if foundLastUsed then
        return toggleNextApp(index, totalCount, nameArray, appMap, appList)
    end

    index = 0
    for _, appName in pairs(nameArray) do
        if appMap[appName]:isFrontmost() then
            index = _
            break
        end
    end

    return toggleNextApp(index, totalCount, nameArray, appMap, appList)
end

function toggleNextApp(current, totalCount, nameArray, map, appList)
    logger.d("toggleNextApp: " .. current .. " total: " .. totalCount)
    local index = math.fmod(current, totalCount) + 1
    local appName = nameArray[index]
    local appObj = map[appName]
    setLastUsedApp(appList, appName)
    logger.d("setLastUsedApp: " .. appName)
    if appObj:isFrontmost() then
        appObj:hide()
    else
        appObj:activate()
        showIndicator(nameArray, index)
    end
end

function filterOpenApps(apps)
    local map, names = {}, {}

    for _, app in pairs(apps) do
        appObj = hs.application.get(app)
        if appObj then
            map[app] = appObj
            names[#names + 1] = app
        end
    end

    return map, names, #names
end

function openFirstApp(apps)
    for _, app in pairs(apps) do
        local result = hs.application.launchOrFocus(app)
        if result then
            hs.alert.show("Open " .. app)
            return setLastUsedApp(appList, app)
        end
    end
    return hs.alert.show("No app found in:\n" .. table.concat(apps, "\n"))
end
