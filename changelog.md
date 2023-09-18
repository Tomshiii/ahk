# <> Release 2.12.x - 

## > Functions

`prem {`
- Fixed some `QMK` functions failing to focus the timeline without scrolling through multiple sequences
    - Focusing the timeline should now be more reliable across all scripts
- `preset()` now makes use of `UIA` for better reliability
- `zoom()` now makes use of `UIA` for better reliability

`switchTo {`
- Renamed `Photo()` => `Photoshop()`
- `Premiere()` & `AE()` will no longer throw if the required shortcut file doesn't exist

## > Other Changes
- Fixed incorrect `KSA` value used in `Resolve_Example.ahk`
- `blend` streamdeck scripts now use `SetDefaultMouseSpeed(0)`