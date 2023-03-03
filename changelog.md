# <> Release 2.10.x - 
- `tomshiBasic {` will now force `"Segoe UI Variable"` as the font to ensure proper scaling if the user has changed their system font (#16)

## > Functions
- Add `keys.allCheck()`
- `delaySI()` can now send `Numbers` instead of only `Strings`
- `switchTo.AE()` will now check the transparency of `After Effects` and set it to opaque before swapping to it

`prem {`
- `zoom()` will now on first use retrieve coordinates to place the tooltip alerting the user toggles have reset
    - Hotkey that calls `prem.zoom()` now encased in `#MaxThreadsBuffer` to better cycle through zoom values
- Colour values for `audioDrag()` now maintained in a `Map` at the top of the class
- Refactored and reduced repeat code to lower footprint by around 4%

## > Other Changes
- Fixed `right click premiere.ahk` erroring out if hotkey attempts to fire before the array of colours has been set
- Attempt to fix (#17) `autosave.ahk` erroring while setting AE transparency