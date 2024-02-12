# <> Release 2.13.x - 

## > Functions
- Fixed `prem.wheelEditPoint()` getting stuck when using multicam view
- Fixed `settingsGUI()` showing invalid versions in the dropdown list
- Fixed `switchTo.Photoshop()` throwing if shortcut does not already exist
- `genProjDirs()` directory selection will default to a selected explorer window if it is the active window
- `switchTo.Explorer()` now contains code to ignore other programs that share the same class values and cause unexpected conflicts
- `tool.cust()` now offers darkmode and will default to the system theme
- `settingsGUI()` now offers selections for `Photoshop`

## > Streamdeck AHK
- Fix `proresGUI {` failing to run the ffmpeg command

## > Other Changes
- Fixed `autosave.ahk` failing to restart playback
- Added `Labels.ini` to backup premiere label colours