local hotkey = { "ctrl", "shift" }
local copyDelaySeconds = 0.15
local pending = false

local function trim(value)
    return value:match("^%s*(.-)%s*$")
end

local function targetFor(query)
    if query:match("^http://") or query:match("^https://") then
        return query
    end

    if query:match("^go/[^%s]+") then
        return "http://" .. query
    end

    if query:match("^[%w%-._~%%]+%.[%a][%w%-]*$")
        or query:match("^[%w%-._~%%]+%.[%a][%w%-]*[:/?#][^%s]*$") then
        return "https://" .. query
    end

    return "https://www.google.com/search?q=" .. hs.http.encodeForQuery(query)
end

local function openFromSelectionOrClipboard()
    if pending then
        return
    end

    pending = true
    local clipboardBeforeCopy = hs.pasteboard.getContents() or ""

    -- Copying the active selection works in most macOS apps. If it does not
    -- change the pasteboard, the saved clipboard value remains the fallback.
    hs.eventtap.keyStroke({ "cmd" }, "c", 0)

    hs.timer.doAfter(copyDelaySeconds, function()
        pending = false

        local query = trim(hs.pasteboard.getContents() or clipboardBeforeCopy)
        if query == "" then
            hs.alert.show("Select or copy text first")
            return
        end

        hs.pasteboard.setContents(query)
        hs.urlevent.openURL(targetFor(query))
    end)
end

hs.hotkey.bind(hotkey, "s", openFromSelectionOrClipboard)

return { open = openFromSelectionOrClipboard }
