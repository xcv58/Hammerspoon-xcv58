local hyper = {"cmd", "shift"}

local browsers = {{"Google Chrome", "Safari"}}
local editors = {{"Sublime Text", "Atom", "Emacs"}}
local emails = {{"CloudMagic Email"}}
local chats = {{"HipChat", "WeChat", "Messages"}}
local tweets = {{"Tweetbot"}}
local ides = {{"com.jetbrains.intellij.ce"}}

hs.hotkey.bind(hyper, "s", function() toggleApps(browsers) end)
hs.hotkey.bind(hyper, "a", function() toggleApps(emails) end)
hs.hotkey.bind(hyper, "x", function() toggleApps(editors) end)
hs.hotkey.bind(hyper, "w", function() toggleApps(chats) end)
hs.hotkey.bind(hyper, "o", function() toggleApps(tweets) end)
hs.hotkey.bind(hyper, "j", function() toggleApps(ides) end)

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
        local app = appNames[1]
        hs.alert.show("Open " .. app)
        setLastUsedApp(appList, app);
        return hs.application.open(app)
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
