# <> Release 2.10.4 - Settings.ahk Changes
- `UserSettings` is no longer automatically set alongside `UserPref {` and now requires manual initialisation
    - Scripts with settings that can be adjusted by `settingsGUI()` now use `OnMessage()` to know when their settings have been changed (#18)

## > Functions
- Fix `settingsGUI()` throwing if the user clicks the current version in the adobe settings GUI
- Fix `winget.ProjPath()` throwing if program is on a part where the filepath cannot be found
- Fix `gameCheckGUI()` not launching in dark mode
- Add `WM {`
- `discord.button()` will now alert the user if they aren't hovering over a message they sent when trying to use `Edit` or `Delete`

`ytDownload()`
- Now returns the url
- Now works with `youtu.be` links (youtube share links)

`switchTo.AE()`
- Fix edgecase where program would not activate
- Fix function no longer working if using a version of `After Effects` other than `v22.6`

## > Other Changes
- `CreateSymLink.ahk` will now also generate Symlinks for adobe folders to partially support more versions