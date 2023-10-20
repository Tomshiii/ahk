# <> Release 2.12.x - 
- `Keyboard Shortcuts.ini` has been moved from `..\lib\KSA\` => `..\Support Files\KSA\`
    - This should allow the user to more easily, manually update their entire `..\lib\` folder without worrying about `KSA.ini` getting wiped in the process
> ##### *It should be noted that this change does not protect the user in the event that a new `KSA` variable is added. It will need to be manually added back by the user or they will have to go through the usual update steps.*

## > Functions
- Removed references to `7zip.ahk` from `startup.libUpdateCheck()` as the script has been pulled by `thqby`
- `rbuttonPrem().movePlayhead()` now accepts optional param `allChecks` and allows the user to call `movePlayhead()` even if the cursor is hovering over a video/audio track
- `checkStuck()` now accepts optional param `arr` to pass in a custom array of buttons to check
- `errorLog()` will now check for, and strip the `err.what` string of the passed in error object of the word `Prototype.` to make resulting logs easier to read
- Code taken from `settingsGUI()` to add `generateAdobeShortcut()`
- `adobeTemp()` will no longer run if `Premiere` or `After Effects` is currently open
- `getHTML()` will now check the resulting string for error messages
- `mouseDrag()` will now delay slightly between inputs to reduce the number of times the function is too fast for the desired input

`switchTo`
- `Premiere()` & `AE()` will now;
    - Check for the existence of `Creative Cloud` and attempt to open it before proceeding
        - Both functions now also accept parameter `openCC` to determine if this behaviour is desired. It is set to `true` by default
    - Attempt to generate a shortcut (using values set within `settingsGUI()`) if one isn't detected

## > Other Changes
- `autosave.ahk` will no longer backup project files when the user manually saves with <kbd>Ctrl + s</kbd> to help mitigate the backup folders inflating to giant sizes during long projects
- Added `v24` Premiere template
- Added `nameof.ahk` by `thqby`
- Fixed `Move Project.ahk` throwing when it attempts to delete a `Backups` folder