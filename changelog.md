# <> Release 2.14.10 - Bugfix

## Functions
- Fixed `autosave.ahk` not saving if `PremiereRemote` is unresponsive

`settingsGUI()`
- Added a button/Menu option that links to a wiki page explaining what all the settings do
- Fixed `Premiere`/`After Effects` versions being unselectable if the current beta version is a different `year` version


`premUIA_Values {`
- `__setNewVal()`
    - Will now block inputs while it is interacting with Premiere so the user cannot interrupt it
    - Will now ensure playback has halted before continuing as UIA can become incredibly unresponsive during playback

## Other Changes
- This version will now assume the `Spectrum UI` is coming in `v25.0` and not `v24.6`