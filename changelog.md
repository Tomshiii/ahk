# <> Release 2.9 - Huge Refactor
- Added `class timer {` to quickly and easily build more complex timer functionality

## > errorLog()
- No longer takes a `backupVar` for every parameter instead **_requiring_** an `Error Object` to be passed into the function
    - `backupFunc` is still a parameter
- Can now have an optional message that will appear on a new, tabbed line
- Can now automatically generate a `tool.Cust()` tooltip from the passed in error object
    - This parameter can have an object passed into it to generate a custom tooltip, or it will simply generate a default `tool.Cust()` tooltip that lasts `1.5s`
- Can now automatically `throw` with the passed in Error Object

## > settingsGUI()
- Editor settings can now be accessed as separate GUIs through the menubar
    - Removed the two edit controls to change prem/ae year from the main GUI
    - These GUI windows offer the opportunity in the future to potentially support more than just one version of AE/Prem

## > obj {
Added a new class `obj {` to maintain a collection of wrapper functions designed to take normal ahk functions and return their VarRefs as objects instead

- Added `obj.WinPos()`
- Added `obj.imgSrch()` using `checkImg()`
- Moved `SplitPathObj()` and renamed to `obj.SplitPath()`
    - Fixed all instances of scripts that use this function not having the proper `#Include`
- Moved `getMousePos()` and renamed to `obj.MousePos()`

## > coord {
- Added `coord.Client()` to set the pixel mode to `client`
- Expanded functionality of all functions to accept a parameter to adjust what they want to target

## > Functions
- Added `delaySI()` to send a string of `SendInput` commands spaced out with a custom delay
- Added `allKeyUp()` to attempt to unstick as many keys as possible by looping through `ScanCodes` & `Virtual Key Codes`
- `winget.AEName()` updated to have complete feature parity with `winget.PremName()`
- Removed `prem.num()` - it's old code that was superceeded by `prem.zoom()`
- `checkImg()` changed to support all normal ImageSearch `ImageFile options`

## > checklist.ahk
- Entire script has been refactored to make use of `class timer {`
    - `checklistTimer {`, `checklistLog {` & `checklistReminder {` have been created to extend off the base class
- `H:` float will now **always** show `3dp` even if the current hour value is a whole integer.
    > old: `H: 1.0 M: 0 S: 0` => new: `H: 1.000 M: 0 S: 0`
- Added functions `checkTooltips()` & `checkDark()` to return settings relating to both instead of cluttering the main script with code

## > Other Changes
- `tomshiBasic()` now creates a hidden button to force focus to it instead of the first user defined ctrl
- `adobe fullscreen check.ahk` now uses `timer {`
- QMK `open dir of current project` now uses `winget.AEName()/PremName()`