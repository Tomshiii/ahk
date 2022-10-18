# <> Release 2.6.x

## > Functions
- Added a slight delay to `vscode()` when expanding the `Functions` folder to ensure the right folder is expanded

## > My Scripts
- All hotkeys that saved the state of the clipboard now save `ClipboardAll()`

`$^f::`
- Now checks to see if you have anything highlighted and won't delete it from the search field if you do
- Now requires `editor.emptySelectionClipboard` to be set to `false` within `VSCode`
    - Added `$^x::` to recreate `VSCode's` typical feature to remove an entire line with `^x` (setting `editor.emptySelectionClipboard` to `false` removes this feature as well)

## > Resolve
- `Rbutton::` now saves the timeline coordinates in a static variable to speed things up *(this forces the need for a reload if the user moves the timeline however)*
- Now uses `getHotkeys()` in the place of `A_PriorHotkey`
- Fixed a large amount of `ImageSearch` logic blocks that I broke with `Release v2.6`
- `rgain()` now returns the original Clipboard once complete
- Updated some images for `Resolve 18.0.4`

## > Other Changes

`HotkeyReplacer.ahk`
- All text is centered for a cleaner look
- Now has a `TrayIcon`
- Now shows a progress bar
- Now shows a status bar that updates during the various steps in the process
- Now follows global dark mode settings (defaults to dark mode if no settings.ini file has been generated yet)