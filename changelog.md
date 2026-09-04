# <> Release 2.18.x - 

## Functions

### 📝 `ae {`
- ✏️ Added `selectTool()`
- 📋 `isToolSelected()` now accepts param `returnObj`

### 📝 `premUIA_Values {`
- ✅ Fixed `__activeElementPath(true)` not returning the focused element object and instead returning a string path
- 📋 If `elementPath` passed into `__isUiaElementActive()` is a UIA path tracked in `UIA_Hwnd` it will attempt an initial rudimentary check for active state by checking the `UIA` `state` value for either `4`/`1048580` before falling back to previous methods

## PremiereRemote
- ✏️ Added `getActiveSequenceName()`
- 📋 Renamed `getActiveSequence()` => `getActiveSequenceID()` for parity/clarity