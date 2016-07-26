function tolerance(a, b) return math.abs(a - b) < 32 end

function resize(x, y, w, h)
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local max = win:screen():frame()
    local ww = max.w / w
    local hh = max.h / h
    local xx = max.x + (x * ww)
    local yy = max.y + (y * hh)

    if ischatmode and x == 0 then
        xx = xx + CHAT_MODE_WIDTH
        ww = ww - CHAT_MODE_WIDTH
    end

    if tolerance(f.x, xx) and tolerance(f.y, yy) and tolerance(f.w, ww) and tolerance(f.h, hh) then
        if w > h then
            x = (x + 1) % w
        elseif h > w then
            y = (y + 1) % h
        else
            x = (x == 0) and 0.9999 or 0
            y = (y == 0) and 0.9999 or 0
        end
        return resize(x, y, w, h)
    end
    f.x = xx
    f.y = yy
    f.w = ww
    f.h = hh
    return win:setFrame(f)
end

function fullscreen()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local max = win:screen():frame()
    if ischatmode then
        f.x = max.x + CHAT_MODE_WIDTH
        f.w = max.w - CHAT_MODE_WIDTH
    else
        f.x = max.x
        f.w = max.w
    end
    f.y = max.y
    f.h = max.h
    win:setFrame(f)
end

function center()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    local max = win:screen():frame()
    f.x = (max.w - max.x - f.w) / 2
    f.y = (max.h - max.y - f.h) / 2
    win:setFrame(f)
end

ischatmode = false
function chatmode()
    ischatmode = not ischatmode
    if ischatmode then
        hs.alert.show('enable chat mode')
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local max = win:screen():frame()
        CHAT_MODE_WIDTH = max.w * 0.18
        f.x = max.x
        f.y = max.y
        f.w = CHAT_MODE_WIDTH
        f.h = max.h
        win:setFrame(f)
    else
        hs.alert.show('disable chat mode')
    end
end
