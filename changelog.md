# <> Release 2.12.x - 

## > Functions
- Added `coord.reset()`
- Fixed `getHTMLTitle()` throwing if link provided doesn't have html tags the function is looking for
- Fixed `switchTo.adobeProject()` not focusing the correct explorer window if parameter `optionalPath` was used
- Fixed a few calls to `obj.imgSrchMulti()` in `Prem {` missing a parameter
- Attempt to fix `WinGet.isProc()` throwing if it attempts to check a window that isn't responding
- Replying to a message with `discord.button()` now disables the `@ON` ping by holding <kbd>Shift</kbd> instead of searching for the `@ON` text.
    - Can now be disabled by setting the internal class variable `disableAutoReplyPing` to `false`
- `ffmpeg.trim()` now offers optional parameter `runDir` to define whether the dir of the chosen file will be run after the function has executed
- `obj.SplitPath()` will now include OwnProp `Path` containing the path that was passed into it
- `yt-dlp {` will no longer produce a traytip saying `ffmpeg`. Oops!
- Minor logic changes to `prem.__waitForTimeline()` in an attempt to stop it getting stuck in an extended loop waiting for the timeline to be brought into focus

## > Other Changes
- Added additional backups for `VSCode`; `settings.json` & `keybindings.json`
- Added `reencodeGUI.ahk` & `reencode.ahk`
- Fixed `Alt_menu_acceleration_DISABLER.ahk` not `#Include`(ing) `errorLog {`
- Fixed some `QMK` (`Prem.ahk`) scripts incorrectly trying to focus the timeline
- A tooltip will now be presented at the bottom of the screen while `Startup` functions are running
- `textreplace.ahk` (using `quickHotstring()`) will now automatically place new additions into the correctly sorted position