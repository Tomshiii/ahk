# <> Release 2.14.x -

## Functions
- Fixed `rbuttonPrem().movePlayhead()` not properly detecting when Premiere is no longer the active window
- Fixed `premUIA_Values {` causing some inputs to get stuck

`settingsGUI()`
- Added Toggles;
    - `Check for AHK Updates` & `Check for Library Updates`
    - `getTimeline() Always Check UIA` & `Limit Daily`
        - Allows the user to determine whether they *always* want to refresh UIA values & whether to limit that check
- Fixed some text overlapping with the `Adjust` edit boxes
- Fixed `values.json` using ahk style formatting instead of json style formatting resulting in newlines not rendering and <kbd>`</kbd> being represented twice

`prem {`
- Fixed `__remoteFunc()` not passing back if it was successful which caused `autosave.ahk` to always fall back to the previous save method causing double saves
- Added more images so `reset()` will fail less on `Spectrum UI`