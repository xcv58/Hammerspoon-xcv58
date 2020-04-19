--- === Microphone ===
---
--- Control the default Microphone mute state, [instructions](https://github.com/xcv58/Hammerspoon-xcv58/wiki/Microphone-Spoon).
---
--- Download: [https://github.com/xcv58/Hammerspoon-xcv58/raw/master/hammerspoon/Spoons/Microphone.spoon.zip](https://github.com/xcv58/Hammerspoon-xcv58/raw/master/hammerspoon/Spoons/Microphone.spoon.zip)

local obj = {}
obj.__index = obj
obj.name = "Microphone"
obj.version = "0.1"
obj.author = "xcv58 <hammerspoon_microphone@xcv58.com>"
obj.homepage = "https://github.com/xcv58/Hammerspoon-xcv58"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- Microphone.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('Microphone')
local logger = obj.logger

--- Microphone:init()
--- Method
--- init.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The Microphone object
function obj:init()
    self.logger.d("init")
    self._init_done = true
    return self
end

local function modsKeyTostring(mods, key)
    return string.format("%s+%s", table.concat(mods, "+"), key)
end

local function getInputDevice()
    return hs.audiodevice.defaultInputDevice()
end

local function showAlert(text)
    hs.alert.closeAll(0.2)
    hs.alert.show(text)
end

local function toggleInputMuted()
    logger.d("toggleInputMuted")
    inputDevice = getInputDevice()
    if not inputDevice then
        return showAlert("No input device")
    end
    local muted = inputDevice:inputMuted()
    logger.d("toggleInputMuted: " .. tostring(not muted))
    inputDevice:setMuted(not muted)
    showAlert((muted and "Unmute " or "Mute ") .. inputDevice:name())
end

local function setMuted(muted)
    logger.d("setMuted:" .. tostring(muted))
    inputDevice = getInputDevice()
    if not inputDevice then
        return showAlert("No input device")
    end
    inputDevice:setMuted(muted)
end

local function muteInputDevice()
    setMuted(true)
end

local function unmuteInputDevice()
    setMuted(false)
end

local function getIndicator(hotkeyMods, hotkey)
    local frame = hs.screen.mainScreen():fullFrame()
    local width = 400
    local height = 45
    local f = {
        x = frame.x + frame.w / 2 - width / 2,
        y = frame.y,
        w = width,
        h = height
    }
    return hs.canvas.new(f):appendElements(
        {
            action = "fill",
            fillColor = {alpha = 0.8, black = 1},
            type = "rectangle"
        },
        {
            action = "fill",
            type = "text",
            textColor = {red = 1},
            textSize = 32,
            textAlignment = "center",
            text = modsKeyTostring(hotkeyMods, hotkey) .. " to exit speak mode"
        }
    )
end

local function initToggleMuted(hotkeyMods, hotkey)
    logger.d("init toggleMuted")
    hs.hotkey.bind(hotkeyMods, hotkey, toggleInputMuted)
end

local function initSpeakMode(hotkeyMods, hotkey)
    logger.d("init toggleSpeakModal")
    local indicator = nil
    local winHotkeyModal = hs.hotkey.modal.new(hotkeyMods, hotkey)
    function winHotkeyModal:exited()
        hs.alert.closeAll()
        hs.alert.show("Exit speak mode")
        muteInputDevice()
        indicator:delete(0.2)
        indicator = nil
    end

    function winHotkeyModal:entered()
        hs.alert.closeAll()
        hs.alert.show("Speak mode")
        indicator = getIndicator(hotkeyMods, hotkey):show(1)
        unmuteInputDevice()
    end

    winHotkeyModal:bind(
        hotkeyMods,
        hotkey,
        function()
            winHotkeyModal:exit()
        end
    )
end

--- Microphone.hyper
--- Variable
--- Default hotkey mods.
obj.hyper = {"⌃", "⇧"}

--- Microphone.toggleKey
--- Variable
--- Default key to toggle mute state.
obj.toggleKey = "t"

--- Microphone.toggleSpeakModal
--- Variable
--- Default key to toggle speak mode.
obj.toggleSpeakModal = "s"

--- Microphone.defaultMapping
--- Variable
--- Default hotmap mapping to define available functions with related hotkey and init function.
obj.defaultMapping = {
    toggleMute = {
        key = {obj.hyper, obj.toggleKey},
        fn = initToggleMuted
    },
    toggleSpeakModal = {
        key = {obj.hyper, obj.toggleSpeakModal},
        fn = initSpeakMode
    }
}

--- Microphone:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for Microphone
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * toggleMute - Toggle the state of default input device
---   * toggleSpeakModal - Toggle the speak mode:
---                        1st hit -> unmute the default input device
---                        2nd hit -> mute the default input device
---
--- Returns:
---  * The Microphone object
function obj:bindHotKeys(mapping)
    mapping = mapping or {}
    self.logger.d("bindHotKeys")
    for k, v in pairs(self.defaultMapping) do
        key = mapping[k] and mapping[k] or v["key"]
        hotkeyMods = key[1]
        hotkey = key[2]
        self.logger.df("init function %s: %s", k, modsKeyTostring(hotkeyMods, hotkey))
        v["fn"](hotkeyMods, hotkey)
    end
    return self
end

return obj
