# <> Release 2.11.x

## > Functions
- `Premiere_RightClick.ahk` now produces an icon on the left side of the timeline to offer the user a visual indication of whether timeline focusing is turned `on` or `off`
    - This icon can be enabled/disabled within `settingsGUI()`
- `musicGUI()` will no longer throw if the user doesn't have the application installed

`Prem {`
- Using `prem.valuehold()` to adjust the `Y` coordinate should now be less prone to missing the blue text
- Now stores an internal value that can be toggled to determine whether the user wants some functions to focus the `timeline`
    - `rbuttonPrem().movePlayhead()`, `prem.mouseDrag()` & `(previous/next)editpoint::`

## > Other Changes
- `New Premiere.ahk` no longer attempts to set ingest settings