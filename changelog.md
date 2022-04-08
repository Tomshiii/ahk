# <> Release 2.3.2.3

## > Functions
- Small adjustment to the formatting of system information in `errorLog()`
- Updated `collapse.png` for `vscode()`

## > My Scripts
- Clipboard macros (`^+c` & `SC03A & c`) now store the original value of the clipboard, then returns it at the end of the macro
- Adjusted recent `F{key}` changes as they were conflicting with other hotkeys
- Added new hotkeys to manipulate playback within Premiere's timline using just the mouse
- Removed `catch {}`'s from `adobeTemp()` as it was stopping the script from finishing

## > Other Changes
- Added `convert mkv2mp3.ahk`
- `autosave.ahk` will now reload itself if you have it paused but then close Premiere to stop the reminder message from appearing when it isn't required
- Updated `ImageSearches` for `disc()` as discord slightly changed the look of their buttons