# <> Release 2.3.2.3

## > Resolve_Example
- Added functionality similar to `right click premiere.ahk`
- `rgain()` now middle clicks the timeline after adjusting the value to remove focus from the gain input box

`rflip()`
- Updated `inspector2.png`
- Now ensures the inspector window is open

## > Functions
- Small adjustment to the formatting of system information in `errorLog()`
- Updated `collapse.png` for `vscode()`

## > My Scripts
- Clipboard macros (`^+c` & `SC03A & c`) now store the original value of the clipboard, then returns it at the end of the macro
- Adjusted recent `F{key}` changes as they were conflicting with other hotkeys
- Added new hotkeys to manipulate playback within Premiere's timline using just the mouse

`adobeTemp()`
- Removed `catch {}`'s as it was stopping the function from finishing
- Now produces a tooltip when it runs to show how large your cache files total to

## > Other Changes
- Added `convert mkv2mp3.ahk`
- `autosave.ahk` will now reload itself if you have it "paused" but then close Premiere to stop the reminder message from appearing when it isn't required
- Updated `ImageSearch` images for `disc()` as discord slightly changed the look of their buttons
- Fixed incorrect link in `readme.md`
- Fixed `tiktok project.ahk` still containing old path
    - Updated all images for newer version of Premiere Pro