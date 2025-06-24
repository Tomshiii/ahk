# <> Release 2.15.x - 

## Functions
- ✅ Fixed `disc.button("edit")` throwing if the user hovers over a message that isn't theirs
- ✅ Fixed `ytdlp.download()` videos containing audio that `Premiere` can't open. (youtube seems to be moving to all `opus` or `webm` audio streams)
- ✏️ Added `FormatWeekRange()`
- ✏️ Added `FormatWeekDay()`
- ✏️ Added `getDaySuffix()`
- ✏️ Added `resetOrigDetect()`
- 📋 `clip.returnClip()` & `clip.delayReturn()` now accept parameter `clearClipboard` to determine whether the clipboard should initially be cleared before attempting to return the stored clipboard. Defaults to `true`


⚠️ `prem {`
- ✅ Fixed `layerSizeAdjust()` not initially moving the mouse instantly
- ✏️ Added `disableAllMuteSolo()`
- ✏️ Added `pseudoFS()`
- ✏️ Added `changeLabel()`

📍 `valuehold()`
- ✅ Fixed function being unable to progress because `effCtrlCollapse.png` is different in `v24.x`
- ✅ Fixed function failing to find the `reset` button on `v24.x`
- ❌ Removed images for the old version of this function from the `..\Support Files\ImageSearch\Premiere\` directories for versions pre `Spectrum UI`

📍 `save()`
- 📋 Now accepts parameter `continueOnBusy`
- 📋 Will now return `"busy"` in the event that a window with a different class value has the current focus. *(parameter `continueOnBusy` must be set to `false`)*

⚠️ `premUIA_Values {`
- 📋 Will now alert the user if it fails to create the same amount of controls as defined within the class
- 📋 Will now alert the user if it sets duplicate values

⚠️ `Startup {`

📍 `trayMen()`
- Added ability to `open/close` `HotkeylessAHK.ahk`
- Reorganised entire tray menu, utilising submenus to clean everything up

## Other Changes
- ✅ Fixed `Premiere` hotkey <kbd>$+c::</kbd> should no longer attempt to fire while the user is typing
- ✏️ Added `generateProxies.ahk`
- `ExplorerDialogPathSelector.ahk` will no longer add its own tray menu item to `My Scripts.ahk`
- `autosave.ahk` will now no longer continue a `Premiere` save attempt when the `save` function determines Premiere may be busy to stop instances where saving may get stuck