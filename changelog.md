# <> Release 2.12 - New autosave.ahk
- `autosave.ahk` has been rewritten from the ground up to follow cleaner code patterns allowing for easier expandability, easier debugging and allowing the script to do what it's designed to do and not encounter issue after issue as more and more responsibilities got attached to the one script.  
The purpose of this update is to smooth out the experience of using the script and allow it to do what it was always supposed to do; do it's thing in the background without interupting the user.
> This currently means that `autosave.ahk` will lose the ability to automatically open `checklist.ahk` (as it shouldn't have ever been its responsibility anyway) & will no longer show a countdown until the next automatic save. The removal of these features has been done after careful consideration to ensure that it doesn't end up in the same pit as before and remains clean and easily maintainable.

- Alongside `autosave.ahk` I am also slowly transitioning my `Premiere Pro/After Effects` workflow over to `v23.5` and beyond. Code added from this release forward is no longer guaranteed to work on versions `v22.3.1(prem)/v22.6(ae)` as testing will now be conducted on newer releases of the program(s). There shouldn't be much in the way of inconsistencies for the foreseeable future but this is the offical cutoff point.

## > Functions
- `winget.PremName/AEName()` now returns `-1` on failure instead of `unset`

`Premiere_RightClick()`
- Fix script stalling if the user attempts to right click anywhere other than the timeline while its coordinates haven't been set
- `checkStuck()` taken out and separated into its own function file

`prem {`
- Fixed `gain()` getting stuck if used multiple times in a row
    - Will also now double check to ensure audio is selected before attempting to open the gain window
- Fixed `getTimeline()` stalling when it encounters an issue
- Added `numpadGain()` which allows `gain()` to quickly be called by pressing <kbd>NumpadSub/NumpadAdd</kbd> followed by any of the <kbd>Numpad</kbd> buttons
- `__checkTimelineFocus()` is now static

## > Other Changes
- Added `render and replace.ahk`