# Hammerspoon-xcv58

Personal [Hammerspoon](https://www.hammerspoon.org/) configuration with keyboard- and mouse-driven window management, audio controls, a desktop clock, Chrome sidebar automation, and smart URL opening.

## Install

1. Download Hammerspoon from https://www.hammerspoon.org/
2. Clone this repo: `git clone https://github.com/xcv58/Hammerspoon-xcv58.git`
3. `cd Hammerspoon-xcv58 && zsh ./install.zsh`
4. Open Hammerspoon.app

## Modules

| Module | Description |
|--------|-------------|
| `window.lua` | Window positioning, resizing, halves/quarters, fullscreen, golden ratio, chat mode, and a hotkey modal for keyboard-driven window management |
| `control.lua` | Volume control (increase/decrease with acceleration), mute/unmute, and system sleep |
| `timer.lua` | Desktop clock overlay that displays on all spaces |
| `events.lua` | Auto-mute on screen lock, auto-unmute on unlock |
| `utils.lua` | Config reload on file change, manual reload hotkey |
| `chrome.lua` | Chrome tab-sidebar toggle, active only while Chrome is frontmost |
| `quick-url.lua` | Opens selected text or clipboard content as a URL, go-link, or Google search |

## Spoons

Only the `Windows` Spoon is currently loaded by `init.lua`.

| Spoon | Description |
|-------|-------------|
| `Windows` | Mouse-driven window move (hold Ctrl+Option) and resize (hold Option+Shift) |

The repository also contains `Calendar`, `Shortcuts`, `CircleClock`, `Microphone`, `ModalMgr`, and `SpoonInstall`, but they are not enabled by the current configuration.

## Hotkey Reference

### Window Management (`window.lua`)

| Hotkey | Action |
|--------|--------|
| `Cmd+Ctrl+Shift + H` | Left half |
| `Cmd+Ctrl+Shift + J` | Bottom half |
| `Cmd+Ctrl+Shift + K` | Top half |
| `Cmd+Ctrl+Shift + L` | Right half |
| `Cmd+Ctrl+Shift + M` | Fullscreen (maximize) |
| `Cmd+Ctrl+Shift + ;` | Cycle vertical thirds |
| `Cmd+Ctrl+Shift + G` | Golden ratio (centered) |
| `Cmd+Ctrl+Shift + 1` | Top-left quarter (cycles) |
| `Cmd+Ctrl+Shift + 2` | Top-right quarter (cycles) |
| `Cmd+Ctrl+Shift + I` | Window hints |
| `Cmd+Ctrl+Shift + Q` | Toggle chat mode (reserve the left 18% of the screen) |
| `Cmd+Ctrl+Shift + W` | Resize taller |
| `Cmd+Ctrl+Shift + A` | Resize narrower |
| `Cmd+Ctrl+Shift + S` | Resize shorter |
| `Cmd+Ctrl+Shift + D` | Resize wider |
| `Cmd+Ctrl+Shift + X` | Center window |
| `Cmd+Ctrl+Shift + F` | Fullscreen |
| `Cmd+Ctrl + F` | Fullscreen (alt binding) |
| `Cmd+Ctrl+Shift + P` | Move window to previous screen |
| `Cmd+Ctrl+Shift + N` | Move window to next screen |
| `Cmd+Ctrl+Shift + R` | Resize to 1440x900 and center |
| `Cmd+Ctrl+Shift + O` | Open window hotkey modal (see below) |

#### Window Hotkey Modal (press `Cmd+Ctrl+Shift + O` to enter, `Escape` to exit)

| Key | Action |
|-----|--------|
| `H/J/K/L` | Move window left/down/up/right |
| `Ctrl + H/J/K/L` | Resize narrower/shorter/taller/wider |
| `Shift + H/J` | Resize narrower/shorter |
| `Shift + K` | Maximize height |
| `Shift + L` | Maximize width |
| `1` / `2` | Top-left / top-right quarter |
| `W/A/S/D` | Resize taller/narrower/shorter/wider |
| `C` | Center |
| `F` | Fullscreen |
| `G` | Golden ratio |

Window movement and resizing in the modal use increments of one tenth of the current screen's width or height.

### Volume & System (`control.lua`)

| Hotkey | Action |
|--------|--------|
| `Cmd+Ctrl + K` | Increase volume (hold to accelerate) |
| `Cmd+Ctrl + J` | Decrease volume (hold to accelerate) |
| `Cmd+Ctrl + H` | Mute |
| `Cmd+Ctrl + G` | Unmute |
| `Cmd+Ctrl + L` | System sleep |

### Timer (`timer.lua`)

| Hotkey | Action |
|--------|--------|
| `Cmd+Ctrl + T` | Toggle desktop clock |

### Utilities (`utils.lua`)

| Hotkey | Action |
|--------|--------|
| `Cmd+Ctrl+Alt + R` | Reload Hammerspoon config |

### Smart URL (`quick-url.lua`)

| Hotkey | Action |
|--------|--------|
| `Ctrl+Shift + S` | Copy the current selection (or use the clipboard), then open an `http(s)` URL, `go/...` link, bare domain, or Google search |

### Chrome (`chrome.lua`)

| Hotkey | Action |
|--------|--------|
| `Cmd+Ctrl + S` | Toggle Chrome's tab sidebar via its native `Cmd+Shift+L` command; enabled only while Chrome is frontmost |

Requires a Chrome version with the native vertical-tab collapse/expand shortcut.

### Windows Spoon (mouse-driven, no hotkeys)

| Modifier | Action |
|----------|--------|
| Hold `Ctrl + Option` and move the mouse | Move window under cursor |
| Hold `Option + Shift` and move the mouse | Resize window under cursor |

## Auto-Behaviors

- **Auto-reload**: Config reloads automatically when any `.lua` file changes in `~/.hammerspoon/`
- **Screen lock**: Mutes audio on lock, unmutes on unlock
- **Desktop clock**: Starts automatically, persists across spaces, and prefers a non-primary display when multiple displays are connected
- **Chrome hotkey**: Enables the sidebar hotkey when Chrome becomes active and disables it when another app becomes active
- **Logging and CLI**: Enables global debug logging and installs the `hs` command-line interface

## License

[MIT](LICENSE)
