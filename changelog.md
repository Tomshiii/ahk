# <> Release 2.9 -

## > Functions
- Removed `prem.num()` - it's old code that was superceeded by `prem.zoom()`
- Added `class timer {` to quickly and easily build more complex timer functionality

## checklist.ahk
- Entire script has been refactored to make use of `class timer {`
    - `checklistTimer {`, `checklistLog {` & `checklistReminder {` have been created to extend off the base class
- `H:` float will now **always** show `3dp` even if the current hour value is a whole integer.
    > old: `H: 1.0 M: 0 S: 0` => new: `H: 1.000 M: 0 S: 0`
- Added functions `checkTooltips()` & `checkDark()` to return settings relating to both instead of cluttering the main script with code