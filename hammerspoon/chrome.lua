local hyper = {"cmd", "ctrl"}

local function toggleSidebar()
    if hs.application.frontmostApplication():bundleID() ~= "com.google.Chrome" then
        return
    end

    local chrome = hs.application.get("com.google.Chrome")
    if not chrome then
        hs.alert.show("Chrome not running")
        return
    end

    local win = chrome:mainWindow()
    if not win then
        hs.alert.show("No Chrome window")
        return
    end

    local axWin = hs.axuielement.windowElement(win)
    local targets = {
        ["Expand tabs"] = true, ["Collapse tabs"] = true,
        ["Expand Tabs"] = true, ["Collapse Tabs"] = true,
    }

    local function findButton(el, depth)
        if depth > 10 then return nil end
        local role = el:attributeValue("AXRole") or ""
        local title = el:attributeValue("AXTitle") or ""
        local desc = el:attributeValue("AXDescription") or ""
        if role == "AXButton" and (targets[title] or targets[desc]) then
            return el
        end
        for _, child in ipairs(el:attributeValue("AXChildren") or {}) do
            local found = findButton(child, depth + 1)
            if found then return found end
        end
        return nil
    end

    local btn = findButton(axWin, 0)
    if btn then
        btn:performAction("AXPress")
    else
        hs.alert.show("Sidebar button not found")
    end
end

local sidebarHotkey = hs.hotkey.new(hyper, "s", toggleSidebar)

local function handleAppEvent(_, event, app)
    if event == hs.application.watcher.activated then
        if app:bundleID() == "com.google.Chrome" then
            sidebarHotkey:enable()
        else
            sidebarHotkey:disable()
        end
    end
end

local chromeWatcher = hs.application.watcher.new(handleAppEvent)
chromeWatcher:start()

if hs.application.frontmostApplication():bundleID() == "com.google.Chrome" then
    sidebarHotkey:enable()
end

return { watcher = chromeWatcher, hotkey = sidebarHotkey }
