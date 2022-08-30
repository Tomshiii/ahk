# <> Release 2.5.2 - Fixes & Features

## > Functions
- Added `aetimeline()` a more beefed up version of `timeline()` to be more flexible
- Fixed `verCheck()`
- Fixed `manInput()` erroring out if `optional` variable wasn't assigned a value
- `adobeTemp()` now sets it's `largestSize` variable in `settings.ini` & `settingsGUI()`
- UI changes to `settingsGUI()`
- `getTitle()` will no longer throw an error if the title cannot be found (ie. Windows taskbar/desktop)
- `generate()` `WORK` variable now defaults to my working dir - this fixes `locationReplace()` not firing if no `settings.ini` file exists

`audioDrag()`
- Add more colours
- Changed `bleep` tooltip to make it more obvious which track you're about to drag to

`getHotkeys()`
- If the activation hotkey length is only `2`, `&first` & `&second` will be assigned to the first and second characters respectively
    - If one of those characters is a special key (ie. ! or ^) it will return the virtual key instead so `KeyWait` will still work as expected

`vscode()`
- Will now send a hotkey to collapse the explorer tree instead of searching for and clicking the collapse button. The collapse button changes depending on how wide your toolbar is and constantly breaks if you accidentally change the size even slightly
    - Will check to see if the user has the first repo expanded already -> if they do it will check to see if any explorer trees are expanded -> If there are it will send the collapse hotkey once before moving on, otherwise it will skip ahead and just move straight along
- Replaced `KeyWait(A_PriorKey)` with `getHotkeys()`

`moveTab()`
- Will now attempt to reactivate the originally active tab
- Will now check to make sure the cursor isn't attempting to resize the window before dragging the tab. (helpful if the window isn't fullscreen)
- Will now move the cursor back to the original coords if function is activated from main monitor

## > My Scripts
- `Media_Play_Pause::` for firefox will now send `{Media_Play_Pause}` if you're on the subscriptions/home page
- `#c::` will now centre the window in the current active monitor or move it to the main monitor if activated again
- `#F1:: - activeScripts()` changed -> `#F2::`
    - `#F1::` now pulls up `settingsGUI()`
- `autosave.ahk` `minutes` variable (how often it saves) is now adjustable in `settings.ini/settingsGUI()`

## > Other Changes
- Changed `premiere_fullscreen_check` -> `adobe fullscreen check.ahk`
    - `fire_frequency` (how often it checks) now adjustable in `settings.ini/settingsGUI()`
    - Can now check After Effects as well
    - Now uses `isFullscreen()` instead of hard coded values
    - Adjusted `vscode()` values in `My Scripts.ahk` to accommodate this change
- `right click premiere.ahk` now checks if `Ctrl` is being pressed.
    - Pressing `Ctrl + \` is what causes premiere to freak out and enter the weird state that I created `adobe fullscreen check.ahk` for. Adding checks in this script will dramatically decrease the need for that script.

`checklist.ahk`
- Will now show `Seconds`
- Minutes shown will now be the amount of minutes into the hour instead of total minutes. Hours shown will still be rounded to 2dp however
- Will no longer error if you open `checklist.ahk` in a new year
- Small UI adjustments
    - `H/M/S` now aligned horizontally
    - Checkboxes are more compact