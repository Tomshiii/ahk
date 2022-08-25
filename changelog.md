# <> Release 2.5.x

## > Functions
- `moveTab()` will now attempt to reactivate the originally active tab
- Added `aetimeline()` a more beefed up version of `timeline()` to be more flexible
- Fixed `verCheck()`
- Fixed `manInput()` erroring out if `optional` variable wasn't assigned a value
- `adobeTemp()` now sets it's `largestSize` variable in `settings.ini` & `settingsGUI()`
- UI changes to `settingsGUI()`

## > My Scripts
- `Media_Play_Pause::` for firefox will now send `{Media_Play_Pause}` if you're on the subscriptions/home page

## > Other Changes
- Changed `premiere_fullscreen_check` -> `adobe fullscreen check.ahk`
    - Can now check After Effects as well
    - Now uses `isFullscreen()` instead of hard coded values
    - Adjusted `vscode()` values in `My Scripts.ahk` to accommodate this change
- `right click premiere.ahk` now checks for both the `Save Project` dialog box and if `Ctrl` is being pressed.
    - Pressing `Ctrl + \` is what causes premiere to freak out and enter the weird state that I created `adobe fullscreen check.ahk` for. Adding checks in this script will dramatically decrease the need for that script.
- Updated `collapse.png` for `vscode()`

`checklist.ahk`
- Will now show `Seconds`
- Will no longer error if you open `checklist.ahk` in a new year
- Small UI adjustments