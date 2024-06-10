# <> Release 2.14.x - 

## Functions
- Added `startup.createShortcuts()` to check if shortcuts have been generated
    - Added `createShortcuts.ahk` to help with this process or to allow the user to generate them manually
- Wrapped all uses of `JSON.Parse()` in `try` blocks to hopefully stop some instances of the script locking up in the event that it doesn't retrieve the data it needs
- `winget.PremName()` & `winget.AEName()` now accept parameter `ttips` to determine whether tooltips will display if the window titles cannot be determined
- Fixed `rbuttonPrem().movePlayhead()` attempting to use `PremiereRemote` every use even if it's been determined to not be working correctly
- Fixed `prem.getTimeline()` not properly accounting for a different column size left of the timeline on the new `Spectrum UI`

## Other Changes
- Updated `Notify.ahk` now that text alignment is a native feature
- `autosave.ahk` attempting to restart playback within `Premiere Pro` after a save attempt can now be enabled/disabled within `settingsGUI()`