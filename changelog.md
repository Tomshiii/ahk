# <> Release 2.18.x - 

## Functions
- ✅ Fixed `errorLog()`/`Log()` sometimes failing to log if interrupted
- ✅ Fixed `Reboot HotkeylessAHK` not working from the tray menu
- ✅ Fixed `startup.gitBranchCheck()` throwing
- ✏️ Added `getWindowScale()`

### 📝 `prem {`
- ✅ Fixed various instances of calling `__isUiaElementActive()`/`isToolSelected()` incorrectly
- ✅ Fixed `__checkRemoteParams()` throwing if a param included a <kbd>=</kbd> in its value
- ✅ Fixed `__disableMulticamOnAudioEffect()` logic behaving unexpectedly if the window is hidden by deselecting the clip instead of fully closing it
- ✅ Fixed `__getlayerMid()` potentially returning the incorrect `midDivYBottom` value
- ✏️ Added `isPlaying()`, `isMultiCamActive()`, `getSourceMonDragButtons()`, `determineLockedTracks()`
- 📋 `renderAndReplace()` now accepts parameter `timeout`
- 📋 `setShinsIMG()` will now correctly scale based on the user's window scaling
- 📋 `isEditTabActive()` will now return `-1` for any execution failures instead of `false`
- 📋 `delayPlayback()`/`rippleTrim()` now share their values over the `UIA` object for better reliability

📍 `gain()`
- 📋 Now accepts parameter `opt` to set all 4 types of gain
- 📋 Now uses UIA to set values instead of keystrokes

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

### 📝 `rbuttonPrem {`
- ❗ No longer uses `Hotkey` 
- 📋 Once again uses [`MouseHook.ahk`](<https://discord.com/channels/115993023636176902/1207794506095923350/1207794506095923350>) (without the issues this time<sup>[[1]](<https://github.com/Tomshiii/ahk/releases/tag/v2.14.1.1>)</sup>)
    - This stops any user set hotkeys from getting deleted after `rbuttonPrem.movePlayhead()` has been called (and `playbackKeys` has been set)

## PremiereRemote
- ✏️ Added `getPlayheadPosTicks()`, and `setPlayheadPosTicks()`

## KSA
- ✏️ Added `chooseCam11` => `chooseCam16`

## Other Changes
- ❌ Removed `stop.png`, `sourceMon_audioX.png`, `sourceMon_videoX.png`, `jpgX.png`, `pngX.png`
- 📋 Changed all uses of `UIA` `LocalizedType` to the corresponding `Type` integer for broader compatibility

🔗 `autosave.ahk`
- ❗ No longer requires any `ImageSearch`
- ✅ Fixed `__saveAE()` incorrectly checking for `Premiere` `Notify`'s under certain circumstances
- ✅ Fixed `__checkPremPlayback()` checking an incorrect `UIA` value causing the script to throw
- ✅ Fixed script sometimes failing to reactivate the correct window, or outright not attempting to restart playback
- 📋 Added more guarding so `After Effects` does not attempt to save when it isn't supposed to
- 📋 Now uses UIA to restart playback when enabled

🔗 `mult-dl.ahk`
- ✅ Fixed script throwing if the whole repo is not installed
- 📋 Folder picker will default to the current installation directory when updating `.exe`