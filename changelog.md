# <> Release 2.12.x - 
`autosave.ahk` & `adobe fullscreen check.ahk` will now attempt to check if `Premiere_RightClick.ahk` is currently active before proceeding with their functions in an attempt to mitigate unexpected behaviour that arises when multiple scripts clash against each other.

## > Functions
- Added `coord.reset()`
- Added `multiKeyPress()`
- Fixed `getHTMLTitle()` throwing if link provided doesn't have html tags the function is looking for
- Fixed `switchTo.adobeProject()` not focusing the correct explorer window if parameter `optionalPath` was used
- Replying to a message with `discord.button()` now disables the `@ON` ping by holding <kbd>Shift</kbd> instead of searching for the `@ON` text.
    - Can now be disabled by setting the internal class variable `disableAutoReplyPing` to `false`
- `ffmpeg.trim()` now offers optional parameter `runDir` to define whether the dir of the chosen file will be run after the function has executed
- `obj.SplitPath()` will now include OwnProp `Path` containing the path that was passed into it
- `yt-dlp {` will no longer produce a traytip saying `ffmpeg`. Oops!
- `switchTo.Music()` will no longer accept a window with no title as a window
- Year selector within `Premiere` & `After Effects` GUI (`settingsGUI()`) is now a `DropDownList` instead of an `Edit` control

`WinGet {`
- Added `pathU()`
- Attempt to fix `WinGet.isProc()` throwing if it attempts to check a window that isn't responding

`Prem {`
- Moved `__parseMessageResponse()` & `__recieveMessage()` => `WM {`
- Fixed a few calls to `obj.imgSrchMulti()` missing a parameter
- Fixed `prem.thumbScroll()` spam activating if code hits a premptive end
- Minor logic changes to `prem.__waitForTimeline()` in an attempt to stop it getting stuck in an extended loop waiting for the timeline to be brought into focus

## > Other Changes
- Added additional backups for `VSCode`; `settings.json` & `keybindings.json`
- Added `reencodeGUI.ahk` & `reencode.ahk`
- Fixed `Alt_menu_acceleration_DISABLER.ahk` not `#Include`(ing) `errorLog {`
- Fixed some `QMK` (`Prem.ahk`) scripts incorrectly trying to focus the timeline
- A tooltip will now be presented at the bottom of the screen while `Startup {` functions are running to alert the user to what is currently happening
- `textreplace.ahk` (using `quickHotstring()`) will now automatically place new additions into the correctly sorted position
- Menu item added to `My Scripts.ahk` to quickly open `UIA.ahk`