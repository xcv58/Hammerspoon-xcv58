# CLAUDE.md - Project Guide

## Project Overview

Hammerspoon configuration for macOS automation. The `install.zsh` script symlinks `hammerspoon/` to `~/.hammerspoon/`.

## Project Structure

```
hammerspoon/
  init.lua          # Entry point - loads all modules and Spoons
  window.lua        # Window management (hyper = Cmd+Ctrl+Shift)
  control.lua       # Volume/mute/sleep (hyper = Cmd+Ctrl)
  timer.lua         # Desktop clock overlay
  events.lua        # Screen lock/unlock handlers
  utils.lua         # Config reload utility
  slack/
    init.lua        # Slack module entry point
    focus.lua       # Slack AX accessibility helpers
    find.lua        # AX tree search utilities
    debug.lua       # AX debug helpers
  Spoons/
    Calendar.spoon/     # Desktop calendar widget
    Shortcuts.spoon/    # macOS Shortcuts integration
    Windows.spoon/      # Mouse-driven window move/resize
    ModalMgr.spoon/     # Available but not loaded
    CircleClock.spoon/  # Available but not loaded
    Microphone.spoon/   # Available but not loaded
    SpoonInstall.spoon/ # Available but not loaded
```

## Key Patterns

- **Module loading**: `init.lua` uses `require` for core modules and `hs.loadSpoon()` for Spoons
- **Hyper key**: Two hyper combos are used:
  - `{"cmd", "ctrl", "shift"}` (3-key) in `window.lua`
  - `{"cmd", "ctrl"}` (2-key) in `control.lua`, `timer.lua`, `Shortcuts.spoon`
- **Spoon convention**: Each Spoon lives in `Spoons/<Name>.spoon/init.lua`, returns a table with an `:init()` method

## Making Changes

- Config auto-reloads when any `.lua` file changes in `~/.hammerspoon/`
- Manual reload: `Cmd+Ctrl+Alt + R`
- Debug logging: global log level is set to `debug` in `init.lua`
- Use `hs.logger.new('YourModule')` for module-specific logging
- Hammerspoon console (`Cmd+Alt+Ctrl+Z` by default in the app) is useful for testing

## Notes

- `launcher.lua` exists but is commented out in `init.lua` (disabled)
- `ModalMgr.spoon` is available but not loaded (commented out)
- The `events.lua` module calls `setMuted()` from `control.lua` — `control.lua` must be loaded first
- Lua files use a mix of `local` and global functions; prefer `local` for new code
- **Always check whether `README.md` and `CLAUDE.md` need updates** when adding, removing, or changing modules, Spoons, or hotkeys
