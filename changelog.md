# <> Release 2.11 - adobeKSA.ahk
- Added `adobeKSA.ahk` to parse through a user's `Premiere` keyboard shortcut file & automatically assign values to `KSA.ini` values
- Fix install process potentially not generating a `settings.ini` file if one does not already exist
- Fix install process potentially throwing during the extraction stage if the user doesn't already have symlinks properly generated
- Further fix settings changes not sticking when adjusted in `settingsGUI()`
- Refactored `gameCheckGUI()` to better make use of the fact that it's a class

## > Functions
- Fix `prem.audioDrag()` from `inserting` clip - caused by pressing <kbd>Ctrl</kbd> before the clip has finished being placed
- Fix `prem.getTimeline()` from retrieving the incorrect coordinates if a second window is in focus when called
    - Change `beta` verbage => `Pre-Releases`
    - Fix the `new release GUI` not updating settings values
- Add `tool.tray()`
    - `convert2()`, `ytDownload()` & `Move Project.ahk` now use `tool.tray()` to alert the user that their process has completed
- `prem.zoom()` cancel hotkey changed to <kbd>Esc</kbd> instead of <kbd>F5</kbd>
- `tomshiBasic {` now extends the default `gui.show()` method to automatically make all defined buttons `dark mode` if the settings is enabled

`startup {`
- Fix `updateChecker()` treating `alpha` updates as full releases
- Fix `firstCheck()` not updating settings properly and continuously opening
    - Also fixed bug causing window to remain `disabled` after opening & closing `settingsGUI()`
- Removed `locationReplace()`
- Refactored `generate()` to no longer require manual definition of all possible settings options

`tool.cust()`
- Removed `find` parameter
- Passing `0` to `timout` will now stop the desired tooltip
    - Calling the same `WhichToolTip` will stop the previous instance, replacing it
- Cleaned up function

## > My Scripts
- Added `prem(previous/next)Keyframe` hotkeys to `My Scripts.ahk`/`KSA.ini`
- `alwaysontopHotkey::` now attempts to draw a border around the always on top window *(win11 only)*

`Removed:`
- `premprojectHotkey::`
- `pinfirefoxHotkey::`
- `showmoreHotkey::`

## > Other Changes
- Fix `waitUntil.ahk` throwing
- Fix `New Premiere.ahk` not including `switchTo {`
- Adjusted `ffmpeg` command for `convert (mkv/mov)2mp4.ahk` for slightly better performance
- Cleaned up `Move project.ahk`