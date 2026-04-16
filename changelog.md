# <> Release 2.17.0.2 - Final Hotfix for pre v26.2

This release acts as the final patch before my repo moves to requiring `Premiere v26.2+`  
Supporting newer versions of Premiere will require some hefty rewrites to a lot of the UIA code and as such will **require** me to bump the minimum version required for this repo. So in that regard;

> [!Caution]
> This release is **NOT** compatible with Premiere v26.2+. You may experience large slowdown attempting to use these functions on this version (and beyond) of Premiere. Please wait for an update to address this issue in the future.

## Functions
- 📋`startup.adobeVerOverride()` no longer shows `Photoshop` version
- ✅ Fixed some edge cases with `getHotkeys()`
- ✅ Fixed `move.clipMouse()` not working when activated twice

### 📝 `prem {`
- 📋 `toggleEnabled()` will now remove a track from the queue if selected twice
- ✅ Fixed `Notify` use in `renderProjectSelection()` & `New Premiere.ahk`
- ✅ Fixed `wheelEditPoint()` not passing on the user's `activationKeys` paramater
- ✅ Fixed `accelScroll()` not working

📍 `__remoteFunc()`
- 📋 Will now alert the user if it is waiting for the socket connection to load and abort early to avoid unnecessary errors
- 📋 Will now return a result in more scenarios
- ✅ Fixed function throwing in some scenarios

## Other Changes
- 📋 `Core Functionality.ahk` will now throw if the current directory does not match the install directory

🔗 `Premiere_RightClick.ahk`
- ✅ Fixed script causing a bunch of `PremiereRemote` errors if initiated too quickly after a reload
- ✏️ Added parameter `playbackKeys` to determine which hotkeys will reactivate playback once the function has finished
- 📋 Cursor will now be moved back to the original position in the event it moves to grab the nearby playhead

🔗 `PremiereRemote`
- ✅ Fixed `selectionIsSequence()` only returning `false`
    - ✅ Fixes `renderInPrem()` always failing
- ✏️ Added `setSeqSettings()`
- ✏️ Added `setAllEnableDisabled()`