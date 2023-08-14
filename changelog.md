# <> Release 2.12.x - 

## > Functions
- Added `coord.reset()`
- Fixed `getHTMLTitle()` throwing if link provided doesn't have html tags the function is looking for
- Attempt to fix `WinGet.isProc()` throwing if it attempts to check a window that isn't responding
- Replying to a message with `discord.button()` now disables the `@ON` ping by holding <kbd>Shift</kbd> instead of searching for the `@ON` text.
    - Can now be disabled by setting the internal class variable `disableAutoReplyPing` to `false`

## > Other Changes
- Added additional backups for `VSCode`; `settings.json` & `keybindings.json`
- A tooltip will now be presented at the bottom of the screen while `Startup` functions are running
- Fixed `Alt_menu_acceleration_DISABLER.ahk` not `#Include`(ing) `errorLog {`