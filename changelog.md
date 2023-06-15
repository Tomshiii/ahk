# <> Release 2.11.x
- Added `Premiere Timeline GUI.ahk` which produces an icon on the left side of the timeline to offer the user a visual indication of whether timeline focusing in some hotkeys/functions is turned `on` or `off`
    - This icon can be enabled/disabled within `settingsGUI()`

## > Functions
- Fix `getHTMLTitle()` no longer returning `Twitch` titles correctly
- `musicGUI()` will no longer throw if the user doesn't have the application installed

`Premiere_RightClick.ahk`
- Fixed another bug causing `My Scripts.ahk` to crash under certain circumstances
- Added an additional colour to give better compatibility with `v23.4`

`Prem {`
- Using `prem.valuehold()` to adjust the `Y` coordinate should now be less prone to missing the blue text
- Class now stores an internal value that can be toggled to determine whether the user wants some hotkeys/functions to focus the `timeline`
    - `rbuttonPrem().movePlayhead()`, `prem.mouseDrag()` & `(previous/next)editpoint::`
- Added `prem.timelineFocusStatus()` to check for the coloured outline of a typically focused window to determine if the timeline needs to be focused or not
- Added `prem.Previews()` to speed up the process of generating/deleting `Render Previews`

## > Other Changes
- `New Premiere.ahk` no longer attempts to set ingest settings
- `vfx.ahk` & `video.ahk` now attempt to check if a download process has already started to avoid erroring out