# <> Release 2.5.3 - gameCheck.ahk
This release brings along `gameCheck.ahk` that will automatically detect when a predetermined game is currently active and suspend `My Scripts.ahk`. This is important because `My Scripts.ahk` contains a bunch of macros that really don't play nice to games and cause a lot of basic functionality in them to break. This script will also detect when the game is no longer the active window and unsuspend `My Scripts.ahk`. Games may be periodically added to this script but feel welcome to add your own list!

## > My Scripts
- Changed `F14::` `show more options` hotkey -> `F18` due to it causing issues with `F14 & WheelDown\WheelUp::`

## > Functions
- Added `floorDecimal()` to round down after a determined amount of decimal places
- Add `blockOff()` to `getTitle()` and `isFullscreen()` so that in the event they fail, the user is not potentially stuck
- More colours for `audioDrag()`
- `zoom()` sets it's variable presets in an array to remove the need for multiple variables
- Fixed hard coded dir in `switchToDisc()`
- Added a check in `musicGUI()` to make sure to music folder actually exists
- `switchToAE()` contains more elaborate code to be able to open the `.aep` file for the current project even once AE is already open
- `activeScripts()` now starts a timer to check the suspended state of `My Scripts.ahk` to update the checkbox value

`settingsGUI()`
- Minor GUI tweaks
- Fixed bug that caused function to error if non numeric values were entered into the edit boxes
- Now has an option to globally enable/disable reminder tooltips for `checklist.ahk`
- Moved `Current working dir:` to the status bar
    - Status bar now also shows whether `My Scripts.ahk` is active or suspended
- Ability to add game information to `gameCheck.ahk`

## > Other Changes
- Adjusted positioning of tray menu items for `My Scripts.ahk` & `autosave.ahk`
- Added `commLocation :=` to `Keyboard Shortcut Adjustments` for the user to manually input their own commission working dir (if they have one) so my scripts don't need to be hard coded with my own variable
    - `QMK Keyboard.ahk` `h::` now attempts to open `commLocation` if there is no Adobe project open

`replaceChecklist.ahk`
- Will now ignore backup folders
- Fixed bug causing "Yes to All" to not function correctly
- Fixed typo causing this script to create a different `\backup` folder than `checklist.ahk`

`checklist.ahk`
- Fixed `H:` number getting cut off when above 10 hours
- Moved all functions to the bottom of the script to increase readability
- Now uses `floorDecimal()` for the `Hour` text so it ticks over more accurately
- Added menu bar to:
    - Open other checklists
    - Toggle tooltips for the current project (if global `checklist.ahk` tooltips are enabled)
    - Display `About` informational GUI
    - Open the github repo
    - Show hours worked today, days worked & avg hours worked per day
    - Check for updates on both the stable and beta paths
- Version number moved to `About` menu bar GUI