# <> Release 2.11.x - New autosave.ahk
`autosave.ahk` has been rewritten from the ground up to follow cleaner code patterns allowing for easier expandability, easier debugging and allowing the script to do what it's designed to do and not encounter issue after issue as more and more responsibilities got attached to the one script.  
The purpose of this update is to smooth out the experience of using the script and allow it to do what it was always supposed to do; do it's thing in the background without interupting the user.

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