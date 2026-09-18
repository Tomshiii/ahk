# <> Release 2.18.x - 

## Functions
- ✏️ Added `coord.screenToClient()`/`coord.clientToScreen()`, `cmd.httpGet()`, `premUIA_Values.getSelectedTool()`

### 📝 `prem {`
- ✏️ Added `prem.getPlayheadPosition()`
- 📋 `__getAllLayerPos()` now uses `ShinsImageScanClass` to determine all layers
- 📋 `selectTool()` now accepts parameter `selectMethod` & `focusTimeline`
- 📋 `__focusTimeline()` will first attempt to use UIA to focus the timeline before falling back to previous methods
- 📋 `toggleEnabled()` now uses `ShinsImageScanClass` to check for transition handles
    - This and a combination of other changes listed, as well as changes in the previous release have made this function nearly 2x faster
- 📋 `mouseDrag()` will now automatically return the selected tool back to its original selection and only uses `toolorig` as a final fallback

📍 `__remoteFunc()`/`__remoteUXP()`
- 📋 Will now alert the user if the respective extension panel is not open
- 📋 Now returns `null` for all non response failures instead of a mix of `null`/`false`
- 📋 Now use `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time
- 📋 Param `needResult` => `runAsync`
    - Both functions now always return their result

### 📝 `ae {`
- ✅ Fixed `selectTool()` crashing AE
- ✏️ Added `ae.getActivePanelName()`
- 📋 `__remoteFunc()` now uses `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time

### 📝 `ps {`
- ✅ Fixed using incorrect `ImageSearch` path
- 📋 `Type()` no longer needs to move the cursor

## PremiereRemote
- ✏️ Added `resetSelection()`, `isPanelOpen()`

### 📝 `UXP`
- ✅ Fixed some actions not using `await`

### KSA
- ✏️ Added most tools
- 📋 Renamed `cutTool` => `razorTool`

## Other Changes
- 📋 `reloadAll.ahk` will now run `replaceHotkeyless.ahk` if `HotkeylessAHK.ahk` is open