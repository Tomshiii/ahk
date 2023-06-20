# <> Release 2.11.3 - Fixes and QOL Adjustments
- Added `Premiere Timeline GUI.ahk` which produces an icon on the left side of the timeline to offer the user a visual indication of whether timeline focusing in some hotkeys/functions is turned `on` or `off`
    - This icon can be enabled/disabled within `settingsGUI()`

## > Functions
- Fix `getHTMLTitle()` no longer returning `Twitch` titles correctly
- Fix `settingsGUI()` setting `premVer` incorrectly for `v23.0+`
- `musicGUI()` will no longer throw if the user doesn't have the application installed
- `settingsGUI()` will now select the most recent release of `Premiere`/`AE` when the user changes their year

`Premiere_RightClick.ahk`
- Fixed another bug causing `My Scripts.ahk` to crash under certain circumstances
- Added an additional colour to give better compatibility with `v23.4`

`Prem {`
- Using `prem.valuehold()` to adjust the `Y` coordinate should now be less prone to missing the blue text
- Class now stores an internal value that can be toggled to determine whether the user wants some hotkeys/functions to focus the `timeline`
    - To change this value call `prem().__toggleTimelineFocus()`
- Added `prem.timelineFocusStatus()` to check for the coloured outline of a typically focused window to determine if the timeline needs to be focused or not
    - Avoids Premiere cycling through sequences when the user simply needs to focus the timeline
- Added `prem.Previews()` to speed up the process of generating/deleting `Render Previews`

## > Other Changes
- Added `remapDrive.ahk` to quickly and easily remap network drives
    - Adds `cmd.mapDrives()` & `cmd.inUseDrives()`
- `New Premiere.ahk` no longer attempts to set ingest settings
- `vfx.ahk` & `video.ahk` now attempt to check if a download process has already started to avoid erroring out
- `ffmpeg.reencode_h26x()` will now default to `veryfast` instead of `medium`