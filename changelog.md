# <> Release 2.10 - Settings.ahk, KSA.ahk & HotkeyReplacer.ahk
###### This release contains a lot of underlying refactoring that completely changes large chunks of the codebase.

- Added a new class `Settings.ahk` that takes complete control over all interactions with `settings.ini`
    - Handles creating `settings.ini` if it doesn't exist yet
    - Moved `createIni()` into `Settings.ahk`

- `Keyboard Shortcut Adjustmenst.ahk` is now a self contained class that automatically generates variables based on `KSA.ini`
    - Will now alert the user of duplicates
    - `=` can no longer be used as a hotkey within `KSA.ini`

- `HotkeyReplacer.ahk` is now a self contained class that takes advantages of `Maps` to quickly and easily find and replace the user's custom values
    - Has complete feature parity while only needing a fraction of the code
    
## > Functions
- `activeScripts()` can now be called by right clicking on `My Scripts.ahk` in the tray menu
- `prem.preset("loremipsum")` now checks for images multiple times to avoid erroring out earlier than necessary 
- Add `runcmd()` as a wrapper function to quickly send a command to the command line
    - Added Streamdeck scripts `ffmpeg.ahk` & `yt-dlp.ahk` to check for updates for both utilities
- Moved `getcmd()` out of `Extract.ahk` and into its own function file

`dark.allButtons()`
- Fix function failing to enumerate passed the first button
- Can now pass an object to customise the background colours of the GUI/GUI buttons

`tool.Cust()`
- Fix function throwing an error if a `float` is passed to the `x or y` parameters
- Fix function throwing an error if a number is passed in to the first parameter

`monitorAlert()`
- Fix not using `ptf` values
- Fix function going ahead if script is reloaded while the alert MsgBox is active

## > Other Changes
- Fix `checklist.ahk` defaulting to expanded UI
- Fix some duplicate values in `KSA.ini`
- `MyRelease` is no longer a global variable defined in `My Scripts.ahk`
    - `Startup {` now gets initiated instead of using purely static functions so that it can share `MyRelease` and only assign it a value once
- `Multi-Instnce Close.ahk` now ignores all scripts in `..\lib\Multi-Instance Close\ignoreList.ahk`
- Streamdeck `download` scripts now use `#SingleInstance Off` to allow multiple downloads at the same time

`autosave.ahk1
- Fix script throwing if `After Effects` is opened while timer is running
- Fix script throwing if `After Effects` is in the background and a save is no longer required