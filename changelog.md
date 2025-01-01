# <> Release 2.15.x - 

## Functions
- Added `startup.updateAdobeVerAHK()` to allow the user for updates to the `Vers.ahk`/`adobeVers.ahk` files so that they may select newer versions of adobe programs without needing to wait for a full release
    - Can be toggled in `settingsGUI()`

`errorLog()`
- Fixed date/time from being printed unintentially at the beginning of the file
- Function can now be called like; `errorLog({})` to generate the initial file

## Other Changes
- Added [`MsgBoxCreator.ahk`](https://www.autohotkey.com/boards/viewtopic.php?t=78253)
    - Added shortcut to `My Scripts.ahk` tray icon right click menu