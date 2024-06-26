# <> Release 2.14.x - 
- Fixed references/functions/filepaths that assumed `v24.5` was going to be the `Spectrum UI` update

## Functions
- Fixed `rbuttonPrem().movePlayhead()` attempting to use `PremiereRemote` every use even if it's been determined to not be working correctly
- Fixed `settingsGUI()` setting adobe `beta` values as `0/1` instead of `true/false`
- Fixed `generateAdobeShortcut()` incorrectly generating `After Effects Beta` shortcut
- `winget.PremName()` & `winget.AEName()` now accept parameter `ttips` to determine whether tooltips will display if the window titles cannot be determined
- `SD_Opt {` now contains function `checkCount()` to ensure all currently available options have been set in the user's `options.ini` file

`switchTo {`
- `AE()`
    - Should now more reliably bring After Effects into focus
    - Will now focus `Mocha` if it exists

`Prem {`
- Fixed `getTimeline()` not properly accounting for a different column size left of the timeline on the new `Spectrum UI`
- `swapChannels()` will now work for 2 track files assuming you want all media channels to use the same stereo pair

`startup {`
- Added `startup.createShortcuts()` to check if shortcuts have been generated
    - Added `createShortcuts.ahk` to help with this process or to allow the user to generate them manually (fixes `New Premiere.ahk` throwing in the event of no shortcuts)
- Fixed `current function` tooltip from showing when the function variable is blank

## Other Changes
- Updated `Notify.ahk` now that text alignment is a native feature
- Added `vidPart.ahk` & `audPart.ahk` to automate downloading specific timecodes of youtube videos
- Wrapped all uses of `JSON.Parse()` in `try` blocks to hopefully stop some instances scripts locking up in the event that they don't retrieve the data they need
- `reencodeGUI()` will now prompt the user asking if they'd like to attempt to force GPU rendering if it rudimentarily determines GPU rendering isn't available

`autosave.ahk`
- Script attempting to restart playback within `Premiere Pro` after a save attempt can now be enabled/disabled within `settingsGUI()`
- Making `After Effects` opaque should now be more reliable
- Fixed script failing to fall back to alternate save method if `PremiereRemote` server is not functioning correctly