# <> Release 2.11.x - 

## > Functions
`prem {`
- Fixed `gain()` getting stuck if used multiple times in a row
    - Will also now double check to ensure audio is selected before attempting to open the gain window
- `__checkTimelineFocus()` is now static

## > Other Changes
- `prem.gain()` can now be called quickly by pressing any of the <kbd>Numpad</kbd> buttons
    - <kbd>NumpadSub</kbd> can be pressed before any input to remove the selected number instead of adding