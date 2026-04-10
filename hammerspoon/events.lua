local function handler(type)
    if type == hs.caffeinate.watcher.screensDidLock then
        return setMuted(true)
    end
    if type == hs.caffeinate.watcher.screensDidUnlock then
        return setMuted(false)
    end
end

local eventsWatcher = hs.caffeinate.watcher.new(handler)
eventsWatcher:start()
