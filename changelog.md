# <> Release 2.9 - Huge Refactor

## > errorLog()
- No longer takes a `backupVar` for every input instead requiring an `Error Object` to be passed into the function
    - `backupFunc` is still a parameter
- Can now have an optional message that will appear on a new, tabbed line
- Can now automatically generate a `tool.Cust()` tooltip from the passed in error object

## > settingsGUI()
- Editor settings can now be accessed as separate GUIs through the menubar
    - Removed the two edit controls to change prem/ae year from the main GUI

## > obj {
Added a new class `obj {` to maintain a collection of wrapper functions designed to take normal ahk functions and return their VarRefs as objects instead

- Added `obj.WinPos()`
- Moved `SplitPathObj()` and renamed to `obj.SplitPath()`
- Moved `getMousePos()` and ranamed to `obj.MousePos()`
- Fixed all instances of scripts not having the proper `#Include`

## > Functions
- Removed `prem.num()` - it's old code that was superceeded by `prem.zoom()`
- Added `class timer {` to quickly and easily build more complex timer functionality

## > checklist.ahk
- Entire script has been refactored to make use of `class timer {`
    - `checklistTimer {`, `checklistLog {` & `checklistReminder {` have been created to extend off the base class
- `H:` float will now **always** show `3dp` even if the current hour value is a whole integer.
    > old: `H: 1.0 M: 0 S: 0` => new: `H: 1.000 M: 0 S: 0`
- Added functions `checkTooltips()` & `checkDark()` to return settings relating to both instead of cluttering the main script with code

## > Other Changes
- `tomshiBasic()` now creates a hidden button to force focus to it instead of the first user defined ctrl