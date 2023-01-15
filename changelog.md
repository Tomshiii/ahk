# <> Release 2.10 - Settings.ahk 
- Added a new class `Settings.ahk` that takes complete control over all interactions with `settings.ini`
    - Handles creating `settings.ini` if it doesn't exist yet
    
## > Functions
- `activeScripts()` can now be called by right clicking on `My Scripts.ahk` in the tray menu

`monitorAlert()`
- Fix not using `ptf` values
- Fix function going ahead if script is reloaded while the alert MsgBox is active

## > Other Changes
- Fix `checklist.ahk` defaulting to expanded UI
- `MyRelease` is no longer a global variable defined in `My Scripts.ahk`