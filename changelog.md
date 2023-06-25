# <> Release 2.11.x - New autosave.ahk
`autosave.ahk` has been rewritten from the ground up to follow cleaner code patterns allowing for easier expandability, easier debugging and allowing the script to do what it's designed to do and not encounter issue after issue as more and more responsibilities got attached to the one script.

## > Functions
- `checkStuck()` taken from `Premiere_RightClick()` and separated into its own function file
- `winget.PremName/AEName()` now returns `-1` on failure instead of `unset`

`prem {`
- Fixed `gain()` getting stuck if used multiple times in a row
    - Will also now double check to ensure audio is selected before attempting to open the gain window
- Fixed `getTimeline()` stalling when it encounters an issue
- `__checkTimelineFocus()` is now static

## > Other Changes
- `prem.gain()` can now be called quickly by pressing any of the <kbd>Numpad</kbd> buttons
    - <kbd>NumpadSub</kbd> can be pressed before any input to remove the selected number instead of adding