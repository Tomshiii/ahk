# <> Release 2.15.x - 

## Functions
- Added `startup.updateAdobeVerAHK()` to alerts the user of updates to the `Vers.ahk`/`adobeVers.ahk` files so that they may select newer versions of adobe programs without needing to wait for a full release
    - Can be toggled in `settingsGUI()`

`prem {`
- `dragSourceMon("video")` will now work for sources like `Bars and Tone` when the image is different
- `numpadGain()` will now alert the user with a tooltip under certain circumstances if the timeline is not in focus

`errorLog()`
- Fixed date/time from being printed unintentially at the beginning of the file
- Function can now be called like; `errorLog({state:"empty"})` to generate the initial file

## Other Changes
- Added [`MsgBoxCreator.ahk`](https://www.autohotkey.com/boards/viewtopic.php?t=78253)
    - Added shortcut to `My Scripts.ahk` tray icon right click menu
- Added `move 1sec.ahk` to move the `Premiere` playhead forwards/backwards by 1 second
    - Added `movePlayhead` as a PremiereRemote function