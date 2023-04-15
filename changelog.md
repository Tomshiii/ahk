# <> Release 2.11 - adobeKSA.ahk
- Added `adobeKSA.ahk` to parse through a user's `Premiere`/`After Effects` keyboard shortcut file & automatically assign those values to their respective `KSA.ini` values
- Fix install process potentially not generating a `settings.ini` file if one does not already exist
- Fix install process potentially throwing during the extraction stage if the user doesn't already have symlinks properly generated
- Further fix settings changes not sticking when adjusted in `settingsGUI()`
- Refactored `gameCheckGUI()` to better make use of the fact that it's a class

## > Functions
- Fix `prem.audioDrag()` from `inserting` clip - caused by function pressing <kbd>Ctrl</kbd> before the clip has finished being placed
- Fix `prem.getTimeline()` from retrieving the incorrect coordinates if a second window is in focus when called
- Add `tool.tray()`
    - `convert2()`, `ytDownload()` & `Move Project.ahk` now use `tool.tray()` to alert the user that their process has completed
- `prem.zoom()` cancel hotkey changed from <kbd>F5</kbd> to <kbd>Esc</kbd> 
- `settingsGUI()`checkbox verbage change `autosave.ahk check for checklist.ahk` => `Auto open checklist.ahk`

`tomshiBasic {`
- Now extends the default `gui.show()` method to automatically make all defined buttons `dark mode` if the setting is enabled
    - Can also pass an object containing the options you'd normally pass to `dark.allButtons()`
- Now automatically makes menu drop down windows dark mode if setting is enabled

`startup {`
- Fix `updateChecker()` treating `alpha` updates as full releases
    - Change `beta` verbage => `Pre-Releases`
    - Fix the `new release GUI` not updating settings values
- Fix `firstCheck()` not updating settings properly and continuously opening
    - Fixed bug causing window to remain `disabled` after opening & closing `settingsGUI()`
- Fix `discord.button()` searching in the incorrect position for the `@ON` ping
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
- Added option to call `Hard Reset` (`reload_reset_exit("reset")`) from the `Tray Menu`

`Moved:`
- `centreHotkey::` => `move.winCenter()`
- `discdmHotkey::` => `discord.DMs()`
- `prem^DeleteHotkey::` => `prem.wordBackspace()`
- `premselecttoolHotkey::` => `prem.selectionTool()`
- `12forward/BackHotkey(s)::` => `prem.moveKeyframes()`
- `alwaysontopHotkey::` => `alwaysOnTop()`
- `searchgoogleHotkey::` => `clip.search()`
- `capitaliseHotkey::` => `clip.capitilise()`

`Removed:`
- `premprojectHotkey::`
- `pinfirefoxHotkey::`
- `showmoreHotkey::`
- A few old, unused, unmarked hotkeys

## > Other Changes
- Fix `waitUntil.ahk` throwing
- Fix `New Premiere.ahk` not including `switchTo {`
- Added `trim {` to facilitate the creation of `trim(Audio/Video).ahk` to quickly and easily trim an audio/video file using ffmpeg
- Adjusted `ffmpeg` command for `convert(mkv/mov)2mp4.ahk` for slightly better performance
- Cleaned up `Move project.ahk`
- `New Premiere.ahk` will now prompt the user to select the desired template if multiple are found in the template folder
- `settingsGUI()` can now be called from the `checklist.ahk` menubar

`tiktok project.ahk`
- Fix `gui.ctrl` being passed to `InStr` causing it to throw
- Edit boxes will now be prioritised as long as soon as they're focused instead of only on change
- Set `select` button as the default input