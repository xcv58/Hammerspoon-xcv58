local hyper = {"cmd", "ctrl"}
local chromeBundleID = "com.google.Chrome"

local function isChromeFrontmost()
    local app = hs.application.frontmostApplication()
    return app ~= nil and app:bundleID() == chromeBundleID
end

local function toggleSidebar()
    if not isChromeFrontmost() then
        return
    end

    local chrome = hs.application.get(chromeBundleID)
    if not chrome then
        hs.alert.show("Chrome not running")
        return
    end

    local win = chrome:mainWindow()
    if not win then
        hs.alert.show("No Chrome window")
        return
    end

    -- Chrome's native toggle avoids Accessibility labels that include shortcuts.
    hs.eventtap.keyStroke({"cmd", "shift"}, "l", 0, chrome)
end

local sidebarHotkey = hs.hotkey.new(hyper, "s", toggleSidebar)

local function handleAppEvent(_, event, app)
    if event == hs.application.watcher.activated then
        if app and app:bundleID() == chromeBundleID then
            sidebarHotkey:enable()
        else
            sidebarHotkey:disable()
        end
    end
end

local chromeWatcher = hs.application.watcher.new(handleAppEvent)
chromeWatcher:start()

if isChromeFrontmost() then
    sidebarHotkey:enable()
end

return { watcher = chromeWatcher, hotkey = sidebarHotkey }
