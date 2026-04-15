# <> Release 2.17.x - 

## Functions
- 📋`startup.adobeVerOverride()` no longer shows `Photoshop` version
- ✅ Fixed some edge cases with `getHotkeys()`
- ✅ Fixed `move.clipMouse()` not working when activated twice

### 📝 `prem {`
- 📋 `toggleEnabled()` will now remove a track from the queue if selected twice
- ✅ Fixed `Notify` use in `renderProjectSelection()`
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