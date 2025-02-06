# <> Release 2.15.2 - QoL Improvements

## Functions
- Added `startup.updateAdobeVerAHK()` to alert the user of updates to the `Vers.ahk`/`adobeVers.ahk` files so that they may select newer versions of adobe programs without needing to wait for a full release
    - Can be toggled in `settingsGUI()`
- Fixed `ytdlp.__activateDir()` failing to activate if the chosen directory is the root folder of a drive
- `trimGUI {` now requires a start/end timecode instead of the user needing to determine the `start time` & `duration` in seconds

`prem {`
- `dragSourceMon("video")` will now work for sources like `Bars and Tone` when the image is different
- `numpadGain()` will now alert the user with a tooltip under certain circumstances if the timeline is not in focus
    - Will now activate if `Effect Controls` is the active window to make keyframing `Levels` more natural
- `toggleLayerButtons()` will now function properly with different layer heights
    - Will now activate even if the `Timeline` is not active, as long as the cursor is within the timeline coordinates
- `wheelEditPoint()` now accepts parameter `checkMButton` which when set to either `true` or an `object` can wait a specified amount of time to ensure the user doesn't click <kbd>MButton</kbd> afterwards (or to ensure it isn't being held). This is useful when panning in `Premiere's` `Program Monitor` when the function is activated using a tilting mouse scroll wheel

`errorLog()`
- Fixed date/time from being printed unintentially at the beginning of the file
- Function can now be called like; `errorLog({state:"empty"})` to generate the initial file

## Other Changes
- Added [`MsgBoxCreator.ahk`](https://www.autohotkey.com/boards/viewtopic.php?t=78253)
    - Added shortcut to `My Scripts.ahk` tray icon right click menu
- Added `move 1sec.ahk` to move the `Premiere` playhead forwards/backwards by 1 second
    - Added `movePlayhead` as a PremiereRemote function
- `backupProj.ahk` will ask the user if they wish to backup any additional `videos` folders