# <> Release 2.5.x

## > Functions
- Added `floorDecimal()` to round down after a determined amount of decimal places
- `settingsGUI()` now has an option to globally enable/disable reminder tooltips for `checklist.ahk`

## > Other Changes
`replaceChecklist.ahk`
- Will now ignore backup folders
- Fixed bug causing "Yes to All" to not function correctly
- Fixed typo causing this script to create a different `\backup` folder than `checklist.ahk`

`checklist.ahk`
- Moved all functions to the bottom of the script to increase readability
- Now uses `floorDecimal()` for the `Hour` text so it ticks over more accurately
- Added menu bar to:
    - Open other checklists
    - Toggle tooltips for the current project (if global `checklist.ahk` tooltips are enabled)
    - Display `About` informational GUI
    - Open the github repo
    - Check for updates on both the stable and beta paths
- Version number moved to `About` menu bar GUI