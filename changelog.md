# <> Release 2.13.2 - Hotfix

## > Functions
- Fixed `Premiere` & `After Effects` `Version` selector dropdown not visually sticking if the GUI window is closed and reopened before restarting `settingsGUI()`
- Fixed `cmd.mapDrive()` && `cmd.deleteMappedDrive()` incorrectly calling `this.run()`
- Added `prem.anchorToPosition()`
- `ytdlp.handleDownload()` will now correctly handle `youtu.be` links and treat them as youtube links

`switchTo {`
- Added `Slack()`

- `Disc()`
    - Now takes parameter `doMove` to determine if the user wishes to move it. Defaults to `false`
    - Coordinate paramaters have been condensed to a single object parameter

## > Other Changes
- Added `sleepDisplays.ahk`