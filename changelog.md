# <> Release 2.14.x - 
- Fixed references/functions/filepaths that assumed `v24.5` was going to be the `Spectrum UI` update

## Functions
- Wrapped all uses of `JSON.Parse()` in `try` blocks to hopefully stop some instances of the script locking up in the event that it doesn't retrieve the data it needs
- `winget.PremName()` & `winget.AEName()` now accept parameter `ttips` to determine whether tooltips will display if the window titles cannot be determined
- Fixed `rbuttonPrem().movePlayhead()` attempting to use `PremiereRemote` every use even if it's been determined to not be working correctly
- Fixed `prem.getTimeline()` not properly accounting for a different column size left of the timeline on the new `Spectrum UI`
- Fixed `settingsGUI()` settings adobe `beta` values as `0/1` instead of `true/false`

`startup {`
- Added `startup.createShortcuts()` to check if shortcuts have been generated
    - Added `createShortcuts.ahk` to help with this process or to allow the user to generate them manually (fixes `New Premiere.ahk` throwing in the event of no shortcuts)
- Fixed `current function` tooltip from showing when the function variable is blank

## Other Changes
- Updated `Notify.ahk` now that text alignment is a native feature
- `reencodeGUI()` will now prompt the user asking if they'd like to attempt to force GPU rendering if it rudimentarily determines GPU rendering isn't available

`autosave.ahk`
- Script attempting to restart playback within `Premiere Pro` after a save attempt can now be enabled/disabled within `settingsGUI()`
- Making `After Effects` opaque should now be more reliable
- Fixed script failing to fall back to alternate save method if `PremiereRemote` server is not functioning correctly