hs.hotkey.bind({"cmd", "ctrl", "alt"}, "r", hs.reload)

local function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then doReload = true end
    end
    if doReload then hs.reload() end
end

return { reloadConfig = reloadConfig }
