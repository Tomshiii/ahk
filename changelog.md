# <> Release 2.11 - adobeKSA.ahk
- Fix install process potentially not generating a `settings.ini` file if one does not already exist
- Further fix settings changes not sticking when adjusted in `settingsGUI()`

## > Functions
- Fix `prem.audioDrag()` from `inserting` clip - caused by pressing <kbd>Ctrl</kbd> before the clip has finished being placed
- Fix `prem.getTimeline()` from retrieving the incorrect coordinates if a second window is in focus when called
- Fix `startup.updateChecker()` treating `alpha` updates as full releases
    - Change `beta` verbage to `Pre-Releases`
- Add `tool.tray()`
    - `convert2()`, `ytDownload()` & `Move Project.ahk` now use `tool.tray()` to alert the user that their process has completed
- `prem.zoom()` cancel hotkey changed to <kbd>Esc</kbd> instead of <kbd>F5</kbd>

`tool.cust()`
- `find` parameter has been removed
- Cleaned up function

## > Other Changes
- Fix `waitUntil.ahk` throwing
- Added `prem(previous/next)Keyframe` hotkeys to `My Scripts.ahk`/`KSA.ini`
- Cleaned up `Move project.ahk`