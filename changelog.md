# <> Release 2.18.x - 

## Functions
- ✏️ Added `coord.screenToClient()`/`coord.clientToScreen()`, `cmd.httpGet()`

### 📝 `prem {`
- ✏️ Added `prem.getPlayheadPosition()`
- 📋 `__remoteFunc()` & `__remoteUXP()` now use `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time
- 📋 `__getAllLayerPos()` now uses `ShinsImageScanClass` to determine all layers

### 📝 `ae {`
- ✅ Fixed `selectTool()` crashing AE
- ✏️ Added `ae.getActivePanelName()`
- 📋 `__remoteFunc()` now uses `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time

## PremiereRemote
- ✏️ Added `resetSelection()`

### 📝 `UXP`
- ✅ Fixed some actions not using `await`