# <> Release 2.10.x
- `UserSettings` is no longer automatically set alongside `UserPref {` and now requires manual initialisation
    - Scripts with settings that can be adjusted by `settingsGUI()` now use `OnMessage()` to know when their settings have been changed (#18)

## > Functions
- Fix `settingsGUI()` throwing if the user clicks the current version in the adobe settings GUI
- Fix `winget.ProjPath()` throwing if program is on a part where the filepath cannot be found
- Fix `gameCheckGUI()` not launching in dark mode
- Add `WM {`
- `ytDownload()` now returns the url
- `discord.button()` will now alert the user if they aren't hovering over a message they sent when trying to use `Edit` or `Delete`