# <> Release 2.6.x

## > Functions
- Added a slight delay to `vscode()` when expanding the `Functions` folder to ensure the right folder is expanded

## > My Scripts
- Added `$^x::` to recreate `VSCode's` typical feature to remove an entire line with `^x`
    - The new `$^f::` macro requires `editor.emptySelectionClipboard` to be set to `false` within `VSCode`    
- `$^f::` now checks to see if you have anything highlighted and won't delete it from the search field if you do

## > Other Changes

`HotkeyReplacer.ahk`
- All text is centered for a cleaner look
- Now has a `TrayIcon`
- Now shows a progress bar
- Now shows a status bar that updates during the various steps in the process
- Now follows global dark mode settings (defaults to dark mode if no settings.ini file has been generated yet)