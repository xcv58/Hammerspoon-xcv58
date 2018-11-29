function handler(type)
    if type == hs.caffeinate.watcher.screensDidLock then
        return setMuted(true)
    end
    if type == hs.caffeinate.watcher.screensDidUnlock then
        return setMuted(false)
    end
end

hs.caffeinate.watcher.new(handler):start()
