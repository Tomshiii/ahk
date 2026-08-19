# <> Release 2.18.x - 

## Functions
- ✅ Fixed `errorLog()`/`Log()` sometimes failing to log if interrupted
- ✅ Fixed `Reboot HotkeylessAHK` not working from the tray menu
- ✏️ Added `getWindowScale()`
- 📋 `renderAndReplace()` now accepts parameter `timeout`

### 📝 `prem {`
- ✅ Fixed various instances of calling `__isUiaElementActive()`/`isToolSelected()` incorrectly
- ✏️ Added `isPlaying()`, `isMultiCamActive()`, `getSourceMonDragButtons()`
- 📋 `setShinsIMG()` will now correctly scale based on the user's window scaling
- 📋 `isEditTabActive()` will now return `-1` for any execution failures instead of `false`


📍 `dragSourceMon()`
- ❗ No longer requires any `ImageSearch`
- ❌ Removed parameter `sendOnFailure`
    - 📋 Will no longer send keystrokes on failure
- 📋 Changed paramater `audOrVid` => `audVidBoth`
    - Now accepts `both`
- 📋 Will now only operate if the cursor is within the `Timeline` panel

📍 `wheelEditPoint()`
- 📋 Will now behave differently depending on if the `Multi-Cam` view is active
- 📋 Will now only manually move the playhead forward/backwards if the playhead is stuck in `Multi-Cam` view

## PremiereRemote
- ✏️ Added `getPlayheadPosTicks()`, and `setPlayheadPosTicks()`

## KSA
- ✏️ Added `chooseCam11` => `chooseCam16`

## Other Changes
- ❌ Removed `stop.png`, `sourceMon_audioX.png`, `sourceMon_videoX.png`, `jpgX.png`, `pngX.png`

🔗 `autosave.ahk`
- ❗ No longer requires any `ImageSearch`
- ✅ Fixed `__saveAE()` incorrectly checking for `Premiere` `Notify`'s under certain circumstances
- ✅ Fixed `__checkPremPlayback()` checking an incorrect `UIA` value causing the script to throw
- ✅ Fixed script sometimes failing to reactivate the correct window, or outright not attempting to restart playback
- 📋 Added more guarding so `After Effects` does not attempt to save when it isn't supposed to
- 📋 Now uses UIA to restart playback when enabled