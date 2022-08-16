# <> Release 2.5.1 - HotkeyReplacer.ahk + KSA
With this release `HotkeyReplacer.ahk` will also replace `Keyboard Shortcuts.ini` entries with the users custom entries. This change allows for a more seamless move between versions for the user as no more manual tinkering is necessary to get up and running (unless you use `QMK Keyboard.ahk`. There are no plans to add `QMK Keyboard.ahk` to `HotkeyReplacer.ahk` not only due to it being so highly specific to the keyboard layout of the user but also just because most things in that script should be functions anyway).

# > Functions
- `discUnread()` now shows the proper tooltip depending on if it can't find any servers/channels
- Add default values to `valuehold()` and `manInput()`
- Updated `collapse.png` for `vscode()`

`audioDrag()`
- Will now always send an `errorLog()` if the right colour was found instead of only loops `2/3`
- Added more colours

`moveTab()` 
- Will now set the `monitor` variable to one of the two I wish to cycle between if the function is activated on a monitor that isn't included in the cycle
- Fixed a bug that would cause the function to cycle endlessly
- Fixed a bug that would cause a tab to sometimes not join another browser window
- Changed `MouseMove()` speed from `3 -> 2`

`toolCust()`
- `timeout` variable will now default to `1000 (1s)` and may be omitted
    - All `timeout` variables still containing `""` have been swapped for just integers

# > My Scripts
`SC03A & c::`
- Will now attempt to determine whether to capitilise or completely lowercase the highlighted text depending on which is more frequent
- Fixed a bug that caused the hotkey to ignore any text in quotation marks
- Removed `SC03A & v::` as it is now redundant
- Will now prompt the user if the highlighted string is too long before continuing

# > QMK Keyboard
- Fixed `p::`
- Moved `"^+1"` to `KSA` value
- `newWin()` now uses `getHotkeys()` to remove a required variable

# > Other Changes
`autosave.ahk`
- Removed redundant variables from `timeRemain()` function
- `tooltips` variable now reads an `.ini` file in `A_MyDocuments \tomshi\autosave.ini` instead of an adjustable variable in the script itself