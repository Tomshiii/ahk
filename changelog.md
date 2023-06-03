# <> Release 2.11.x
- Add `Premiere Timeline GUI.ahk` which produces an icon on the left side of the timeline to offer the user a visual indication of whether timeline focusing in some hotkeys/functions is turned `on` or `off`
    - This icon can be enabled/disabled within `settingsGUI()`

## > Functions
- `musicGUI()` will no longer throw if the user doesn't have the application installed

`Prem {`
- Using `prem.valuehold()` to adjust the `Y` coordinate should now be less prone to missing the blue text
- Class now stores an internal value that can be toggled to determine whether the user wants some hotkeys/functions to focus the `timeline`
    - `rbuttonPrem().movePlayhead()`, `prem.mouseDrag()` & `(previous/next)editpoint::`

## > Other Changes
- `New Premiere.ahk` no longer attempts to set ingest settings