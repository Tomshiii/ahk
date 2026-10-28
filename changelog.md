# <> Release 2.20.x - 

## Functions

### 📝 `prem {`
- 📋 `__setRemoteIcon()` will now perform a different button action for `UXP` if the extension is installed via the `.ccx` file
- 📋 `__getUXPRegistry()` will now automatically regenerate if the `index.js` file has changed
- 📋 Renamed `rippleTrim()` => `delayTick()`
    - No longer checks against `A_PriorKey`

### 📝 `AERemote`
- ✏️ Added `replaceSeqWithSequence()`

## Other Changes
- ✅ Fixed `resetNPM.ahk` throwing

🔗 `mult-dl.ahk`
- ✅ Fixed `yt-dlp` reverting back to stable release instead of sticking on `nightly`