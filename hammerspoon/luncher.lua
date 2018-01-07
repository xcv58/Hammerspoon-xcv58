local hyper = {"cmd", "shift"}

local browsers = {{"Google Chrome", "Safari"}}
local editorAndIDEs = {{"Atom Beta", "org.vim.MacVim", "Emacs", "com.jetbrains.intellij.ce", "Xcode"}}
local emails = {{"Mailplane 3"}}
local chats = {{"HipChat", "WeChat", "Messages", "Telegram"}}
local tweets = {{"Tweetbot"}}
local terminals = {{"iTerm2"}}
local reminders = {{"Reminders", "Quip"}}
local debuggers = {{"com.postmanlabs.mac"}}

hs.hotkey.bind(hyper, "s", function() toggleApps(browsers) end)
hs.hotkey.bind(hyper, "a", function() toggleApps(emails) end)
hs.hotkey.bind(hyper, "x", function() toggleApps(editorAndIDEs) end)
hs.hotkey.bind(hyper, "w", function() toggleApps(chats) end)
hs.hotkey.bind(hyper, "o", function() toggleApps(tweets) end)
hs.hotkey.bind(hyper, "j", function() toggleApps(terminals) end)

-- hs.hotkey.bind(hyper, "k", function() toggleApps(debuggers) end)
-- hs.hotkey.bind(hyper, "r", function() toggleApps(reminders) end)

function getAppNames (appList)
    return appList[1]
end

function getLastUsedApp (appList)
    return appList["LAST_USED_APP"]
end

function setLastUsedApp (appList, app)
    appList["LAST_USED_APP"] = app
end

function toggleApps (appList)
    local appNames = getAppNames(appList)
    local lastUsedApp = getLastUsedApp(appList)

    local appMap, nameArray, totalCount = filterOpenApps(appNames)

    if totalCount == 0 then
        return openFirstApp(appNames)
    end

    local foundLastUsed, index = false, 1

    for _, appName in pairs(nameArray) do
        if lastUsedApp == appName then
            local appObj = appMap[appName]
            if appObj:isFrontmost() then
                foundLastUsed = true
                index = _
                break
            else
                return toggleApp(appObj)
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

function toggleNextApp (current, totalCount, nameArray, map, appList)
    local index = math.fmod(current, totalCount) + 1
    local appName = nameArray[index]
    local appObj = map[appName]
    setLastUsedApp(appList, appName)
    return toggleApp(appObj)
end

function filterOpenApps (apps)
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

function toggleApp (app)
    if app:isFrontmost() then
        hs.application.hide(app)
    else
        app:activate()
    end
end


function openFirstApp (apps)
    for _, app in pairs(apps) do
        local result = hs.application.launchOrFocus(app)
        if result then
            hs.alert.show("Open " .. app)
            return setLastUsedApp(appList, app)
        end
    end
    return hs.alert.show("No app found in:\n" .. table.concat(apps, "\n"))
end
