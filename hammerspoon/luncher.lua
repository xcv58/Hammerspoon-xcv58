local hyper = {"cmd", "shift"}

local browsers = {"Google Chrome", "Safari"}
local editors = {"Atom", "Emacs"}
local emails = {"CloudMagic Email"}
local chats = {"HipChat", "WeChat", "Messages"}
local tweets = {"Tweetbot"}

hs.hotkey.bind(hyper, "s", function() toggleApps(browsers) end)
hs.hotkey.bind(hyper, "a", function() toggleApps(emails) end)
hs.hotkey.bind(hyper, "x", function() toggleApps(editors) end)
hs.hotkey.bind(hyper, "w", function() toggleApps(chats) end)
hs.hotkey.bind(hyper, "o", function() toggleApps(tweets) end)

function toggleApps (apps)
    allApps = filterOpenApps(apps)

    if #allApps == 0 then
        hs.alert.show("Open " .. apps[1])
        return hs.application.open(apps[1])
    end

    needOpen = false

    for _, app in pairs(allApps) do
        if needOpen then
            return toggleApp(app)
        end

        if app:isFrontmost() then
            needOpen = true
        end
    end

    return toggleApp(allApps[1])
end

function filterOpenApps (apps)
    results = {}

    for _, app in pairs(apps) do
        appObj = hs.application.get(app)
        if appObj then
            results[#results + 1] = appObj
        end
    end

    return results
end

function toggleApp (app)
    if app:isFrontmost() then
        hs.application.hide(app)
    else
        app:activate()
    end
end
