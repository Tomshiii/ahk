# <> Release 2.6.x
- Some scripts now require `AutoHotkey v2.0-beta.12` as a minimum

## > Functions
- Added a slight delay to `vscode()` when expanding the `Functions` folder to ensure the right folder is expanded
- `zoom()` tooltip to notify that toggle values have been reset now only appears if the current project has a toggle zoom
- `moveWin()` (when pressing the maximise hotkey) will now check to see if the active window is already maximised, and if it is, unmaximise it
- `updateChecker()` will (while beta update checking is enabled) no longer show the update changelog as the current `dev branch` changelog unless the latest update is actually a pre-release

## > My Scripts
- All hotkeys that saved the state of the clipboard now save `ClipboardAll()`

`$^f::`
- Now checks to see if you have anything highlighted and won't delete it from the search field if you do
- Now requires `editor.emptySelectionClipboard` to be set to `false` within `VSCode`
    - Added `$^x::` to recreate `VSCode's` typical feature to remove an entire line with `^x` (setting `editor.emptySelectionClipboard` to `false` removes this feature as well)

## > Resolve
- `Rbutton::` now saves the timeline coordinates in a static variable to speed things up *(this forces the need for a reload if the user moves the timeline however)*
- Now uses `getHotkeys()` in place of all `A_PriorHotkey`
- Fixed a large amount of `ImageSearch` logic blocks that I broke with `Release v2.6`
- `rgain()` now returns the original Clipboard once complete
- Updated some images for `Resolve 18.0.4`
- `REffect()` will now more accurately drag the desired effect in more scenarios
    - Will also not attempt to run while Resolve is not maximised and will notify the user

## > Other Changes
- Removed all uses of `verCheck()` and replaced with `#Requires`
- `autosave.ahk` will now attempt to reactivate the original window even if the user interupts the save by interacting with the keyboard
- Moved; `pauseautosave()`, `pausewindowmax()` & `ScriptSuspend(ScriptName, SuspendOn)` to `General.ahk`
- Fix edge case bug of `getID()` not assigning a value and causing an error
- Moved `gameCheck.ahk` game list to `\lib\gameCheck\Game List.ahk`
- Fix `Multi-Instance Close.ahk` starting its timer before the `ms` variable has been set

`checklist.ahk`
- Will now apply a dark theme to the menu popouts
- If `autosave.ahk` attempts to open `checklist.ahk` before the user has opened a project, `checklist.ahk` will now ask the user if they wish to wait until a project has been opened, or if they'd like to manually select the project
- `Check for Updates`
    - If the user has generated a `settings.ini` file, it will now compare the local `Release` version, to the latest release version on github instead of checking the local version of `checklist.ahk`
    - If the user hasn't generated a `settings.ini` file, it will now just open the root dir of the repo on github instead of the individual `checklist.ahk` url (now that so many things related to `checklist.ahk` are separated into the `\lib` dir, it makes no sense to point the user to that specific page)

`HotkeyReplacer.ahk`
- All text is centered for a cleaner look
- Now has a `TrayIcon`
- Now shows a progress bar
- Now shows a status bar that updates during the various steps in the process
- Now follows global dark mode settings (defaults to dark mode if no settings.ini file has been generated yet)