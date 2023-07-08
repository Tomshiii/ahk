# <> Release 2.12 - New autosave.ahk
`autosave.ahk` has been rewritten from the ground up to follow cleaner code patterns allowing for easier expandability, easier debugging and allowing the script to do what it was originally designed to do while not encountering issue after issue as more and more responsibilities got attached to the one script.  
The purpose of this update is to smooth out the experience of using the script and allow it to do what it was always supposed to do; do it's thing in the background without interupting the user with countless unrecoverable errors.
> This currently means that `autosave.ahk` will lose the ability to automatically open `checklist.ahk` (as it shouldn't have ever been its responsibility anyway) & will no longer offer a countdown until the next automatic save. The removal of these features has been done after careful consideration to ensure that it doesn't end up in the same pit as before and remains clean and easily maintainable.
>> The settings for these features have currently been disabled within `settingsGUI()` while I decide whether I wish to bring them back in some capacity.

Alongside `autosave.ahk` I am also slowly transitioning my `Premiere Pro/After Effects` workflow over to `v23.5` and beyond.
- Code added from this release forward is no longer guaranteed to work on versions `v22.3.1(prem)/v22.6(ae)` as testing will now be conducted on newer releases of the program(s). *There shouldn't be much in the way of inconsistencies for the foreseeable future (as almost everything so far has worked in both versions fine) but this is the offical cutoff point.*

## > Functions
- Fixed `gamCheckGUI {` failing to produce `Msgbox` to alert the user a game has already been added to the list when the GUI is called from the tray menu.
- `switchTo.Explorer()` now includes `"ahk_class OperationStatusWindow"`

`WinGet`
- `PremName()/AEName()` now returns `-1` on failure instead of `unset`
- `title()` now has parameter `exitOut` to determine whether the user wishes for the active thread to exit if the function cannot determine the title. Defaults to `true`

`Premiere_RightClick.ahk`
- Fix script stalling if the user attempts to right click anywhere other than the timeline while its coordinates haven't been set
- `checkStuck()` taken out and separated into its own function file

`prem {`
- Fixed `gain()` getting stuck if used multiple times in a row
    - Will also now double check to ensure audio is selected before attempting to open the gain window
- Fixed `getTimeline()` stalling when it encounters an issue
- Added `numpadGain()` which allows `gain()` to quickly be called by pressing <kbd>NumpadSub/NumpadAdd</kbd> followed by any of the <kbd>Numpad</kbd> buttons
- `__checkTimelineFocus()` is now static
- `zoom()`
    - Fixed function cycling through timeline sequences if multiple are open
    - Preset zooms can now accept an array length of `5` to include the `Anchor Point` coordinates

## > Other Changes
- Added `render and replace.ahk`
- `adobe fullscreen check.ahk` will now work on any version of `Premiere Pro`/`After Effects` and no longer requires the correct year to be set within `settingsGUI()`
- Refactored the following timer scripts;
    - `adobe fullscreen check.ahk`
    - `autodismiss error.ahk`
    - `premKeyCheck.ahk`

`Logs`
- Added the class `log {` to allow for easier logging without the need for an `Error Object`
- `errorLog()` refactored into a `class` (that extends off `log {`) for cleaner code and easier expandability

> These changes do not break prior functionality of `errorLog()` and the only change necessary from a user perspective is adjusting the `#Include` location if used in any custom scripts.