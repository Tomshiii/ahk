# <> Release 2.18.x - 

## Functions

📍 `prem {`
- 📋 `renderAndReplace()` now accepts parameters `handles`, and `includeEffects`
- 📋 `__remoteFunc()` will now alert the user if they've passed incorrect parameters or if they've forgotten to pass the parameter name

📍 `winExt {`
- ✏️ Added `WaitActiveRegex()`
- ✅ Fixed `ActivateRegex()`, `CloseRegex()`, `MinimizeRegex()`, and `MaximizeRegex()` leaking the `RegEx` titlematchmode

### 📝 `PremiereRemote`
- ✏️ Added `removeMarkerAtPlayhead()`, `getSeqFrameRate()`, `addMatchedAdjustmentLayer()`
- ✅ Fixed `setMarker()` not working on all clip types

📍 `applyEffectSlotJSON()`
- 📋 Can now additionally accept a filepath instead of *just* a `base64` encoded string
- 📋 Can now additionally apply effects from a `prfpset` file

## Other Changes
- ✅ Fixed `HotkeylessAHK` `renderAndReplace()` causing the script to throw if the render took too long