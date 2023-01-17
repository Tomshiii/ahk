# <> Release 2.10 - Settings.ahk 
- Added a new class `Settings.ahk` that takes complete control over all interactions with `settings.ini`
    - Handles creating `settings.ini` if it doesn't exist yet
    - Moved `createIni()` into `Settings.ahk`
    
## > Functions
- Fix `tool.Cust()` throwing an error if a `float` is passed to the `x or y` parameters
- `activeScripts()` can now be called by right clicking on `My Scripts.ahk` in the tray menu
- Cleaned up `move {`

`monitorAlert()`
- Fix not using `ptf` values
- Fix function going ahead if script is reloaded while the alert MsgBox is active

## > Other Changes
- Fix `checklist.ahk` defaulting to expanded UI
- Fix some duplicate values in `KSA.ini`
- `MyRelease` is no longer a global variable defined in `My Scripts.ahk`
    - `Startup {` now gets initiated instead of using purely static functions so that it can share `MyRelease` and only assign it a value once