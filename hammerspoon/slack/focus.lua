local find = require('slack.find')
local debug = require('slack.debug')

----------

local function getAxSlackWindow()
  local app = hs.application.find("Slack")
  if not app then return end

  -- Electron apps require this attribute to be set or else you cannot
  -- read the accessibility tree
  axApp = hs.axuielement.applicationElement(app)
  axApp:setAttributeValue('AXManualAccessibility', true)

  local window = app:mainWindow()
  window:focus()

  return hs.axuielement.windowElement(window)
end

local function hasClass(element, class)
  local classList = element:attributeValue('AXDOMClassList')
  if not classList then return false end

  return hs.fnutils.contains(classList, class)
end

-----------

local module = {}

module.mainMessageBox = function()
  local window = getAxSlackWindow()
  if not window then return end

  local textarea = find.searchByChain(window, {
    function(elem) return hasClass(elem, 'p-workspace-layout') end,
    function(elem) return elem:attributeValue('AXSubrole') == 'AXLandmarkMain' end,
    function(elem) return hasClass(elem, 'p-workspace__primary_view_contents') end,
    function(elem) return hasClass(elem, 'c-wysiwyg_container') end,
    function(elem) return elem:attributeValue('AXRole') == 'AXTextArea' end,
  })

  if textarea then
    textarea:setAttributeValue('AXFocused', true)
  end
end

module.threadMessageBox = function(withRetry)
  withRetry = withRetry or false

  local window = getAxSlackWindow()
  if not window then return end

  local findTextarea = function()
    return find.searchByChain(window, {
      function(elem) return hasClass(elem, 'p-workspace-layout') end,
      function(elem) return hasClass(elem, 'p-flexpane') end,
      function(elem) return hasClass(elem, 'p-threads_flexpane') end,
      function(elem) return hasClass(elem, 'c-wysiwyg_container') end,
      function(elem) return elem:attributeValue('AXRole') == 'AXTextArea' end,
    })
  end

  local textarea = nil

  local textareaVisible = function()
    textarea = findTextarea()
    return not not textarea
  end

  local focusTextarea = function()
    textarea:setAttributeValue('AXFocused', true)
  end

  if withRetry then
    -- Do it in a retry loop
    local loopTimer = hs.timer.waitUntil(textareaVisible, focusTextarea)

    -- Give up after 2 seconds
    hs.timer.doAfter(2, function()
      loopTimer:stop()
    end)
  elseif textareaVisible() then
    -- fire it once
    focusTextarea()
  end
end

module.leaveChannel = function()
  local window = getAxSlackWindow()
  if not window then return end

  local button = find.searchByChain(window, {
    function(elem) return hasClass(elem, 'p-workspace-layout') end,
    function(elem)
      return elem:attributeValue('AXRole') == 'AXPopUpButton' and
        hasClass(elem, 'p-view_header__big_button--channel')
    end,
  })

  if not button then return end

  button:performAction('AXPress')

  find.clickButton(function()
    return find.searchByChain(window, {
      function(elem)
        return elem:attributeValue('AXSubrole') == 'AXApplicationDialog' and
          hasClass(elem, 'p-about_modal')
      end,
      function(elem)
        return elem:attributeValue('AXRole') == 'AXButton' and
          elem:attributeValue('AXTitle') == 'Leave channel'
      end,
    })
  end)
end

module.setLunch = function()
  local window = getAxSlackWindow()
  if not window then return end

  find.clickButton(function()
    return find.searchByChain(window, {
      function(elem)
        return hasClass(elem, 'p-ia__nav__user')
      end,
    })
  end)

  find.clickButton(function()
    return find.searchByChain(window, {
      function(elem)
        return hasClass(elem, 'p-ia__main_menu__custom_status_icon')
      end,
    })
  end)

  find.clickButton(function()
    local i = 0
    return find.searchByChain(window, {
      function(elem)
        if hasClass(elem, 'p-custom_status_modal__preset') then
          i = i + 1
          return i == 2
        end
      end,
    })
  end)

  find.clickButton(function()
    return find.searchByChain(window, {
      function(elem)
        return hasClass(elem, 'c-input_checkbox--focus-visible')
      end,
    })
  end)

  find.clickButton(function()
    return find.searchByChain(window, {
      function(elem)
        return hasClass(elem, 'c-button--primary')
      end,
    })
  end)
end

return module
