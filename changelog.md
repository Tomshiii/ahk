# <> Release 2.18.x - 

## Functions

📍 `winExt {`
- ✏️ Added `WaitActiveRegex()`
- ✅ Fixed `ActivateRegex()`, `CloseRegex()`, `MinimizeRegex()`, and `MaximizeRegex()` leaking the `RegEx` titlematchmode

### 📝 `PremiereRemote`
- ✏️ Added `removeMarkerAtPlayhead()`
- ✅ Fixed `setMarker()` not working on all clip types

📍 `applyEffectSlotJSON()`
- 📋 Can now additionally accept a filepath instead of *just* a `base64` encoded string
- 📋 Can now additionally apply effects from a `prfpset` file