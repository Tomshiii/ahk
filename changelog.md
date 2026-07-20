# <> Release 2.18.x - 

## Functions
- 📋 `prem.renderAndReplace()` now accepts parameters `handles`, and `includeEffects`

📍 `winExt {`
- ✏️ Added `WaitActiveRegex()`
- ✅ Fixed `ActivateRegex()`, `CloseRegex()`, `MinimizeRegex()`, and `MaximizeRegex()` leaking the `RegEx` titlematchmode

### 📝 `PremiereRemote`
- ✏️ Added `removeMarkerAtPlayhead()`, `getSeqFrameRate()`
- ✅ Fixed `setMarker()` not working on all clip types

📍 `applyEffectSlotJSON()`
- 📋 Can now additionally accept a filepath instead of *just* a `base64` encoded string
- 📋 Can now additionally apply effects from a `prfpset` file

## Other Changes
- ✅ Fixed `HotkeylessAHK` `renderAndReplace()` causing the script to throw if the render took too long