# <> Release 2.18.x - 

## Functions
- ✏️ Added `getWindowScale()`

### 📝 `prem {`
- ✏️ Added `isPlaying()`
- 📋 `setShinsIMG()` will now correctly scale based on the user's window scaling
- 📋 `isEditTabActive()` will now return `-1` for any execution failures instead of `false`

## Other Changes
- ❌ Removed `stop.png`

🔗 `autosave.ahk`
- ❗ No longer requires any `ImageSearch`
- ✅ Fixed `__saveAE()` incorrectly checking for `Premiere` `Notify`'s under certain circumstances
- ✅ Fixed `__checkPremPlayback()` checking an incorrect `UIA` value causing the script to throw
- ✅ Fixed script sometimes failing to reactivate the correct window, or outright not attempting to restart playback
- 📋 Added more guarding so `After Effects` does not attempt to save when it isn't supposed to