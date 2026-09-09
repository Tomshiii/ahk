# <> Release 2.18.x - 

## Functions
- ✏️ Added `null {`
- ✏️ Added `CLSID_Objs.loadProp()`/`CLSID_Objs.writeProp()`
    - Reduces the `COM` round trip time across many functions

### 📝 `prem {`
- 📋 `CEP`/`UXP` functions (and parameters) are now only computed once

📍 `preset()`
- ✅ Fixed function failing to determine the find box
- 📋 Now accepts param `folderDepth`

### 📝 `ae {`
- ✏️ Added `selectTool()`
- 📋 `isToolSelected()` now accepts param `returnObj`
- 📋 `CEP` functions (and parameters) are now only computed once

### 📝 `premUIA_Values {`
- ✏️ Added `getLivePanel()`
- ✅ Fixed `__activeElementPath(true)` not returning the focused element object and instead returning a string path
- 📋 If `elementPath` passed into `__isUiaElementActive()` is a UIA path tracked in `UIA_Hwnd` it will attempt an initial rudimentary check for active state by checking the `UIA` `state` value for either `4`/`1048580` before falling back to previous methods
- 📋 `setObjs()` will exit early if the `Edit` tab is not selected

### 📝 `CLSID_Objs {`
- ✏️ Added `writeProp()`, `loadProp()`
    - `loadProp()` is now used wherever possible to significantly reduce the `COM` round trip time

## PremiereRemote
- ✏️ Added `getActiveSequenceName()`
- 📋 Renamed `getActiveSequence()` => `getActiveSequenceID()` for parity/clarity