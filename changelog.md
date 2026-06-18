# <> Release 2.18.0.1 - Hotfix

## Functions

### 📝 `prem {`
- ❌ Removed `checkNoClips()`
- ✏️ Added `isClipSelected()`, `__setEffContScrollbar()`
- ✅ Fixed `setBlendMode()` potentially throwing if blend modes could not be found
- 📋 `__getlayerMid()` now uses UIA to determine the middle divider coordinates
- 📋 `reset()` now uses UIA to determine the `reset` button position
- 📋 `changeDupeFrameMarkers()` removed parameter `toggleHotkey`. Now uses `KSA`

### 📝 `KSA {`
- ✅ Fixed throwing with `After Effects` versions that do not contain a patch version number (ie. `26.3`)
- ✏️ Added `togDupeFrameMarkers`

## Other Changes
- ❌ Removed `noclips.png`