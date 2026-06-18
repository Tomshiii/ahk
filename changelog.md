# <> Release 2.18.x - 

## Functions
- ✅ Fixed `KSA` throwing with `After Effects` versions that do not contain a patch version number (ie. `26.3`)

### 📝 `prem {`
- ❌ Removed `checkNoClips()`
- ✅ Added `isClipSelected()`, `__setEffContScrollbar()`
- ✅ Fixed `setBlendMode()` potentially throwing if blend modes could not be found
- 📋 `__getlayerMid()` now uses UIA to determine the middle divider coordinates
- 📋 `reset()` now uses UIA to determine the `reset` button position

## Other Changes
- ❌ Removed `noclips.png`