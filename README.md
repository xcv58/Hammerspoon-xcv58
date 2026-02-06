# Hammerspoon-xcv58

Personal [Hammerspoon](https://www.hammerspoon.org/) configuration with window management, volume control, system utilities, and macOS Shortcuts integration.

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
| `slack/` | Slack accessibility helpers (focus message boxes, set status, leave channel) |

## Spoons

| Spoon | Description |
|-------|-------------|
| `Calendar` | Desktop calendar widget (bottom-right corner) |
| `Shortcuts` | macOS Shortcuts integration for meeting mode and audio device switching |
| `Windows` | Mouse-driven window move (Ctrl+Alt+drag) and resize (Alt+Shift+drag) |
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
| `Cmd+Ctrl+Shift + Q` | Toggle chat mode |
| `Cmd+Ctrl+Shift + W` | Resize taller |
| `Cmd+Ctrl+Shift + A` | Resize narrower |
| `Cmd+Ctrl+Shift + S` | Resize shorter |
| `Cmd+Ctrl+Shift + D` | Resize wider |
| `Cmd+Ctrl+Shift + X` | Center window |
| `Cmd+Ctrl+Shift + F` | Fullscreen |
| `Cmd+Ctrl + F` | Fullscreen (alt binding) |
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

### Shortcuts Spoon (`Shortcuts.spoon`)

| Hotkey | Action |
|--------|--------|
| `Cmd+Ctrl + M` | Start meeting (macOS Shortcut) |
| `Cmd+Ctrl + N` | Stop meeting (macOS Shortcut) |
| `Cmd+Ctrl + X` | Switch to AirPods (Sound menu) |

### Windows Spoon (mouse-driven, no hotkeys)

| Modifier | Action |
|----------|--------|
| `Ctrl + Alt` + mouse move | Move window under cursor |
| `Alt + Shift` + mouse move | Resize window under cursor |

## Auto-Behaviors

- **Auto-reload**: Config reloads automatically when any `.lua` file changes in `~/.hammerspoon/`
- **Screen lock**: Mutes audio on lock, unmutes on unlock
- **Desktop clock**: Starts automatically, persists across spaces
- **Calendar**: Desktop calendar widget starts automatically

## License

[MIT](LICENSE)
