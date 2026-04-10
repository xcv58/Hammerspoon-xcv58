local control = require "control"

local function handler(type)
    if type == hs.caffeinate.watcher.screensDidLock then
        return control.setMuted(true)
    end
    if type == hs.caffeinate.watcher.screensDidUnlock then
        return control.setMuted(false)
    end
end

local eventsWatcher = hs.caffeinate.watcher.new(handler)
eventsWatcher:start()
