# <> Release 2.18.x - 

## Functions
- ✏️ Added `coord.screenToClient()`/`coord.clientToScreen()`, `cmd.httpGet()`, `premUIA_Values.getSelectedTool()`

### 📝 `prem {`
- ✏️ Added `prem.getPlayheadPosition()`
- 📋 `__remoteFunc()` & `__remoteUXP()` now use `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time
- 📋 `__getAllLayerPos()` now uses `ShinsImageScanClass` to determine all layers
- 📋 `selectTool()` now accepts parameter `uiaOrPrem` & `focusTimeline`
- 📋 `__focusTimeline()` will first attempt to use UIA to focus the timeline before falling back to previous methods
- 📋 `toggleEnabled()` now uses `ShinsImageScanClass` to check for transition handles
    - This and a combination of other changes listed above, as well as changes in the previous release have made this function nearly 2x faster

### 📝 `ae {`
- ✅ Fixed `selectTool()` crashing AE
- ✏️ Added `ae.getActivePanelName()`
- 📋 `__remoteFunc()` now uses `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time

## PremiereRemote
- ✏️ Added `resetSelection()`

### 📝 `UXP`
- ✅ Fixed some actions not using `await`

## Other Changes
- 📋 `reloadAll.ahk` will now run `replaceHotkeyless.ahk` if `HotkeylessAHK.ahk` is open