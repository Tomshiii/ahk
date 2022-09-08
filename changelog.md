# <> Release 2.5.x

## > Functions
- Added `floorDecimal()` to round down after a determined amount of decimal places

## > Other Changes
- `replaceChecklist.ahk` will now ignore backup folders

`checklist.ahk`
- Now uses `floorDecimal()` for the `Hour` text so it ticks over more accurately
- Added menu bar to:
    - Open other checklists
    - Display `About` informational GUI
- Version display moved to `About` menu bar GUI