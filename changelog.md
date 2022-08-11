# <> Release 2.5.x - 

# > Functions
- `discUnread()` now shows the proper tooltip depending on if it can't find any servers/channels
- `moveTab()` will now set the `monitor` variable to one of the two I wish to cycle between if the function is activated on a monitor that isn't included in the cycle

# > My Scripts
`SC03A & c::`
- Will now attempt to determine whether to capitilise or completely lowercase the highlighted text depending on which is more frequent
- Fixed a bug that caused the hotkey to ignore any text in quotation marks
- Removed `SC03A & v::` as it is now redundant
- Will now prompt the user if the highlighted string is too long before continuing

# > Other Changes

`autosave.ahk`
- Removed redundant variables from `timeRemain()` function
- `tooltips` variable now reads a `.ini` file in `A_MyDocuments \tomshi\autosave.ini` instead of an adjustable variable in the script itself