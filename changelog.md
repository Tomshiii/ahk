# <> Release 2.18.x - 
This update focuses on optimisations to reduce unnecessary wait times across a wide variety of functions. This includes; heavily reducing the startup delay for both `prem.__remote` functions, using `ShinsImageScanClass` when possible instead of `PixelSearch()`/`PixelGetColor()`, and more.

## Functions
- ✏️ Added `coord.screenToClient()`/`coord.clientToScreen()`, `cmd.httpGet()`
- 📋 `startup().trayMen()` now shows controls for `AERemote`/`PremiereRemote`

### 📝 `prem {`
- ✏️ Added `getPlayheadPosition()`, `getSelectedTool()`, `__getPixel()`, `__getPixelRegion()`
- 📋 `selectTool()` now accepts parameter `selectMethod` & `focusTimeline`
- 📋 `__focusTimeline()` will first attempt to use UIA to focus the timeline before falling back to previous methods
- 📋 `mouseDrag()` will now automatically return the selected tool back to its original selection and only uses `toolorig` as a final fallback
- 📋 `premUIA_Values.isToolSelected()` moved => `prem {`
- 📋 The following functions will now use `ShinsImageScanClass` instead of `PixelSearch()`/`PixelGetColor()` when possible;
    - `__getAllLayerPos()`, `isClipUnderCursor()`, `timelineFocusStatus()`, `toggleEnabled()`, `disableDirectManip()`, `movepreview()`, `__layerDividerCheck()`, `disableAllMuteSolo()`, `soloVideo()`, `searchPlayhead()`, `__getlayerTopBottom()`

📍 `__remoteFunc()`/`__remoteUXP()`
- 📋 Will now alert the user if the respective extension panel is not open (once per reload)
- 📋 Now returns `null` for all non response failures instead of a mix of `null`/`false`
- 📋 Now use `cmd.httpGet()` instead of `cmd.result()` to significantly reduce the response time
- 📋 Param `needResult` => `runAsync`
    - Both functions now always return their result

### 📝 `rbuttonPrem {`
- 📋 `movePlayhead()` will now return the selected tool to its original selection if it manually selects the nearby playhead
- 📋 `__checkForPlayhead()`/`__setColours()` will now use `ShinsImageScanClass` when possible

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
- 📋 `determineUIA.ahk` will now close itself if the user closes all open projects