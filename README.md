# Don't Minimize Me

A Windows utility script that prevents windows from being minimized. Instead of disappearing into the taskbar, minimized windows are restored and sent to the back of the window stack while remaining fully rendered.

## Purpose

This script was created to solve a specific OBS Studio problem: when capturing certain windows using "Window Capture" (for example, browser games in Google Chrome), the capture fails if the window is minimized. This happens because Windows stops rendering minimized windows.

With Don't Minimize Me, windows are never truly minimized. They are sent behind other windows but remain fully rendered, keeping your OBS capture intact even when you instinctively hit the minimize button.

## Requirements

- Windows 10 (not tested on Windows 11)
- AutoHotkey v2.0 or later

## Installation

1. Install [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Download `dont-minimize-me.ahk`
3. Double-click the script to run it

## Usage

The script runs in the background and automatically intercepts minimize actions.

### Keyboard Shortcuts

| Shortcut       | Action                        |
|----------------|-------------------------------|
| Win + F12      | Enable / Disable the script   |
| Win + Ctrl + R | Reload the script             |

### Behavior

- When a window is minimized, it is immediately restored and moved behind all other windows
- Clicking on a window in the taskbar brings it back to the front at its original position
- Window positions and sizes are preserved

## Features

- Works with multiple monitors
- Automatically ignores system windows and toolbars
- Memory-safe with automatic cleanup of closed window references
- Protection against infinite loops with problematic windows
- Limits tracking to 50 windows to prevent memory issues

## Limitations

- Some applications with custom minimize behavior may not work correctly
- UWP / Microsoft Store applications may behave unexpectedly
- Fullscreen games should be excluded from window tracking

## Technical Notes

The script operates by:

1. Polling all visible windows every 250ms
2. Storing window positions and states in memory
3. Detecting minimize events by comparing current state to last known state
4. Restoring minimized windows and repositioning them

Windows that refuse to be restored are automatically added to an ignore list to prevent CPU-intensive loops.

## Credits

This script was written with the assistance of Claude (Anthropic).

## License

MIT License - Feel free to use, modify, and distribute.
