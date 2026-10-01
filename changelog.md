# <> Release 2.19.x - 

## Functions

### 📝 `prem {`
- ✅ Fixed `dismissWarning()` potentially leaving inputs blocked
- ✅ Fixed `effectSlot()` potentially silently failing
- 📋 `UXP` functions are now checked using `PremiereRemote`'s internal registry

### 📝 `rbuttonPrem {`
📍 `movePlayhead()`
- ✅ Fixed leaving mouse movement blocked if the user activates the function while dragging a panel
- ✅ Fixed `sendOnFailure` key not being sent if timeline values have not been set and no sequences are open

### 📝 `PremiereRemote`
- 📋 `replacePremRemote.ahk` will now work correctly for any `.ts` files stored in folders

📍 `UXP`
- ✏️ Added `getRegistryJSON()`
- ✅ Fixed `saveEffectSlotJSON()`/`applyEffectSlotJSON()`
- 📋 Adjust multiple functions to retrieve information concurrently
- 📋 Moved alot of functions into their own files to organise them a bit better
- 📋 `getPlayheadPosTimecode()` will now use internal function `timeToTimecode()` in `v27.0+`

📍 `Both`
- 📋 `movePlayhead()`/`movePlayheadFrames()`/`moveClip()` no longer require parameter `subtract`