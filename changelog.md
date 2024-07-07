# <> Release 2.14.x -

## Functions
- Fixed `rbuttonPrem().movePlayhead()` not properly detecting when Premiere is no longer the active window

`settingsGUI()`
- Fixed some text overlapping with the `Adjust` edit boxes
- `Check for AHK Updates` & `Check for Library Updates` can now be toggled

`prem {`
- Fixed `__remoteFunc()` not passing back if it was successful which caused `autosave.ahk` to always fall back to the previous save method causing double saves
- Added more images so `reset()` will fail less on `Spectrum UI`