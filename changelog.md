# <> Release 2.5.x

## > Functions
- Added `aetimeline()` a more beefed up version of `timeline()` to be more flexible
- Fixed `verCheck()`
- Fixed `manInput()` erroring out if `optional` variable wasn't assigned a value
- `adobeTemp()` now sets it's `largestSize` variable in `settings.ini` & `settingsGUI()`
- UI changes to `settingsGUI()`
- `getTitle()` will no longer throw an error if the title cannot be found (ie. Windows taskbar/desktop)

`moveTab()`
- Will now attempt to reactivate the originally active tab
- Will now check to make sure the cursor isn't attempting to resize the window before dragging the tab. (helpful if the window isn't fullscreen)

## > My Scripts
- `Media_Play_Pause::` for firefox will now send `{Media_Play_Pause}` if you're on the subscriptions/home page
- `#c::` will now centre the window in the current active monitor or move it to the main monitor if activated again

## > Other Changes
- Changed `premiere_fullscreen_check` -> `adobe fullscreen check.ahk`
    - `fire_frequency` now adjustable in `settings.ini/settingsGUI()`
    - Can now check After Effects as well
    - Now uses `isFullscreen()` instead of hard coded values
    - Adjusted `vscode()` values in `My Scripts.ahk` to accommodate this change
- `right click premiere.ahk` now checks if `Ctrl` is being pressed.
    - Pressing `Ctrl + \` is what causes premiere to freak out and enter the weird state that I created `adobe fullscreen check.ahk` for. Adding checks in this script will dramatically decrease the need for that script.
- Updated `collapse.png` for `vscode()`

`checklist.ahk`
- Will now show `Seconds`
- Minutes shown will now be the amount of minutes into the hour instead of total minutes. Hours shown will still be rounded to 2dp however
- Will no longer error if you open `checklist.ahk` in a new year
- Small UI adjustments
    - `H/M/S` now aligned horizontally
    - Checkboxes are more compact