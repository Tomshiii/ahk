# <> Release 2.13.x - 

## > Functions

`settingsGUI()`
- Fixed `Adobe` settings generating incorrect values
- `Adobe` settings will now only present the user with versions of `Premiere` & `After Effects` that they have installed. `Photoshop` will show any versions they have installed +- 1 as their numbering system is a bit weird and I have no intention of keeping a catelogue of what version relates to which year

## > autosave.ahk
- Script should now be better at determining if `rbuttonPrem()` is active which should result in less cuts on the timeline
- Fixed `autosave.ahk` failing to reactive the original window if a save attempt is made

## > Other Changes
- Fixed `generateAdobeSym.ahk` silently failing if build command got too long
- Fixed `Hours Worked` in `checklist.ahk` showing incorrectly unless the timer has stopped
- Added `selectFollowPlayhead.ahk`
- Added `swapChannels.ahk`
- `adobe fullscreen check.ahk` should now be better at determining if `rbuttonPrem()` is active which should result in less window flashing