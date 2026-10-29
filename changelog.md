# <> Release 2.20.x - 

## Functions
- ✏️ Added `docker {`
- ✅ Fixed `getExtensionVersion()` stalling multiple functions

### 📝 `prem {`
- ✅ Fixed `__checkTimelineValues()` not checking against all values
- 📋 `__getUXPRegistry()` will now automatically regenerate if the `index.js` file has changed
- 📋 Renamed `rippleTrim()` => `delayTick()`
    - No longer checks against `A_PriorKey`
- 📋 `__remoteUXP()` will now check that `docker` is installed and that the `premiereremote-uxp` container is running

📍 `__setRemoteIcon()`
- 📋 Will now perform a different button action for `UXP` if the extension is installed via the `.ccx` file
- 📋 Will now open the respective panel when pressed if it is closed
- 📋 `UXP` button will now check that `docker` is installed and that the `premiereremote-uxp` container is running

### 📝 `AERemote`
- ✏️ Added `replaceSeqWithSequence()`

## Other Changes
- ✅ Fixed `resetNPM.ahk`/`resetAndReset.ahk` throwing
- ✅ Fixed `uninstall_PremiereRemoteUXP.ahk`/`update_PremiereRemoteUXP.ahk` potentially stalling

🔗 `mult-dl.ahk`
- ✅ Fixed `yt-dlp` reverting back to stable release instead of sticking on `nightly`