# <> Release 2.18.x - 

## Functions
- ✏️ Added `coord.screenToClient()`/`coord.clientToScreen()`, `cmd.httpGet()`, `premUIA_Values.getSelectedTool()`

### 📝 `prem {`
- ✏️ Added `prem.getPlayheadPosition()`
- 📋 `__remoteFunc()` & `__remoteUXP()` now use `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time
- 📋 `__getAllLayerPos()` now uses `ShinsImageScanClass` to determine all layers
- 📋 `selectTool()` now accepts parameter `uiaOrPrem` & `focusTimeline`
- 📋 `__focusTimeline()` will first attempt to use UIA to focus the timeline before falling back to previous methods

### 📝 `ae {`
- ✅ Fixed `selectTool()` crashing AE
- ✏️ Added `ae.getActivePanelName()`
- 📋 `__remoteFunc()` now uses `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time

## PremiereRemote
- ✏️ Added `resetSelection()`

### 📝 `UXP`
- ✅ Fixed some actions not using `await`