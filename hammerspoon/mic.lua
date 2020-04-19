local hyper = {"⌃", "⇧"}

local log = hs.logger.new('mic', 'debug')

local function getInputDevice()
    return hs.audiodevice.defaultInputDevice()
end

local function showAlert(text)
    hs.alert.closeAll(0.2)
    hs.alert.show(text)
end

local function toggleInputMuted()
    log.d("toggleInputMuted")
    inputDevice = getInputDevice()
    if not inputDevice then
        return showAlert("No input device")
    end
    local muted = inputDevice:inputMuted()
    log.d("toggleInputMuted: " .. tostring(not muted))
    inputDevice:setMuted(not muted)
    showAlert((muted and "Unmute " or "Mute ") .. inputDevice:name())
end

local function setMuted(muted)
    log.d("setMuted:" .. tostring(muted))
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

hs.hotkey.bind(hyper, "t", toggleInputMuted)

-- Set hotkey modal
local function getIndicator()
  local frame = hs.screen.mainScreen():fullFrame()
  local width = 400
  local height = 45
  local f = {
    x = frame.x + frame.w / 2 - width / 2,
    y = frame.y,
    w = width,
    h = height
  }
  return hs.canvas.new(f):appendElements({
    action = "fill",
    fillColor = { alpha = 0.8, black = 1 },
    type = "rectangle",
  }, {
    action = "fill",
    type = "text",
    textColor = { red = 1 },
    textSize = 32,
    textAlignment = "center",
    text = hyper[1] .. "+" .. hyper[2] .. "+S to exit speak mode"
  })
end

local inidcator = nil

local winHotkeyModal = hs.hotkey.modal.new(hyper, "s")

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
  indicator = getIndicator():show(1)
  unmuteInputDevice()
end

winHotkeyModal:bind(hyper, "s", function()
  winHotkeyModal:exit()
end)
