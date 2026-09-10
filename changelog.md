# <> Release 2.18.x - 

## Functions
- ✏️ Added `null {`
- ✏️ Added `CLSID_Objs.loadProp()`/`CLSID_Objs.writeProp()`
    - Reduces the `COM` round trip time across many functions

### 📝 `prem {`
- ✏️ Added `isClipUnderCursor()`
- 📋 `CEP`/`UXP` functions (and parameters) are now only computed once
- 📋 `isClipSelected()` now accepts parameter `single`
- 📋 `toggleEnabled()` should be a 150-300ms faster to begin on average

📍 `preset()`
- ✅ Fixed function failing to determine the find box
- 📋 Now accepts param `folderDepth`

### 📝 `ae {`
- ✏️ Added `selectTool()`
- 📋 `CEP` functions (and parameters) are now only computed once
- 📋 `isToolSelected()` now accepts param `returnObj`
- 📋 `isClipSelected()` now accepts parameter `single`

### 📝 `premUIA_Values {`
- ✏️ Added `getLivePanel()`
- ✅ Fixed `__activeElementPath(true)` not returning the focused element object and instead returning a string path
- 📋 If `elementPath` passed into `__isUiaElementActive()` is a UIA path tracked in `UIA_Hwnd` it will attempt an initial rudimentary check for active state by checking the `UIA` `state` value for either `4`/`1048580` before falling back to previous methods
- 📋 `setObjs()` will exit early if the `Edit` tab is not selected

### 📝 `CLSID_Objs {`
- ✏️ Added `writeProp()`, `loadProp()`
    - `loadProp()` is now used wherever possible to significantly reduce the `COM` round trip time

## PremiereRemote
- ✏️ Added `getActiveSequenceName()`, `isSelectedSingle()`
- 📋 Renamed `getActiveSequence()` => `getActiveSequenceID()` for parity/clarity

## AERemote
- ✏️ Added `isSelectedSingle()`