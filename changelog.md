# <> Release 2.10 - Settings.ahk, KSA.ahk & HotkeyReplacer.ahk
###### This release contains a lot of underlying refactoring that completely changes large chunks of the codebase.

- Added a new class `Settings.ahk` (#12) that takes complete control over all interactions with `settings.ini`
    - Handles creating `settings.ini` if it doesn't exist yet
    - Moved `createIni()` into `Settings.ahk`

- `Keyboard Shortcut Adjustmenst.ahk` (#13) is now a self contained class that automatically generates variables based on `KSA.ini`
    - Will now alert the user of duplicates
    - `=` can no longer be used as a hotkey within `KSA.ini`

- `HotkeyReplacer.ahk` is now a self contained class (#14) that takes advantages of `Maps` to quickly and easily find and replace the user's custom values
    - Has complete feature parity while only needing a fraction of the code
    - Will now only run after a symlink has been properly generated
    
## > Functions
- Fix `errorLog()` not logging the current date
- `activeScripts()` can now be called by right clicking on `My Scripts.ahk` in the tray menu
- `prem.preset("loremipsum")` now checks for images multiple times to avoid erroring out earlier than necessary 
- Add `runcmd()` as a wrapper function to quickly send a command to the command line
    - Added Streamdeck scripts `ffmpeg.ahk` & `yt-dlp.ahk` to check for updates for both utilities
- Moved `getcmd()` out of `Extract.ahk` and into its own function file
- `switchTo.AE()` & `New Premiere.ahk` now specifically run the shortcuts for their respective programs found in `..\Support Files\shortcuts\` instead of defaulting to the latest version of either program
- `dark.allButtons()` can now pass an object to customise the background colours of the GUI/GUI buttons
- Changing `Adobe Premiere/Adobe After Effects` versions within `settingsGUI()` will now automatically generate new shortcuts within `..\Support Files\shortcuts\` to the selected version of the desired program

`tool.Cust()`
- Fix function throwing an error if a `float` is passed to the `x or y` parameters
- Fix function throwing an error if a number is passed in to the first parameter

`monitorAlert()`
- Fix not using `ptf` values
- Fix function going ahead if script is reloaded while the alert MsgBox is active

## > Other Changes
- Add `pcTimerShutdown.ahk` to provide a quick and easy GUI to shutdown your PC after any amount of time up to a max of `9999 hours`
- Fix `checklist.ahk` defaulting to expanded UI
- Fix some duplicate values in `KSA.ini`
- Fix `checklist.ahk` hour value getting cut off
- `MyRelease` is no longer a global variable defined in `My Scripts.ahk`
    - `Startup {` now gets initiated instead of using purely static functions so that it can share `MyRelease` and only assign it a value once
- `Multi-Instnce Close.ahk` now ignores all scripts in `..\lib\Multi-Instance Close\ignoreList.ahk`
- Streamdeck `download` scripts now use `#SingleInstance Off` to allow multiple downloads at the same time
- `allKeyUp()` and `reload_reset_exit("exit")` can now be called by right clicking on `My Scripts.ahk`'s tray icon


`autosave.ahk`
- Fix script throwing if `After Effects` is opened while timer is running
- Fix script throwing if `After Effects` is in the background and a save is no longer required