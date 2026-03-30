# <> Release 2.17.x - 

## Functions
- 📋`startup.adobeVerOverride()` no longer shows `Photoshop` version
- ✅ Fixed some edge cases with `getHotkeys()`
- ✅ Fixed `move.clipMouse()` not working when activated twice

### 📝 `prem {`
- 📋 `__remoteFunc()` will now alert the user if it is waiting for the socket connection to load and abort early to avoid unnecessary errors
- 📋 `toggleEnabled()` will now remove a track from the queue if selected twice
- ✅ Fixed `Notify` use in `renderProjectSelection()`
- ✅ Fixed `wheelEditPoint()` not passing on the user's `activationKeys` paramater
- ✅ Fixed `accelScroll()` not working

## Other Changes
- ✅ Fixed `Premiere_RightClick.ahk` causing a bunch of `PremiereRemote` errors if initiated too quickly after a reload
- 📋 `Core Functionality.ahk` will now throw if the current directory does not match the install directory

🔗 `PremiereRemote`
- ✅ Fixed `selectionIsSequence()` only returning `false`
    - ✅ Fixes `renderInPrem()` always failing