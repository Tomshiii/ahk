# <> Release 2.10.x - 
- Fix install process potentially not generating a `settings.ini` file if one does not already exist

## > Functions
- Fix `prem.audioDrag()` from `inserting` clip by pressing <kbd>Ctrl</kbd> before the clip has finished being placed
- Add `tool.tray()`
    - `convert2()`, `ytDownload()` & `Move Project.ahk` now use `tool.tray()` to alert the user that their process has completed

`tool.cust()`
- `find` parameter has been removed
- Cleaned up function

## > Other Changes
- Added `prem(previous/next)Keyframe` hotkeys to `My Scripts.ahk`/`KSA.ini`
- Cleaned up `Move project.ahk`