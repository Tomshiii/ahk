# <> Release 2.12.x - 

## > Functions
- Fixed `settingsGUI()` failing to appropriately set `autosave_save_override`

`adobeTemp()`
- Fixed adding cache directories together even if they were the same path
- Fixed function deleting all files within the set directory instead of specific paths

`prem {`
- Fixed some `QMK` functions failing to focus the timeline without scrolling through multiple sequences
    - Focusing the timeline should now be more reliable across all scripts
- `preset()` & `zoom()` now make use of `UIA` for better reliability
- `PremHotkeys.__HotkeySet()` now accepts additional parameter `Options`

`switchTo {`
- Renamed `Photo()` => `Photoshop()`
- `Premiere()` & `AE()` will no longer throw if the required shortcut file doesn't exist

## > autosave.ahk
- Backing up of project files will now be placed in folders sorted by `YYYY_MM_DD` and will no longer only store 1 version of the current project
- Fixed script failing to override the save hotkey

## > Other Changes
- Fixed incorrect `KSA` value used in `Resolve_Example.ahk`
- `blend` streamdeck scripts now use `SetDefaultMouseSpeed(0)`